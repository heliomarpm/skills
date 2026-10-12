---
name: -tasks
description: "Gerencia o backlog do projeto no arquivo TASKS.md: planeja, cria, decompõe, atualiza o status, audita contra o código e arquiva tarefas, com rastreabilidade para specs e para o discovery. Use sempre que o usuário falar de tarefas, backlog, TASKS.md, 'o que falta fazer', 'próximo passo', 'atualizar progresso', 'marcar como concluída', 'quebrar em tarefas' ou 'registrar pendências', e quando as skills -spec ou -discovery repassarem tarefas e débitos para registro. NÃO use para pedidos de código comuns em que o usuário não pediu para registrar ou acompanhar tarefas."
allowed-tools: Read, Edit, Write, Grep, Glob
---

# Tasks: backlog vivo e rastreável em TASKS.md

Padroniza o ciclo de planejamento, decomposição, execução e arquivamento de tarefas de um projeto no arquivo `TASKS.md`, com estado confiável, evidência de conclusão e vínculo com as specs e com o discovery.

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativa**: `-tasks`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Escopo de escrita.** Com a skill ativa (o usuário pediu para planejar, registrar ou atualizar tarefas), grave no `TASKS.md`. Durante outro trabalho (código, revisão, testes), não edite o arquivo por conta própria: ao final, ofereça registrar as pendências encontradas e aguarde a confirmação.

**Sem pendências ocultas.** Com a skill ativa, nenhuma pendência descoberta fica só no chat: registre no `TASKS.md` ou, se o usuário não quiser registrar, liste-a no resumo final.

**Sem shell.** A skill não executa comandos. Para verificar o estado real use `Read`, `Grep` e `Glob`. Resultados de testes só valem se estiverem visíveis na conversa ou forem informados pelo usuário.

**Data.** Use a data do contexto da conversa. Se não estiver disponível, omita a data; nunca invente.

**Idioma.** Siga o idioma do `TASKS.md` existente; sem arquivo, o da documentação do repositório; sem ela, o do pedido.

---

## 1. Modos de operação

Identifique o modo pelo pedido e diga qual está usando.

| Modo | Quando | O que faz |
| :--- | :--- | :--- |
| **Planejar** | Criar tarefas novas ou o backlog inicial | Cria entradas completas (seção 3.3) |
| **Atualizar** | Mudar estado ou progresso | Move a entrada de seção, ajusta contador e cabeçalho |
| **Auditar** | "Sincronize com o código", "o que já foi feito?" | Compara backlog e código; corrige estados com evidência e lista as dúvidas |
| **Decompor** | Tarefa grande ou vaga | Quebra em tarefas INVEST (seção 4.2) |
| **Importar** | Plano de uma spec ou débitos do discovery | Cria entradas com origem e referência (seção 6) |

---

## 2. Resolução do arquivo alvo

Procure, nesta ordem, e use o primeiro encontrado:

1. `./TASKS.md`
2. `./.agents/TASKS.md`
3. `./agents/TASKS.md`
4. `./docs/TASKS.md`

**Variações aceitas**, para preservar a convenção do projeto: `TASK.md`, `tasks.md`, `task.md` nos mesmos locais. Em sistemas de arquivos que ignoram maiúsculas e minúsculas (Windows, macOS), `TASKS.md` e `tasks.md` são o mesmo arquivo; trate-os como um só. Se achar mais de um arquivo de tarefas, não crie outro: use o primeiro da ordem e avise o usuário da duplicidade.

**Nunca crie um segundo arquivo** se qualquer um dos acima existir.

**Criação (nenhum existe)**, sempre com o nome no plural `TASKS.md`:

- Se a skill foi chamada pelo `-discovery` ou pelo `-spec`, use o diretório dos arquivos de contexto ou da spec.
- Senão, se existirem arquivos de contexto (`AGENTS.md`, `CONTEXT.md`) em `./.agents/`, `./agents/` ou `./docs/`, use esse diretório.
- Senão, use `./.agents/` ou `./agents/` se a pasta existir; caso contrário, a raiz `./`.

