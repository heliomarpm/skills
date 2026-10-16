---
name: -discovery
description: "Explora repositórios existentes (brownfield/legados) e gera ou atualiza a base de documentação de contexto para assistentes de IA: CONTEXT.md e AGENTS.md sempre, e, conforme o que o repositório justificar, ARCHITECTURE.md, DATA.md, PRD.md, GUIDELINE.md, TESTING.md, OPERATIONS.md, DECISIONS.md e GLOSSARY.md. ATIVAÇÃO EXCLUSIVAMENTE EXPLÍCITA: use somente quando o usuário pedir discovery, mapeamento, onboarding, exploração do repositório ou a criação/atualização desses arquivos (ex.: 'faça o discovery do projeto', 'mapeie este repositório', 'gere o PRD.md e o ARCHITECTURE.md', 'atualize o CONTEXT.md'). Nunca acione em tarefas comuns de código, refatoração, correção de bugs ou perguntas pontuais."
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(git status *), Bash(git log *), Bash(git remote *), Bash(git branch *), Bash(git rev-parse *), Bash(git ls-files *)
---

# Discovery: exploração de repositório e memória para IAs

Orienta a exploração metódica de bases de código preexistentes e a síntese de arquitetura, stack, produto, convenções e dados em arquivos markdown enxutos, que servem de memória persistente para assistentes de IA e de onboarding para humanos.

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativa**: `-discovery`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Ativação exclusivamente explícita.** Nunca execute esta skill por conta própria durante codificação, refatoração ou correção de bugs. Gatilhos válidos são pedidos diretos como "faça o discovery", "explore o repositório e gere o contexto", "crie ou atualize o CONTEXT.md / AGENTS.md / PRD.md". Para uma pergunta pontual de código, responda normalmente, sem varredura completa.

**Evidência antes de afirmação.** Todo fato escrito nos artefatos deve ser rastreável a um arquivo do repositório. O que for dedução recebe a marca `(inferido)`; o que não puder ser deduzido recebe `[A CONFIRMAR]`. Nunca invente metas de negócio, comandos, versões ou nomes de serviços.

**Segredos.** Leia apenas `.env.example`, `.env.dist` e equivalentes. Nunca abra `.env`, `*.pem`, `*.key`, `credentials*`, `secrets*` ou arquivos de estado de IaC (`*.tfstate`). Nos artefatos, registre somente os nomes das variáveis de ambiente, jamais valores.

---

## 1. Catálogo de artefatos

Nomes padrão abaixo. Use um nome alternativo apenas se ele já existir no repositório (veja a tabela de equivalências).

| Arquivo | Papel | Gerar quando | Limite |
| :--- | :--- | :--- | :--- |
| `CONTEXT.md` | Visão executiva, stack, comandos, topologia e índice dos demais docs | Sempre | ~150 linhas |
| `AGENTS.md` | Regras e restrições obrigatórias para IAs | Sempre | ~100 linhas |
| `ARCHITECTURE.md` | Estilo arquitetural, módulos, fluxos, diagramas e riscos | Há mais de um módulo ou camada identificável | ~200 linhas |
| `DATA.md` | Banco, entidades, migrations, mensageria, cache e APIs externas | Há persistência ou integrações relevantes | ~150 linhas |
| `PRD.md` | Produto retroativo: problema, usuários, funcionalidades existentes, lacunas | README, docs, rotas ou telas permitem inferir o produto | ~150 linhas |
| `GUIDELINE.md` | Padrões de engenharia com justificativa: nomenclatura, estrutura, erros, git, PR, dependências | Há linters, configs, CI ou histórico que revelem convenções | ~120 linhas |
| `TESTING.md` | Estratégia e execução de testes, convenções e lacunas | Existem testes ou configuração de testes | ~80 linhas |
| `OPERATIONS.md` | Ambientes, variáveis, CI/CD, deploy e observabilidade | Existem Docker, IaC, pipelines ou scripts de deploy | ~120 linhas |
| `DECISIONS.md` | Índice das decisões técnicas: aponta para os ADRs (formato do `-adr`) se existirem; senão, entradas curtas nesse formato | Há ADRs ou decisões claras no histórico e na estrutura | sem limite fixo, uma entrada por decisão |
| `GLOSSARY.md` | Termos de domínio e onde aparecem no código | O domínio tem 8 ou mais termos específicos | ~80 linhas |
| `TASKS.md` | Backlog de débitos encontrados | Somente com confirmação do usuário (seção 5) | via `-tasks` |

