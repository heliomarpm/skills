---
name: sk-observability
description: "Orienta observabilidade e SRE: OpenTelemetry (traces, métricas, logs), SLIs/SLOs, alertas por burn rate, health checks, graceful shutdown, profiling sistêmico e post-mortems sem culpados. Use para instrumentar, definir SLOs ou analisar incidentes. NÃO use para isolar/corrigir bug no código (sk-debug), CI/CD (sk-devops) nem C4 (sk-system-design)."
allowed-tools: Read, Edit, Write, Grep, Glob
---

# Observability: enxergar, medir e responder

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-observability`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Sem shell.** A skill não executa comandos. Para profiling e consultas, passe o comando ao usuário e analise a saída que ele colar. Confirme flags e versões na documentação da stack do projeto.

**Siga o que existe.** Leia `ARCHITECTURE.md`, ADRs e a stack. Use as ferramentas já adotadas (Prometheus, Datadog, Grafana, CloudWatch etc.) e não imponha fornecedor.

**Evidência.** Diagnóstico cita métrica, log ou perfil observado. Sem dado, é hipótese. Não invente números de SLO, tráfego ou orçamento.

**Sem PII.** Logs, atributos de trace e baggage não carregam senhas, tokens, cartões nem dados pessoais (`sk-security`).

**Sem culpados.** Post-mortems descrevem sistemas e decisões, não pessoas.

**Idioma.** O do usuário; nomes técnicos ficam como estão.

---

## 1. Modos de operação

| Modo | Quando |
| :--- | :--- |
| **Instrumentar** | Adicionar traces, métricas e logs |
| **Definir SLOs** | SLIs, metas, error budget e alertas |
| **Diagnosticar desempenho** | Memória, CPU ou latência em produção |
| **Post-mortem** | Analisar um incidente |
| **Revisar** | Avaliar a observabilidade existente |

---

## 2. Workflow

1. **Contexto**: stack, ferramentas de monitoramento já usadas, jornadas críticas.
2. **Sinais** (seção 3) e **SLOs** (seção 4) das jornadas que importam.
3. **Alertas** (seção 5) e **health checks** (seção 6).
4. Em problema de desempenho, siga a seção 7.
5. Em incidente, use o modelo da seção 8.
6. Registre as pendências (seção 9).

---

## 3. Os três sinais com OpenTelemetry

**Traces**
- Propague o contexto W3C (`traceparent`) em HTTP, mensagens de fila (cabeçalhos do broker) e tarefas assíncronas.
- Use SDK e auto-instrumentação da stack, com atributos de recurso (`service.name`, `service.version`, ambiente) e convenções semânticas estáveis.
- Amostragem: por cabeça (probabilística) para volume; por cauda (Collector) para guardar erros e latências altas.
- Exemplars ligam uma amostra de métrica ao trace correspondente.

**Logs**
- JSON em `stdout`, com `trace_id`, `span_id`, `service.name` e ambiente em todas as entradas (veja modelo em [examples/telemetry-and-shutdown.md](./examples/telemetry-and-shutdown.md)).
- Níveis coerentes, stack de erro em campo estruturado, volume e retenção sob controle de custo.
- Trilha de auditoria separada dos logs de aplicação.

**Métricas**
- **RED** para serviços (taxa, erros, duração em percentis) e **USE** para recursos (utilização, saturação, erros). Os "golden signals" do SRE cobrem latência, tráfego, erros e saturação.
- Histogramas com buckets alinhados ao SLO.
- **Cardinalidade baixa**: nunca `user_id`, `email` ou `order_id` como rótulo. Use `route`, `method`, `status_class`.

---

## 4. SLI, SLO e error budget

- **SLI**: medida na jornada do usuário (ex.: proporção de `POST /pagamentos` com 2xx em menos de 500 ms).
- **SLO**: meta e janela (ex.: 99,9% em 30 dias), acordadas com o negócio.
- **Error budget**: 100% menos o SLO. Defina a política de uso: com o orçamento esgotado, prioridade vai para confiabilidade antes de novas funcionalidades.

**Alertas por burn rate**, em múltiplas janelas:

| Janela longa | Janela curta | Burn rate | Ação |
| :--- | :--- | :--- | :--- |
| 1 h | 5 min | 14,4 | Acionar plantão |
| 6 h | 30 min | 6 | Acionar plantão |
| 3 dias | 6 h | 1 | Abrir ticket |

---

## 5. Alertas

Alerte sobre **sintomas** que o usuário sente (SLO), não sobre causas internas isoladas. Todo alerta é acionável, tem severidade, dono e link para um runbook. Alerta que ninguém age sobre é removido ou rebaixado.

---

## 6. Health checks e graceful shutdown

- **Liveness**: só verifica se o processo está vivo. Nunca consulte banco ou dependências externas: se a dependência cair, reiniciar tudo agrava o problema.
- **Readiness**: verifica se a instância pode receber tráfego. Cheque só dependências críticas, com cache curto, para que a queda de uma dependência compartilhada não retire todas as instâncias de uma vez.
- **Startup probe**: para aplicações de inicialização lenta, evita que a liveness reinicie o processo cedo demais.

**Shutdown**: ao receber `SIGTERM`, a instância se marca como não pronta, espera o balanceador retirá-la, termina as requisições em curso, fecha conexões ociosas e libera recursos. O tempo total fica abaixo do `terminationGracePeriodSeconds` (padrão de 30 s no Kubernetes); um `preStop` com pequena pausa ajuda a drenar o tráfego. Veja a implementação de referência em [examples/telemetry-and-shutdown.md](./examples/telemetry-and-shutdown.md).

---

## 7. Diagnóstico de desempenho (memória, CPU, latência)

**Meça antes de otimizar.** Estabeleça uma linha de base, reproduza sob carga, compare **dois snapshots** separados no tempo e correlacione com deploys.

| Stack | Ferramentas comuns (confirme as flags na versão do projeto) |
| :--- | :--- |
| Node | Heap snapshot (DevTools), `--cpu-prof`, `clinic` |
| Go | `pprof` (heap, CPU, goroutines) |
| Java | JFR, `async-profiler`, `jcmd` com heap dump |
| .NET | `dotnet-counters`, `dotnet-trace`, `dotnet-gcdump` |
| Python | `py-spy`, `tracemalloc` |
| PHP | Profiler do Xdebug ou SPX |

Procure por crescimento contínuo de objetos retidos: listeners não removidos, caches sem limite, conexões não liberadas, closures que seguram referências. Para consultas lentas e N+1, use o `sk-sql`. Dumps podem conter PII: trate-os como dados sensíveis.

---

## 8. Post-mortem sem culpados

````markdown
# Post-mortem: <título do incidente>

- **Resumo**: o que aconteceu, em duas linhas.
- **Impacto**: quem foi afetado, por quanto tempo, gravidade.
- **Linha do tempo**: horários de início, detecção, mitigação e resolução.
- **Causa raiz** e **fatores contribuintes**: o que estava errado no sistema.
- **Detecção**: como descobrimos; poderia ter sido mais cedo?
- **Resposta**: o que funcionou e o que não funcionou.
- **Ações**: cada uma com dono, prazo e prioridade.
- **Lições**: o que muda no processo ou na arquitetura.
````

Ações viram tarefas no `sk-tasks`; uma mudança de arquitetura gera um ADR via `sk-adr`.

---

## 9. Integrações e registro via `sk-tasks`

Se houver lacunas ou ações pendentes relevantes, pergunte ao final:

> *"Deseja que eu registre as melhorias de observabilidade no `TASKS.md` do projeto?"*

Com a confirmação, acione a skill `sk-tasks` (modo Importar), com origem `observability`, links relativos e a prioridade: alerta crítico ausente, SLO e correção de causa raiz de incidente P1; shutdown e probes P2; dashboards e otimizações P3. **Fallback**: lista no chat.

| Skill | Como se integra |
| :--- | :--- |
| `sk-debug` | Usa os sinais daqui para chegar à causa de um bug específico |
| `sk-system-design` | Modos de falha, lag de consumidores e métricas de filas |
| `sk-devops` | Collector, probes, dashboards e alertas como código |
| `sk-sql` | Consultas lentas e N+1 |
| `sk-security` | Logs sem PII e trilha de auditoria |
| `sk-adr` | Decisões de observabilidade e mudanças pós-incidente |
| `sk-code-review` | Verifica instrumentação e logs em PRs |

Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 10. Armadilhas

- **Alta cardinalidade em métricas**: `user_id` e `order_id` como rótulo.
- **Liveness acoplada ao banco**: reinicializações em cascata.
- **Readiness que checa tudo**: a queda de uma dependência derruba todas as instâncias.
- **Logs com PII ou segredos.**
- **Alerta sem ação ou sem runbook**: gera ruído e fadiga.
- **Alerta em causa, não em sintoma.**
- **Shutdown sem retirar do balanceador**: derruba requisições em curso.
- **Otimizar sem medir**: ataca o problema errado.
- **Amostragem que descarta os erros.**
- **Post-mortem que busca culpado**: esconde a causa sistêmica.

---

## 11. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado (seção 1).
2. Sinais, SLOs ou diagnóstico, com a evidência usada e as premissas declaradas.
3. Arquivos alterados, com links relativos, ou comandos para o usuário executar.
4. Pendências e a pergunta condicional sobre o registro em tarefas (seção 9).
