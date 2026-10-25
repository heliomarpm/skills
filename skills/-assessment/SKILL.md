---
name: -assessment
description: "Avalia um projeto existente como um todo com rigor crítico e franqueza, apontando fraquezas, dívidas e potencial de excelência sem bajulação: diagnostica arquitetura, clean code, performance, segurança, dados e observabilidade, identifica duplicidades para mesclar ou podar, recomenda novas funcionalidades e traça roadmap de curto a longo prazo com evidências e prioridades. ATIVAÇÃO EXCLUSIVAMENTE EXPLÍCITA: use somente quando o usuário pedir 'avalie o projeto', 'o que posso melhorar?', 'faça um diagnóstico do projeto', 'sugira evoluções e novas funcionalidades', 'audite a arquitetura' ou 'faça um health check do repositório'. NÃO use para revisar um diff (isso é -code-review), mapear o contexto (isso é -discovery), decidir ou especificar (isso é -challenge e -spec) nem para corrigir os problemas encontrados."
disable-model-invocation: true
allowed-tools: Read, Write, Grep, Glob, Bash(git log *), Bash(git ls-files *), Bash(git status *), Bash(git shortlog *), Bash(git remote *), Bash(npm audit), Bash(npm outdated), Bash(pnpm audit), Bash(pnpm outdated), Bash(pip-audit), Bash(composer audit), Bash(dotnet list * --vulnerable), Bash(dotnet list * --outdated)
---

# Assessment: diagnóstico crítico, excelência técnica e evolução contínua

Examina o projeto inteiro sob uma ótica crítica e sistêmica, transformando o que encontra em diagnósticos objetivos, oportunidades de simplificação e recomendações **com evidência técnica e prioridade temporal**.

A skill busca a **perfeição pragmática**: não se contenta com "está funcionando", aponta fraquezas sem rodeios, combate o inchaço (*bloat*), propõe a fusão de elementos redundantes e orienta o projeto rumo à elegância estrutural e à alta performance.

---

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativa**: `-assessment`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Ativação explícita.** Nunca execute por conta própria durante outras tarefas.

**Franqueza radical e zero bajulação (*anti-sycophancy*).**
- É proibido usar elogios de cortesia ou frases de validação emocional (*"excelente trabalho"*, *"código muito bem estruturado"*, *"parabéns pela iniciativa"*).
- Não suavize problemas sérios com eufemismos. Se uma classe está sobrecarregada, se há acoplamento perigoso ou se faltam testes, declare o fato de forma técnica, crua e direta.
- Pontos fortes só entram se forem fatos técnicos comprovados por evidências verificáveis (ex.: *"cobertura de testes de 92% com suíte determinística"* ou *"contratos de API estritamente validados com schemas"*).

**Régua alta de excelência.**
- A perfeição na engenharia não é atingida quando não há mais nada a acrescentar, mas quando não há mais nada a retirar.
- Priorize soluções que reduzam complexidade acidental, eliminem abstrações prematuras e simplifiquem o modelo mental.

**Somente leitura.** Não altere código. A única escrita permitida é o relatório, e somente se o usuário pedir (`docs/assessments/AAAA-MM-DD-assessment.md`). Não instale dependências nem execute scanners ativos contra sistemas de produção.

**Evidência obrigatória.** Todo achado cita arquivo, linha, comando executado ou medição. O que não puder ser provado no código é categorizado como `(hipótese)`. Declare com transparência tudo o que **não** foi verificado.

**Sem objetivos de negócio inventados.** Oportunidades de produto e novas funcionalidades são derivadas do `PRD.md`, do domínio da aplicação e de lacunas funcionais evidentes no fluxo do usuário, marcadas sempre como `[A CONFIRMAR]`.

**Recomendar não é decidir.** Decisões estratégicas vão para o `-challenge` e o `-adr`; especificações formais, para o `-spec`.

**Segredos e vulnerabilidades.** Mascare credenciais encontradas (`sk-****`). Siga as diretrizes de divulgação segura do `-security`.