**Diferença entre `AGENTS.md` e `GUIDELINE.md`.** `AGENTS.md` é uma lista curta de regras imperativas ("faça / não faça") voltada a IAs. `GUIDELINE.md` explica os padrões de engenharia do time e o porquê de cada um, e serve a humanos e IAs. Não duplique conteúdo: `AGENTS.md` aponta para `GUIDELINE.md` quando a regra exigir contexto.

**Equivalências de nome já existentes**

| Padrão | Aceitos se já existirem |
| :--- | :--- |
| `CONTEXT.md` | `PROJECT.md` |
| `AGENTS.md` | `GEMINI.md`, `CLAUDE.md` |
| `DATA.md` | `DATABASE.md` |
| `GUIDELINE.md` | `GUIDELINES.md`, `CONTRIBUTING.md` (apenas leitura e complemento, nunca sobrescrita) |
| `TASKS.md` | `TASK.md` |

**Modo parcial.** Se o usuário pedir arquivos específicos ("gere só o PRD.md e o ARCHITECTURE.md"), gere apenas esses, mas execute a varredura necessária para eles.

---

## 2. Workflow

### 2.1. Inspeção prévia e resolução de destino

Procure, na raiz (`./`), em `./.agents/`, `./agents/` e `./docs/`, qualquer arquivo do catálogo ou de suas equivalências. Leia tudo que existir antes de qualquer escrita.

- **Cenário A (todos os alvos existem)**: atualize no local, sem criar duplicatas em outro diretório.
- **Cenário B (nenhum existe)**: pergunte o destino antes de criar qualquer arquivo (texto na seção 2.3).
- **Cenário C (parcial)**: atualize os existentes no lugar e crie os faltantes **no mesmo diretório** dos existentes, sem perguntar o destino.
- **Execução não interativa** (sem como perguntar): use a raiz do projeto como destino padrão e registre essa escolha no resumo final.

### 2.2. Varredura em camadas

Seja cirúrgico e guiado por metadados. Não leia arquivos de código inteiros sem necessidade.

1. **Identidade e dependências**: `package.json`, `pom.xml`, `*.csproj`, `pyproject.toml`, `Cargo.toml`, `composer.json`, `pubspec.yaml`, `go.mod`; `Dockerfile`, `docker-compose.yml`, `k8s/`. Em monorepos, `workspaces`, `pnpm-workspace.yaml`, `turbo.json`, `nx.json`, `*.sln`.
2. **Comandos operacionais**: scripts dos manifestos, `Makefile`, `justfile`, workflows de CI e `.env.example`. Para cada comando, registre de onde ele veio.
3. **Topologia arquitetural**: use `git ls-files` e `Glob` para mapear pastas; deduza o estilo (Clean Architecture, Hexagonal, MVC, Monolito Modular, Microsserviços) e localize entrypoints (controllers, handlers, listeners, workers, CLI).
4. **Dados e integrações**: ORMs (Prisma, Entity Framework, SQLAlchemy, Eloquent), migrations, schemas SQL, filas, cache e APIs externas críticas.
5. **Engenharia e governança**: linters e formatadores (`eslint`, `prettier`, `.editorconfig`, analyzers), tipagem estrita, pipelines (`.github/workflows/`, `.gitlab-ci.yml`), templates de PR e issue.
6. **Produto e domínio**: `README`, `docs/`, rotas, telas, nomes de entidades, CHANGELOG, ADRs existentes. Fonte principal do `PRD.md`, do `GLOSSARY.md` e do `DECISIONS.md`.
7. **Histórico git** (somente leitura): `git log` para detectar o padrão real de commits (Conventional Commits ou não), áreas mais ativas e tempo desde a última mudança; `git remote` para o link do repositório.