---

## 3. Formato do arquivo

### 3.1. Adaptação ao que existe

Se o `TASKS.md` já existe, **adapte-se ao formato dele**. Aplique o modelo desta skill somente em arquivo novo. Se o formato existente divergir muito (por exemplo, sem seções ou com marcadores próprios), pergunte antes de migrar; nunca reestruture por conta própria.

### 3.2. Estados

Use apenas os checkboxes padrão `[ ]` e `[x]`, que renderizam em qualquer visualizador. O estado é dado pela **seção** em que a tarefa está:

| Seção | Significado | Regra |
| :--- | :--- | :--- |
| Em progresso | Trabalho ativo | Limite de WIP: 2 por padrão, configurável no cabeçalho |
| Bloqueadas | Impedimento externo ou dependência | Título com **[BLOQUEADA]** e linha `Bloqueio:` com causa e ação necessária |
| Backlog | Pendente, ordenada por prioridade | Prioridade P0 a P3 em cada tarefa |
| Concluídas recentemente | Feita, com evidência | `[x]`, data, arquivos e evidência |
| Canceladas | Descartada ou substituída | Título com **[CANCELADA]** e justificativa curta |

Prioridade é uma dimensão separada do estado: **P0** crítico (segurança, produção parada), **P1** alta, **P2** média, **P3** baixa (débitos e otimizações).

### 3.3. Campos de uma tarefa

Toda tarefa tem: ID, prioridade, título, **origem** (`manual`, `bug`, `spec <id> / T-NN`, `adr ADR-NNNN` ou o nome da skill que a gerou, como `-discovery`, `-code-review`, `-testing`, `-refactor`, `-debug`, `-security`, `-devops`, `-sql`, `-observability`, `-api-design`, `-system-design`, `-ai-engineering`, `-design-system` e `-tech-*`), **dependências**, **referências** a arquivos e **critérios de aceite** (DoD) observáveis.

- **IDs**: `T-NNN`, globais no arquivo, alocados como o maior ID existente (incluindo concluídas, canceladas e arquivadas) mais um. Nunca reutilize um ID.
- **Links**: sempre relativos ao arquivo, com linha quando útil: `[arquivo.ts](./src/arquivo.ts#L45-L60)`. Nunca `file:///`.

### 3.4. Cabeçalho e contador

O cabeçalho traz: meta atual, status geral, progresso, limite de WIP e data da última atualização.

**Progresso** = concluídas ÷ (total − canceladas), arredondado para baixo, recalculado a partir das seções a cada escrita. Os arquivos arquivados não entram na conta.

### 3.5. Tamanho e arquivamento

Mantenha o `TASKS.md` com até ~300 linhas. Em "Concluídas recentemente" e "Canceladas", mantenha as últimas 10 entradas ou 30 dias. O excedente vai para `TASKS.archive.md` no mesmo diretório (avise ao criá-lo) ou, se o usuário preferir, é resumido em uma linha de histórico com a contagem. Nunca descarte um item sem registro.

---

## 4. Workflow

### 4.1. Leitura, auditoria e duplicatas

1. **Leia o arquivo inteiro** antes de qualquer escrita. Nunca sobrescreva às cegas e preserve anotações, links e observações manuais.
2. **Cheque o código**: tarefas pendentes que já parecem implementadas, novas dependências ou migrações, quebras de contrato desde a última atualização.
3. **Procure duplicatas** antes de adicionar, inclusive entre concluídas e canceladas.
4. **Valide o escopo**: o item atende ao objetivo atual sem aumentar a complexidade sem necessidade?

### 4.2. Decomposição (INVEST)