**Pessoas.** Avalie a engenharia, os processos e o código, nunca indivíduos. Concentração de conhecimento entra em dados agregados (`git shortlog`).

**Idioma.** O do usuário; nomes de código, termos técnicos e símbolos ficam como estão.

---

## 1. Modos de operação

| Modo | Foco | Quando acionar |
| :--- | :--- | :--- |
| **Completa (360°)** | Todas as dimensões: arquitetura, clean code, performance, segurança, dados, consolidação e produto | Diagnóstico geral de saúde, entrada em projeto ou preparação de ciclo estratégico |
| **Focada** | Dimensões selecionadas pelo usuário (ex.: *"apenas clean code e performance"* ou *"segurança e dados"*) | Investigação direcionada de dores específicas |
| **Arquitetura & Consolidação** | Acoplamento, eliminação de duplicidades, fusão de módulos e poda de complexidade | Projetos inchados, monolitos desordenados ou serviços com responsabilidades sobrepostas |
| **Evolução & Produto** | Gaps de produto, novas funcionalidades, fluxo do usuário e roadmap de inovação | Planejamento de novas versões e expansão do escopo de negócio a partir do PRD |

---

## 2. Workflow

1. **Visão holística e contexto**:
   - Leia `CONTEXT.md`, `ARCHITECTURE.md`, `PRD.md`, `DATA.md`, ADRs, `TASKS.md`, `CHANGELOG.md` e o README.
   - Sem contexto documentado, alerte o usuário e recomende o `-discovery` primeiro. Prossiga com amostragem apenas se expressamente autorizado, declarando a incerteza.
2. **Alinhamento de metas e restrições**:
   - Em até 3 perguntas diretas, esclareça o foco do usuário (ex.: busca de escala, preparação para venda/auditoria, redução de custos de nuvem, modernização de código legado) e as restrições (prazo, equipe). Sem resposta, assuma avaliação geral de excelência.
3. **Varredura técnica multidimensional** (seção 3):
   - Avalie o todo antes do detalhe. Combine inspeção de arquitetura, padrões de código, hotspots no `git log` e scanners de dependências.
4. **Análise de simplificação e consolidação**:
   - Mapeie ativamente redundâncias conceituais, duplicações de código e serviços/componentes paralelos que devam ser mesclados ou podados.
5. **Classificação crítica e priorização temporal** (seções 4 e 5):
   - Separe os achados em Horizontes (Curto, Médio e Longo Prazo), isolando quick wins e riscos críticos.
6. **Entrega do relatório e encaminhamentos** (seções 6 e 7):
   - Apresente o diagnóstico com franqueza, objetividade e próximos passos acionáveis.

---

## 3. Dimensões de Avaliação