**Monorepos.** Gere os arquivos globais na raiz. Para pacotes com stack ou regras próprias, gere um `AGENTS.md` curto (até ~60 linhas) dentro do pacote, que herda o da raiz. Liste os pacotes na tabela de topologia do `CONTEXT.md`.

### 2.3. Plano de entrega e confirmação

Antes de gravar qualquer arquivo, apresente em **uma única mensagem**: o que foi detectado (stack e estilo em uma linha), os arquivos que pretende criar ou atualizar (com o motivo de cada um e dos que foram descartados), o destino e o idioma. Pergunte uma vez:

> *"Posso seguir com este plano? Se não houver arquivos de contexto no repositório, onde prefere criá-los?*  
> *1. Na raiz do projeto (`./`)*  
> *2. Na pasta oculta de configuração (`./.agents/`)*  
> *3. Na pasta de agentes (`./agents/`)*  
> *4. Na pasta de documentação (`./docs/`)*  
> *(ou informe outro caminho de sua preferência)."*

Pule a pergunta de destino nos cenários A e C. Pule o plano inteiro se o usuário já especificou os arquivos e o destino no pedido ou se a execução for não interativa.

### 2.4. Geração e sincronização

Gere ou atualize os arquivos conforme as regras da seção 3 e os modelos da seção 4. Valide cada comando antes de incluí-lo (seção 3.3).

### 2.5. Fechamento

Apresente o resumo conforme a seção 6. Se houver débitos ou lacunas identificados, siga a seção 5.

---

## 3. Regras de escrita

### 3.1. Preservação e merge

- Texto escrito por humanos é sagrado. Nunca apague nem reescreva seções ou notas existentes sem aprovação.
- **Seções da equipe**: qualquer seção cujo título a skill não gera, e em particular `## Notas da Equipe`, é da equipe e nunca é alterada. Em atualizações, a skill modifica apenas as seções que ela mesma gera (identificadas pelos títulos dos modelos, como `## Stack` e `## Comandos`).
- Arquivo preexistente: não reescreva do zero. Adicione ou atualize as seções necessárias, preserve o restante intacto e, se houver contradição entre o texto existente e o código, não resolva sozinho: registre como "Conflito" no resumo final.
- Ao atualizar, verifique o que mudou no código e no histórico git recente e atualize as seções correspondentes.

### 3.2. Concisão

- Respeite os limites do catálogo. Prefira tabelas e listas curtas a prosa.
- Nunca cole código-fonte inteiro nos documentos. Cite caminhos e nomes de símbolos.
- Prefira ponteiros ("detalhes em [ARCHITECTURE.md](./ARCHITECTURE.md)") a repetir conteúdo entre arquivos. `CONTEXT.md` mantém um índice de todos os demais.
- Sem emojis nos arquivos gerados. Links sempre relativos, como `[DATA.md](./DATA.md)`, nunca `file:///`.

### 3.3. Verificação de comandos

Só inclua um comando se ele for rastreável a um manifesto, `Makefile`, `justfile` ou workflow. Cite a origem na tabela. Se não for possível comprovar, marque como `não verificado`. Nunca presuma `npm start`, `python main.py` ou equivalentes.

### 3.4. Idioma

Escreva os artefatos no idioma já usado nos documentos existentes do repositório. Sem documentos, use o idioma do README; se também não houver, use o idioma do pedido do usuário. Mantenha termos técnicos, nomes de comandos e de código em seu idioma original.

### 3.5. Estrutura obrigatória de todo arquivo gerado

Todo arquivo começa com o título e a data de atualização, e termina com a seção `## Notas da Equipe`, com o texto fixo abaixo (criada vazia e nunca alterada em atualizações):

```
> Atualizado em: <YYYY-MM-DD>

...

## Notas da Equipe
*(Espaço reservado para anotações manuais da equipe. A skill não altera esta seção.)*
```

