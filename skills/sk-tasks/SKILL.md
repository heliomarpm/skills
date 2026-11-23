---
name: sk-tasks
description: "Gerencia o backlog vivo em TASKS.md: planeja, cria, decompõe, atualiza, audita contra o código, refina prontidão (DoR) e arquiva tarefas ligadas às specs. Use ao tratar de tarefas, backlog, TASKS.md ou registrar pendências. NÃO use para pedidos de código sem gestão de backlog."
allowed-tools: Read, Edit, Write, Grep, Glob
---

# Tasks: backlog vivo e rastreável em TASKS.md

Padroniza o ciclo de planejamento, decomposição, execução e arquivamento de tarefas de um projeto no arquivo `TASKS.md`, com estado confiável, evidência de conclusão e vínculo com as specs e com o discovery.

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-tasks`

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
| **Refinar** | "As tarefas estão prontas?", antes de iniciar a execução | Verifica a prontidão (seção 4.5) e propõe correções, sem alterar nada sem confirmação |
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

- Se a skill foi chamada pelo `sk-discovery` ou pelo `sk-spec`, use o diretório dos arquivos de contexto ou da spec.
- Senão, se existirem arquivos de contexto (`AGENTS.md`, `CONTEXT.md`) em `./.agents/`, `./agents/` ou `./docs/`, use esse diretório.
- Senão, use `./.agents/` ou `./agents/` se a pasta existir; caso contrário, a raiz `./`.
- **Escolha inicial de organização (única vez)**: antes de criar o primeiro `TASKS.md`, se o usuário ainda não definiu o formato nem pediu criação direta no padrão, apresente a pergunta curta com as 6 opções da seção 3.6 (modelo em [references/tasks-template.md](./references/tasks-template.md)) e informe que `## Rascunhos` entra por padrão salvo se ele preferir sem. Se o pedido exigir execução direta sem pausa ou não houver escolha, adote a opção 1 (**Prioridade simples**). Registre `Organização:` no cabeçalho para não perguntar novamente. Em arquivo existente, nunca pergunte (seção 3.1).

---

## 3. Formato do arquivo

### 3.1. Adaptação ao que existe

Se o `TASKS.md` já existe, **adapte-se ao formato dele**. Aplique o modelo desta skill somente em arquivo novo. Se o formato existente divergir muito (por exemplo, sem seções ou com marcadores próprios), pergunte antes de migrar; nunca reestruture por conta própria.

### 3.2. Estados

Use apenas os checkboxes padrão `[ ]` e `[x]`, que renderizam em qualquer visualizador. O estado é dado pela **seção** em que a tarefa está:

| Seção | Significado | Regra |
| :--- | :--- | :--- |
| Em progresso | Trabalho ativo | Limite de WIP: 2 por padrão, configurável no cabeçalho; conferir prontidão (seção 4.5) |
| Bloqueadas | Impedimento externo ou dependência | Título com **[BLOQUEADA]** e linha `Bloqueio:` com causa e ação necessária |
| Backlog | Pendente, organizada conforme o cabeçalho | Prioridade P0 a P3 em cada tarefa, agrupada pelo modelo escolhido (seção 3.6) |
| Rascunhos | Ideia embrionária sem escopo ou DoD fechado *(opcional)* | Fora da conta de progresso; sem ID `T-NNN` (bullet simples ou `R-NNN`); só entra no Backlog ao ser promovida ou descartada |
| Concluídas recentemente | Feita, com evidência | `[x]`, data, arquivos e evidência |
| Canceladas | Descartada ou substituída | Título com **[CANCELADA]** e justificativa curta |

Prioridade é uma dimensão separada do estado: **P0** crítico (segurança, produção parada), **P1** alta, **P2** média, **P3** baixa (débitos e otimizações).

### 3.3. Campos de uma tarefa

Toda tarefa tem: ID, prioridade, título, **origem** (`manual`, `bug`, `spec <id> / T-NN`, `adr ADR-NNN` ou o nome da skill sem o prefixo `sk-`, como `discovery`, `assessment`, `alignment`, `bootstrap`, `code-review`, `testing`, `refactor`, `debug`, `upgrade`, `security`, `devops`, `sql`, `observability`, `api-design`, `system-design`, `ai-engineering`, `design-system`, `readme`, `changelog` e `tech-*`), **dependências**, **referências** a arquivos e **critérios de aceite** (DoD) observáveis.

- **IDs**: `T-NNN`, globais no arquivo, alocados como o maior ID existente (incluindo concluídas, canceladas e arquivadas) mais um. Nunca reutilize um ID.
- **Links**: sempre relativos ao arquivo, com linha quando útil: `[arquivo.ts](./src/arquivo.ts#L45-L60)`. Nunca `file:///`.
- **Rascunhos e GUT**: itens em `## Rascunhos` dispensam `T-NNN`, `P0`–`P3`, links e DoD até serem promovidos para o `Backlog` (use bullet simples ou `R-NNN` com nota curta). Quando a organização for **Matriz GUT**, registre o placar curto na linha da tarefa (ex.: `GUT 60 (4×5×3)`).