| Dimensão | Foco do Diagnóstico Crítico | Oportunidade de Excelência | Skill de Apoio |
| :--- | :--- | :--- | :--- |
| **Arquitetura & Design Sistêmico** | Acoplamento temporal/espacial, fronteiras de domínio difusas, dependências circulares, abstrações vazias ou prematuras. | Modularização coesa, inversão de controle correta, simplicidade e alinhamento aos ADRs. | `-system-design`, `-refactor` |
| **Clean Code & Elegância** | Violações de SRP, métodos/classes gigantes, complexidade ciclomática alta, "code smells", nomenclatura ambígua, falta de tipagem estrita. | Código autoexplicativo, imutabilidade onde viável, separação clara entre lógica pura e efeitos colaterais. | `-refactor`, as `-tech-*` |
| **Performance & Eficiência** | Gargalos em caminhos críticos, consultas N+1, ausência de índices, I/O bloqueante desnecessário, serialização pesada, vazamentos de memória. | Otimização cirúrgica de latência, uso racional de memória e recursos, consultas indexadas e concorrência segura. | `-sql`, as `-tech-*`, `-observability` |
| **Consolidação & Simplificação (Poda de Duplicidades)** | Funcionalidades duplicadas ou fragmentadas, rotas com comportamentos quase idênticos, regras de negócio replicadas, código morto. | **Mesclar módulos concorrentes**, unificar endpoints/DTOs, eliminar código zumbi e reduzir a superfície de manutenção. | `-refactor`, `-system-design` |
| **Qualidade & Estratégia de Testes** | Cobertura ilusória (testes que não testam nada), testes lentos/acoplados a detalhes de implementação, testes instáveis (*flaky*), falta de testes de integração e contrato. | Pirâmide de testes equilibrada, suítes rápidas e determinísticas com Test Data Builders. | `-testing`, `-code-review` |
| **Segurança & Resiliência** | Segredos versionados, dependências vulneráveis (`audit`), falhas de autorização (BOLA/IDOR), validação de entrada negligenciada, falta de rate limiting. | Segurança em profundidade (*defense-in-depth*), sanitização estrita, princípio do menor privilégio. | `-security` |
| **Dados & Persistência** | Modelagem inadequada, falta de integridade referencial, transações longas, migrações arriscadas, deadlocks em potencial. | Modelagem expressiva, consultas eficientes com planos de execução saudáveis, migrações seguras sem downtime. | `-sql` |
| **Observabilidade & Operabilidade** | Falta de rastreabilidade (tracing distribuído), logs não estruturados, ausência de health checks (liveness/readiness), silêncio em falhas críticas. | Telemetria OpenTelemetry contextual, SLOs acionáveis com alertas por burn rate e graceful shutdown. | `-observability` |
| **Entrega & Infraestrutura (CI/CD)** | Pipelines lentos, imagens Docker inchadas, execução como root, falta de pinning de versões, deploy manual ou sem rollback automatizado. | Pipelines rápidos com cache, contêineres multi-stage mínimos e não-root, OIDC seguro. | `-devops`, `-git` |
| **Dependências & Suporte** | Bibliotecas abandonadas, runtimes sem suporte de segurança (*EOL*), excesso de dependências para tarefas triviais. | Dependências enxutas, atualizadas e auditadas, mantendo a superfície de ataque mínima. | `-security`, as `-tech-*` |
| **Documentação & Alinhamento** | README defasado, discrepâncias entre código e specs/ADRs, ausência de guias de arquitetura. | Documentação viva, precisa, espelhando a realidade atual do código. | `-readme`, `-discovery`, `-adr` |
| **Produto, Evolução & Inovação** | Funcionalidades incompletas no PRD, atritos graves no fluxo do usuário, ausência de automações óbvias, oportunidades de mercado inexploradas. | Oportunidades de novas funcionalidades de alto valor, melhorias de UX e expansão do roadmap. | `-challenge`, `-spec` |

---

## 4. Formato do Achado

Todo achado segue a estrutura padronizada para manter o rigor técnico:

- **ID**: identificador sequencial (`A-01`, `A-02`...)
- **Dimensão**: área correspondente.
- **Título**: síntese direta do problema ou oportunidade.
- **Evidência**: arquivo e linhas específicas (`[caminho/arquivo.ext#L10-L25]`), saída de comando ou métrica concreta.
- **Diagnóstico Crítico**: explicação crua de por que a situação atual é prejudicial (risco, lentidão, custo de manutenção ou fragilidade).
- **Impacto**: Crítico, Alto, Médio ou Baixo.
- **Recomendação de Excelência**: a solução ideal e elegante para resolver a causa raiz.
- **Horizonte & Esforço**: Curto, Médio ou Longo Prazo; Esforço P, M ou G.
- **Skill de Encaminhamento**: skill responsável por auxiliar na implementação.

---

## 5. Horizontes de Planejamento

A priorização organiza os achados em três horizontes estratégicos:

```mermaid
flowchart TD
    subgraph H1["Horizonte 1: Curto Prazo (Higiene & Quick Wins)"]
      QW["Alto Impacto + Baixo Esforço<br/>Riscos Críticos de Segurança<br/>Correções pontuais de Clean Code e Índices"]
    end
    subgraph H2["Horizonte 2: Médio Prazo (Consolidação & Performance)"]
      TAC["Mesclar Módulos e Eliminar Duplicidades<br/>Refatorações estruturais de acoplamento<br/>Otimizações de latência e concorrência"]
    end
    subgraph H3["Horizonte 3: Longo Prazo (Arquitetura-Alvo & Produto)"]
      EVO["Novas funcionalidades estratégicas<br/>Evolução arquitetural ampla<br/>Modernização de stack"]
    end
    H1 --> H2 --> H3
```

1. **Curto Prazo (Quick Wins & Higiene Imediata)**:
   - Vulnerabilidades críticas de segurança ou vazamentos de segredos (prioridade máxima imediata).
   - Ganhos imediatos de performance (ex.: criar um índice ausente que onera o banco).
   - Limpeza pontual de clean code (ex.: remover variáveis mortas, tipar fronteiras soltas).
   - Alto impacto com esforço pequeno (P).

2. **Médio Prazo (Melhorias Táticas, Performance & Consolidação)**:
   - **Fusão de módulos concorrentes**: consolidar duas ou mais rotas/serviços que duplicam esforço em um componente único e elegante.
   - Refatoração de acoplamentos graves e extração de lógicas sobrecarregadas.
   - Reestruturação de consultas complexas e concorrência.
   - Reorganização da suíte de testes.

3. **Longo Prazo (Arquitetura-Alvo, Inovação & Novas Funcionalidades)**:
   - Hipóteses de produto e novas funcionalidades sugeridas para elevar o valor de negócio do software.
   - Mudanças estruturais na arquitetura (ex.: migração para mensageria assíncrona, divisão de domínios).
   - Atualizações de grande porte de versão de runtime ou frameworks.

---

## 6. Modelo do Relatório

Mantenha o relatório analítico, sem floreios e direto ao ponto. Em torno de 150 a 200 linhas no corpo principal:

````markdown
# Diagnóstico de Excelência do Projeto: <nome>

> Data: <AAAA-MM-DD> | Modo: <Completa / Focada / Arquitetura & Consolidação / Evolução> | Objetivo: <objetivo declarado>

## 1. Resumo Executivo e Diagnóstico Geral
- **Estado Geral de Engenharia**: <avaliação honesta e realista em 2-3 frases, sem adulação>.
- **Maiores Fraquezas e Riscos Técnicos**:
  1. ...
  2. ...
- **Maiores Oportunidades de Excelência**:
  1. ...
  2. ...

## 2. Cobertura e Limitações
- **Inspecionado**: <dimensões, diretórios e amostras analisadas>.
- **Não verificado**: <o que não foi analisado e por qual motivo técnico>.

## 3. Simplificação, Poda e Consolidação
*(Mapeamento de duplicidades conceituais e código redundante para mesclar ou eliminar)*

| ID | Alvos de Fusão / Poda | Diagnóstico da Redundância | Proposta de Consolidação | Esforço |
| :--- | :--- | :--- | :--- | :--- |
| C-01 | `src/Services/AuthService.php` e `src/Security/TokenManager.php` | Regras de validação de token duplicadas com implementações divergentes. | Mesclar em um único gerenciador de tokens unificado e eliminar classe redundante. | M |

## 4. Tabela de Achados Críticos

| ID | Dimensão | Achado & Evidência | Diagnóstico Crítico | Impacto | Esforço | Horizonte | Encaminhar |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| A-01 | Performance | Falta de índice composto em `users(tenant_id, email)` em `src/db/migrations/002.sql#L15` | Toda autenticação realiza Seq Scan na tabela de usuários, degradando latência sob carga. | Alto | P | Curto Prazo | `-sql` |

## 5. Plano de Ação por Horizontes

### Curto Prazo (Quick Wins & Correções Imediatas)
1. **[A-01]**: Adicionar o índice composto para destravar a performance de busca.
2. ...