---

## 4. Modelos de referência

Os modelos mostram estrutura e nível de detalhe. Os valores são ilustrativos. Em cada arquivo real, mantenha somente o que o repositório sustenta.

### 4.1. `CONTEXT.md`

````markdown
# Contexto do Projeto: Gateway de Pagamentos

> Atualizado em: 2026-10-11

## Propósito
Serviço de processamento de transações (PIX, cartão, boleto), com idempotência de cobranças e webhooks assinados com HMAC.

## Stack

| Componente | Tecnologia | Versão | Origem |
| :--- | :--- | :--- | :--- |
| Runtime | Node.js | <versão> | `package.json` (engines) |
| Web | Fastify | <versão> | `package.json` |
| Banco | PostgreSQL via Prisma | <versão> | `docker-compose.yml` |
| Testes | Vitest | <versão> | `package.json` |

## Comandos

| Ação | Comando | Origem |
| :--- | :--- | :--- |
| Instalar | `npm install` | `package.json` |
| Dev | `npm run dev` | `package.json` (scripts) |
| Testes | `npm run test` | `package.json` (scripts) |
| Migrar | `npm run db:migrate` | `package.json` (scripts) |
| Deploy | não verificado | n/d |

## Topologia de pastas

```text
src/
├── domain/          # Entidades e regras puras
├── application/     # Casos de uso
├── infrastructure/  # Repositórios, clientes externos
└── presentation/    # Rotas e controllers
```

## Índice da documentação

| Documento | Conteúdo |
| :--- | :--- |
| [AGENTS.md](./AGENTS.md) | Regras para IAs |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Módulos e fluxos |
| [DATA.md](./DATA.md) | Dados e integrações |

## Notas da Equipe
*(Espaço reservado para anotações manuais da equipe. A skill não altera esta seção.)*
````

### 4.2. `AGENTS.md`

````markdown
# Diretrizes para Assistentes de IA

> Atualizado em: 2026-10-11

## Regras obrigatórias
1. Tipagem estrita: não use `any`; modele contratos de API. (Origem: `tsconfig.json`, `strict: true`)
2. Erros no formato Problem Details (RFC 9457). (Origem: `src/presentation/errors`)
3. Commits no padrão Conventional Commits. (Origem: histórico git e `commitlint.config.js`)
4. Mutações financeiras exigem o cabeçalho `Idempotency-Key`.

## Restrições (o que não fazer)
- Não execute comandos destrutivos no banco (`drop`, `truncate`, `delete` sem `where`).
- Não adicione dependências fora do fluxo descrito em [GUIDELINE.md](./GUIDELINE.md).
- Não leia nem exponha `.env`; use `.env.example` como referência.

## Skills aplicáveis
Stack detectada: TypeScript, Node.js e PostgreSQL. Use `-tech-typescript`, `-tech-nodejs`, `-sql`, `-api-design` e `-testing`.

## Decisões críticas
- [ADR-005](./docs/adr/ADR-005.md): Transactional Outbox para eventos financeiros.

## Antes de concluir uma tarefa
Rodar lint e testes (comandos em [CONTEXT.md](./CONTEXT.md)).

## Notas da Equipe
*(Espaço reservado para anotações manuais da equipe. A skill não altera esta seção.)*
````

As seções **Skills aplicáveis** e **Decisões críticas** são opcionais: a primeira mapeia a stack detectada às skills que existirem no ambiente (liste só essas); a segunda linka os ADRs aceitos que restringem o código.

### 4.3. Artefatos condicionais

Para cada artefato aprovado no plano de entrega, siga o cabeçalho e o rodapé da seção 3.5 e inclua, no mínimo:

- **`ARCHITECTURE.md`**: estilo arquitetural e justificativa observável; diagrama de componentes em Mermaid (um só, enxuto); fluxo da requisição ou do caso de uso principal; tabela de módulos com responsabilidade e dependências; pontos de extensão; riscos arquiteturais observados. Para C4 completo ou decisões de desenho, aponte o `-system-design`.
- **`DATA.md`**: banco e ferramenta de migração; 5 a 10 entidades centrais com papel e relacionamentos; mensageria e cache; sistemas externos (autenticação, pagamentos, APIs terceiras) com onde são chamados.
- **`PRD.md`** (retroativo): problema e proposta de valor `(inferido)`; usuários e personas (`(inferido)` ou `[A CONFIRMAR]`); funcionalidades existentes derivadas de rotas, telas e comandos, cada uma com status (implementada, parcial, não verificada) e o arquivo de origem; fora de escopo observado; métricas de sucesso (`[A CONFIRMAR]` salvo se documentadas); perguntas abertas. Nunca invente objetivos de negócio.
- **`GUIDELINE.md`**: nomenclatura; organização de código; tratamento de erros e logs; git (commits, branches, PR, revisão); estilo e linters; política para adicionar dependências. Cada padrão tem uma linha de justificativa e a origem (arquivo de configuração ou histórico).
- **`TESTING.md`**: frameworks; como rodar (comando e origem); estrutura e convenções de nomes; tipos de teste presentes; cobertura se mensurável; lacunas.
- **`OPERATIONS.md`**: ambientes; variáveis de ambiente (apenas nomes, com descrição); jobs de CI/CD e o que cada um faz; processo de deploy; observabilidade e logs; Docker e IaC relevantes.
- **`DECISIONS.md`**: se existe uma pasta de ADRs, vira apenas um índice (link, título e status de cada ADR), sem duplicar conteúdo; sem a pasta, uma entrada por decisão no formato do `-adr` (ID, contexto, decisão, consequências e origem: histórico git ou `(inferido)`). ADRs retroativos completos são criados pelo `-adr`, não por esta skill.
- **`GLOSSARY.md`**: termo, definição curta, onde aparece no código.

---

## 5. Integração com `-tasks` (ao final)

Se a varredura encontrou débitos técnicos, documentação divergente do código, ausência de testes ou lacunas marcadas `[A CONFIRMAR]`, pergunte:

> *"Mapeamento concluído. Identifiquei débitos e lacunas durante a varredura. Deseja que eu os registre no `TASKS.md` do projeto?"*

Com a confirmação, acione a skill `-tasks`. **Fallback**: se `-tasks` não estiver disponível, crie ou atualize o `TASKS.md` diretamente, com uma lista de itens (título, motivo, arquivo de origem), ou apresente a lista no chat se o usuário preferir. Não registre nada sem confirmação.

---

## 6. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0).
2. Plano e confirmação antes de gravar (seção 2.3), quando aplicável.
3. Lista dos arquivos criados e atualizados, com links relativos (`[CONTEXT.md](./CONTEXT.md)`) e uma marca de "criado" ou "atualizado".
4. Resumo executivo de 5 a 8 linhas: stack, arquitetura, estilo de commits e estado dos testes.
5. Pendências: itens `[A CONFIRMAR]`, comandos `não verificado` e conflitos encontrados com conteúdo humano.
6. Pergunta sobre o registro em `TASKS.md` (seção 5).

---

## 7. Armadilhas

- **Sobrescrita destrutiva**: reescrever documentos existentes e apagar notas da equipe. Respeite a seção 3.1.
- **Documentos inchados**: copiar código para dentro dos markdowns ou repetir o mesmo conteúdo em vários arquivos. Respeite os limites e use ponteiros.
- **Alucinação operacional**: inventar comandos, versões ou serviços. Aplique a seção 3.3 e use `[A CONFIRMAR]`.
- **PRD ficcional**: apresentar inferências como requisitos oficiais. Marque tudo que não vier de documentação.
- **Vazamento de segredos**: ler `.env` ou copiar valores sensíveis. Registre apenas nomes de variáveis.
- **Geração em excesso**: criar todos os arquivos do catálogo mesmo sem evidência. Gere somente o que o repositório justifica e informe o que foi descartado.
- **Execução não solicitada**: ativar a varredura em perguntas simples de programação.