### 3.4. Cabeçalho e contador

O cabeçalho traz: meta atual, organização do backlog, status geral, progresso, limite de WIP e data da última atualização.

**Progresso** = concluídas ÷ (total − canceladas), arredondado para baixo, recalculado a partir das seções a cada escrita. Itens em `## Rascunhos` e arquivos arquivados não entram na conta.

### 3.5. Tamanho e arquivamento

Mantenha o `TASKS.md` com até ~300 linhas. Em "Concluídas recentemente" e "Canceladas", mantenha as últimas 10 entradas ou 30 dias. O excedente vai para `TASKS.archive.md` no mesmo diretório (avise ao criá-lo) ou, se o usuário preferir, é resumido em uma linha de histórico com a contagem. Nunca descarte um item sem registro.

### 3.6. Organização do Backlog

Todas as opções preservam `T-NNN` e `P0`–`P3` na tarefa para manter compatibilidade com o modo **Importar** das demais skills, variando apenas o agrupamento das subseções dentro de `## Backlog`:

| Opção | Subseções no `## Backlog` | Quando usar |
| :--- | :--- | :--- |
| **1. Prioridade simples *(padrão recomendado)*** | `Alta Prioridade`, `Média Prioridade`, `Baixa Prioridade` | Menor atrito para o dia a dia |
| **2. Matriz de Eisenhower** | `Q1 · Fazer agora`, `Q2 · Agendar`, `Q3 · Delegar / Automatizar`, `Q4 · Avaliar / Eliminar` | Quando urgência compete com importância |
| **3. Ações Prioritárias (`Impacto × Esforço`)** | `Ganhos rápidos`, `Projetos estratégicos`, `Tarefas de apoio`, `Evitar / Reavaliar` | Priorizar retorno por esforço investido |
| **4. Matriz GUT (`Gravidade × Urgência × Tendência`)** | `Crítico (64–125)`, `Alto (27–63)`, `Moderado (8–26)`, `Baixo (1–7)` | Filas de bugs, incidentes e manutenção |
| **5. Now / Next / Later** | `Agora`, `Próximo`, `Depois` | Roadmaps contínuos sem prazo fixo |
| **6. MoSCoW** | `Must`, `Should`, `Could`, `Won't` | Releases ou escopo fechado com cliente |

Os modelos prontos de cada organização e o texto da pergunta inicial ficam em [references/tasks-template.md](./references/tasks-template.md).

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
2. Mova a tarefa para a seção do novo estado, mantendo a formatação existente. Ao mover para **Em progresso**, confira se a tarefa está pronta (seção 4.5); se houver lacunas, alerte o usuário e ofereça refinar antes.
3. Recalcule o contador e a data no cabeçalho.
4. Registre agora as pendências descobertas no caminho (bugs colaterais, refatorações, débitos), respeitando as regras da seção 0.

### 4.4. Evidência de conclusão

Só marque `[x]` com evidência:

- Os arquivos esperados existem ou foram alterados (confirmado com `Read` ou `Grep`).
- Os testes passaram, conforme resultado visível na conversa ou informado pelo usuário.

Sem evidência de testes, pergunte ao usuário. Se ele confirmar a conclusão sem testes, marque `[x]` e acrescente "(testes não verificados)". Registre a evidência na própria tarefa.

### 4.5. Refinamento (prontidão para construir)

No modo **Refinar**, avalie cada tarefa pendente (Backlog e Bloqueadas) contra esta lista de prontidão (*Definition of Ready*):

Itens em `## Rascunhos` ficam fora dessa auditoria até o usuário pedir para promovê-los ao `Backlog` (podendo amadurecer antes via `sk-challenge` ou `sk-spec`).

| Critério | Pronta quando |
| :--- | :--- |
| Critério de aceite | O DoD é observável e testável (não "melhorar" nem "ajustar") |
| Escopo | Cabe em uma iteração, poucos arquivos, uma responsabilidade (INVEST) |
| Referências | Há links para o arquivo, a rota ou o componente afetado |
| Dependências | Explícitas, e já concluídas ou com ordem definida |
| Origem | Se vem de uma spec, ela está `aprovada` (não `rascunho`) |
| Dúvidas | Sem `[A CONFIRMAR]` nem pergunta em aberto |
| Prioridade | P0 a P3 definida |
| Tamanho | Estimativa só se o time a usa (campo opcional) |

Entregue um relatório e **não altere nada sem confirmação**:

```text
| Tarefa | Pronta? | Lacunas                 | Correção proposta           |
| T-012  | não     | sem critério de aceite  | Propor um DoD observável    |
| T-015  | não     | grande demais           | Decompor em duas tarefas    |
| T-016  | sim     | n/d                     | n/d                         |
```

Com a confirmação, aplique as correções (acrescentar o DoD, usar o modo Decompor, ajustar a prioridade). Ao escolher a próxima tarefa a iniciar, prefira as prontas; se o usuário quiser começar uma que não está pronta, avise e ofereça refinar antes. Não exija estimativa de quem não a usa.

---

## 5. Modelo de referência

Ao criar um `TASKS.md` novo do zero ou formatar uma atualização em diff, consulte [references/tasks-template.md](./references/tasks-template.md). Em arquivos preexistentes, preserve a estrutura atual (seção 3.1).

---

## 6. Integrações

| Skill | Como se integra |
| :--- | :--- |
| `sk-discovery` | Recebe os débitos e lacunas já confirmados pelo usuário. Origem `discovery`, prioridade P3 por padrão (maior se houver risco claro), com deduplicação |
| `sk-spec` | **Importar**: cada `T-NN` do plano da spec vira uma tarefa com ID global e origem `spec <id> / T-NN`, mantendo ordem e dependências. Aponte para a spec com link relativo em vez de copiar o conteúdo. Ao concluir as tarefas de uma spec, sugira ao usuário atualizar a rastreabilidade (coluna "Teste") e o status da spec; a edição da spec é da skill `sk-spec` |
| `sk-challenge` | Dúvidas em aberto de uma tarefa podem ser resolvidas com uma sessão de questionamento antes de refiná-la |
| `sk-testing` | A evidência de testes vem de lá; os critérios de aceite da spec alimentam o DoD |
| `sk-git` | O ID da tarefa vai na branch e no rodapé `Refs:` do commit |
| Demais skills (`sk-assessment`, `sk-alignment`, `sk-bootstrap`, `sk-code-review`, `sk-refactor`, `sk-debug`, `sk-upgrade`, `sk-security`, `sk-devops`, `sk-sql`, `sk-observability`, `sk-api-design`, `sk-system-design`, `sk-adr`, `sk-ai-engineering`, `sk-design-system`, `sk-readme`, `sk-changelog`, `sk-tech-*`) | Chamam o modo **Importar** com a origem própria (sem prefixo `sk-`) e a prioridade P0 a P3 que definem; o `sk-tasks` deduplica e atribui os IDs globais |

**Fallback**: se `sk-discovery` ou `sk-spec` não estiverem disponíveis, aceite as pendências como lista simples no chat e importe da mesma forma, com a origem informada pelo usuário.

---

## 7. Armadilhas

- **Sobrescrita cega**: gerar o arquivo do zero e perder anotações e histórico. Sempre leia antes de editar.
- **Perguntar organização em `TASKS.md` já existente**: adapte-se ao formato atual (seção 3.1) e só faça a pergunta inicial ao criar o arquivo do zero.
- **Contar `## Rascunhos` no progresso ou alocar `T-NNN` antes da promoção**: rascunhos são ideias embrionárias; só recebem ID e entram no contador ao subir para o `Backlog`.
- **Arquivo duplicado**: criar `./TASKS.md` quando já existia outro em `.agents/`, `agents/`, `docs/` ou com nome singular.
- **Concluir sem evidência**: marcar `[x]` sem conferir arquivos e testes.
- **WIP excessivo**: acima do limite configurado, o foco se perde.
- **Tarefa monolítica ou vaga**: "refatorar backend", "ajustar testes". Toda tarefa tem escopo, referência e DoD observável.
- **ID reutilizado ou duplicado**: quebra a rastreabilidade entre spec, tarefa e commit.
- **Tarefa duplicada**: não procurar semelhantes, inclusive nas concluídas e canceladas.
- **Copiar a spec para dentro da tarefa**: gera divergência. Aponte para a spec.
- **Contador desatualizado**: recalcule a cada escrita, conforme a seção 3.4.
- **Arquivo que só cresce**: sem arquivamento, o `TASKS.md` vira ruído. Aplique a seção 3.5.
- **Refinar alterando sem confirmação**: o relatório de prontidão é uma proposta.
- **Exigir estimativa** de um time que não a usa.
- **Aprovar como pronta uma tarefa com critério vago.**

---

## 8. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado (seção 1).
2. Arquivo lido e arquivo modificado, com link relativo, e se foi criado ou atualizado.
3. Resumo das mudanças: tarefas criadas, movidas de estado, canceladas ou arquivadas, e o novo progresso.
4. Pendências descobertas que não foram registradas, e dúvidas de auditoria que dependem do usuário.
5. Quando houver tarefas ligadas a uma spec concluída, a sugestão de atualizar a rastreabilidade (seção 6).
6. No modo Refinar: o relatório de prontidão e as correções propostas, que dependem da sua confirmação.