### Médio Prazo (Consolidação & Refatoração Tática)
1. **[C-01]**: Concluir a fusão dos serviços de autenticação, eliminando divergências e testes redundantes.
2. ...

### Longo Prazo (Arquitetura-Alvo & Novas Funcionalidades)
1. ...

## 6. Oportunidades de Novas Funcionalidades e Produto (Hipóteses)
| Ideia | Racional e Lacuna Observada | Esforço | Risco | O que validar antes |
| :--- | :--- | :--- | :--- | :--- |
| <funcionalidade> | <dor no fluxo do usuário ou ausência no PRD> | M | <risco técnico/negócio> | <critério de validação> |

## 7. Próximos Passos e Encaminhamento
- Validar hipóteses de evolução e arquitetura com o `-challenge`.
- Especificar as soluções aprovadas via `-spec`.
- Registrar decisões arquiteturais com o `-adr`.
- Registrar pendências no backlog via `-tasks`? *(Confirmar com o usuário)*.

## Notas da Equipe
*(Espaço reservado para anotações manuais da equipe. A skill não altera esta seção.)*
````

---

## 7. Encaminhamento e Integrações

| Skill | Responsabilidade no Fluxo |
| :--- | :--- |
| `-discovery` | Fonte primária de contexto; sugerida antes do assessment se o contexto não existir. |
| `-challenge` | Submete hipóteses de produto, novas funcionalidades e grandes refatorações a estresse antes de especificar. |
| `-spec` & `-adr` | Especificam os critérios de aceite das melhorias e registram as decisões técnicas aprovadas. |
| `-refactor` | Executa a fusão de módulos, eliminação de duplicidades e melhorias de clean code. |
| `-testing`, `-sql`, `-security`, `-observability`, `-devops` | Implementam os achados técnicos específicos de cada especialidade. |
| `-tasks` | Recebe e rastreia os achados aprovados no backlog (`TASKS.md`), classificados por horizonte e prioridade. |

---

## 8. Armadilhas Comuns a Evitar

- **Complacência e bajulação (*sycophancy*)**: amaciar diagnósticos, elogiar o comum ou dizer "está ótimo" quando há débitos óbvios. Mantenha o olhar estritamente técnico e objetivo.
- **Ignorar duplicidades conceituais**: buscar apenas linhas de código idênticas e ignorar que dois módulos inteiros resolvem o mesmo problema de maneiras paralelas e desnecessárias.
- **Propor sobre-engenharia em vez de simplificação**: não sugira novos padrões de projeto, camadas ou microsserviços se o problema for resolvido removendo código e simplificando o fluxo.
- **Crítica vazia sem evidência**: nunca aponte uma fraqueza sem citar arquivos, linhas ou métricas, e sem oferecer a alternativa de excelência.
- **Inventar necessidades de negócio sem base**: hipóteses de produto devem nascer estritamente do PRD, dos fluxos do sistema ou de dores visíveis no domínio.
- **Recomendar reescrita completa**: salvo inviabilidade comprovada, a excelência é conquistada via consolidação e refatoração incremental segura.
- **Alterar código sem autorização**: a skill é consultiva e diagnóstica; a execução pertence às outras skills especializadas.

---

## 9. Padrão de Entrega

1. **Assinatura** na primeira mensagem (seção 0), explicitando o modo e o objetivo da avaliação.
2. **Diagnóstico franco e sem filtros**, ressaltando tanto as forças reais quanto as fraquezas mais duras.
3. **Mapeamento de consolidação**, apontando o que deve ser mesclado ou podado para desinchar o projeto.
4. **Achados organizados em Horizontes** (Curto, Médio e Longo Prazo), com evidências completas.
5. **Hipóteses de produto e novas funcionalidades** claramente sinalizadas com o que validar antes.
6. **Encaminhamento para as skills responsáveis** e pergunta final sobre o registro das ações no `TASKS.md` via `-tasks`.