Tarefas devem ser independentes (ou com dependência explícita), claras, estimáveis, pequenas (uma iteração, poucos arquivos, uma responsabilidade) e testáveis (DoD observável). Ao decompor, a tarefa original vira um **épico**: lista os IDs das filhas e só é concluída quando todas forem.

### 4.3. Atualização cirúrgica

1. **Releia o arquivo imediatamente antes de gravar** (ele pode ter mudado). Faça edições pequenas e localizadas.
2. Mova a tarefa para a seção do novo estado, mantendo a formatação existente.
3. Recalcule o contador e a data no cabeçalho.
4. Registre agora as pendências descobertas no caminho (bugs colaterais, refatorações, débitos), respeitando as regras da seção 0.

### 4.4. Evidência de conclusão

Só marque `[x]` com evidência:

- Os arquivos esperados existem ou foram alterados (confirmado com `Read` ou `Grep`).
- Os testes passaram, conforme resultado visível na conversa ou informado pelo usuário.

Sem evidência de testes, pergunte ao usuário. Se ele confirmar a conclusão sem testes, marque `[x]` e acrescente "(testes não verificados)". Registre a evidência na própria tarefa.

---

## 5. Modelo de referência

Ilustrativo. Em arquivo existente, adapte-se ao formato dele (seção 3.1).

````markdown
# Tarefas do Projeto

> Meta: autenticação OAuth 2.1 com PKCE e proteção CSRF nas APIs públicas
> Status: em desenvolvimento | Progresso: 3/10 (30%) | WIP: 1/2 | Atualizado em: 2026-10-11

## Em progresso

- [ ] **T-004 · P1 · Implementar middleware de validação do code challenge (PKCE)**
  - Origem: spec 003 / T-02 | Dep.: T-003
  - Ref: [auth_middleware.ts](./src/middlewares/auth_middleware.ts)
  - DoD:
    - [x] Validar desafio SHA-256 em tempo constante
    - [ ] Rejeitar requisição sem `code_verifier` válido
    - [ ] Testes unitários com os vetores da RFC 7636

## Bloqueadas

- [ ] **T-009 · P3 · [BLOQUEADA] Adicionar métricas Prometheus de tokens emitidos e revogados**
  - Origem: discovery | Dep.: nenhuma
  - Bloqueio: stack de observabilidade ainda não decidida. Ação: definir com a equipe.

## Backlog

- [ ] **T-005 · P0 · Validar `redirect_uri` contra a whitelist no callback**
  - Origem: bug | Dep.: nenhuma
  - Ref: [callback_handler.ts](./src/handlers/callback_handler.ts#L45-L60)
  - DoD: URIs fora da whitelist ou sem `https://` retornam `400`; teste cobre os dois casos.
- [ ] **T-003 · P1 · Repositório Redis para armazenamento transitório de tokens**
  - Origem: spec 003 / T-01 | Dep.: nenhuma
- [ ] **T-006 · P2 · Endpoint `/oauth/v2/token` (RFC 6749)**
  - Origem: spec 003 / T-03 | Dep.: T-003, T-004
- [ ] **T-007 · P2 · Rota de revogação `/oauth/v2/revoke` (RFC 7009)**
  - Origem: spec 003 / T-04 | Dep.: T-006
- [ ] **T-008 · P3 · Trocar o hash síncrono por Argon2id nativo**
  - Origem: discovery | Dep.: nenhuma

## Concluídas recentemente

- [x] **T-002 · P1 · Entidade `AuthorizationCode` com TTL e uso único** (2026-10-09)
  - Arquivos: [authorization_code.ts](./src/domain/authorization_code.ts)
  - Evidência: testes passaram (informado pelo usuário)
- [x] **T-001 · P1 · DTOs imutáveis de Token Request e Token Response** (2026-10-08)
- [x] **T-000 · P2 · Setup de testes unitários com Vitest** (2026-10-07)
  - Arquivos: [vitest.config.ts](./vitest.config.ts)

## Canceladas

(nenhuma)
````

### Exemplo de atualização: concluir a T-004

```diff
-> Status: em desenvolvimento | Progresso: 3/10 (30%) | WIP: 1/2 | Atualizado em: 2026-10-11
+> Status: em desenvolvimento | Progresso: 4/10 (40%) | WIP: 0/2 | Atualizado em: 2026-10-12

 ## Em progresso
-
-- [ ] **T-004 · P1 · Implementar middleware de validação do code challenge (PKCE)**
-  - Origem: spec 003 / T-02 | Dep.: T-003
+
+(nenhuma)

 ## Concluídas recentemente
+
+- [x] **T-004 · P1 · Implementar middleware de validação do code challenge (PKCE)** (2026-10-12)
+  - Arquivos: [auth_middleware.ts](./src/middlewares/auth_middleware.ts)
+  - Evidência: testes passaram (resultado na conversa)
```

---

## 6. Integração com outras skills

| Skill | Como se integra |
| :--- | :--- |
| `-discovery` | Recebe os débitos e lacunas já confirmados pelo usuário. Origem `discovery`, prioridade P3 por padrão (maior se houver risco claro), com deduplicação |
| `-spec` | **Importar**: cada `T-NN` do plano da spec vira uma tarefa com ID global e origem `spec <id> / T-NN`, mantendo ordem e dependências. Aponte para a spec com link relativo em vez de copiar o conteúdo. Ao concluir as tarefas de uma spec, sugira ao usuário atualizar a rastreabilidade (coluna "Teste") e o status da spec; a edição da spec é da skill `-spec` |
| `-testing` | A evidência de testes vem de lá; os critérios de aceite da spec alimentam o DoD |
| `-git` | O ID da tarefa vai na branch e no rodapé `Refs:` do commit |
| Demais skills (`-code-review`, `-refactor`, `-debug`, `-security`, `-devops`, `-sql`, `-observability`, `-api-design`, `-system-design`, `-adr`, `-ai-engineering`, `-design-system`, `-tech-*`) | Chamam o modo **Importar** com a origem própria e a prioridade P0 a P3 que definem; o `-tasks` deduplica e atribui os IDs globais |

**Fallback**: se `-discovery` ou `-spec` não estiverem disponíveis, aceite as pendências como lista simples no chat e importe da mesma forma, com a origem informada pelo usuário.

---

## 7. Armadilhas

- **Sobrescrita cega**: gerar o arquivo do zero e perder anotações e histórico. Sempre leia antes de editar.
- **Arquivo duplicado**: criar `./TASKS.md` quando já existia outro em `.agents/`, `agents/`, `docs/` ou com nome singular.
- **Concluir sem evidência**: marcar `[x]` sem conferir arquivos e testes.
- **WIP excessivo**: acima do limite configurado, o foco se perde.
- **Tarefa monolítica ou vaga**: "refatorar backend", "ajustar testes". Toda tarefa tem escopo, referência e DoD observável.
- **ID reutilizado ou duplicado**: quebra a rastreabilidade entre spec, tarefa e commit.
- **Tarefa duplicada**: não procurar semelhantes, inclusive nas concluídas e canceladas.
- **Copiar a spec para dentro da tarefa**: gera divergência. Aponte para a spec.
- **Contador desatualizado**: recalcule a cada escrita, conforme a seção 3.4.
- **Arquivo que só cresce**: sem arquivamento, o `TASKS.md` vira ruído. Aplique a seção 3.5.

---

## 8. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado (seção 1).
2. Arquivo lido e arquivo modificado, com link relativo, e se foi criado ou atualizado.
3. Resumo das mudanças: tarefas criadas, movidas de estado, canceladas ou arquivadas, e o novo progresso.
4. Pendências descobertas que não foram registradas, e dúvidas de auditoria que dependem do usuário.
5. Quando houver tarefas ligadas a uma spec concluída, a sugestão de atualizar a rastreabilidade (seção 6).