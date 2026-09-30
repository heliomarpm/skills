---
name: _discovery
description: "Explora e analisa repositórios de software existentes para gerar ou atualizar arquivos de contexto e memória para assistentes de IA (PROJECT.md, CONTEXT.md, AGENTS.md, DATA.md). ATIVAÇÃO EXCLUSIVAMENTE EXPLÍCITA: acione apenas quando o usuário solicitar explicitamente o mapeamento, onboarding, exploração ou atualização do contexto do repositório."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(git status *), Bash(git log *), Bash(git remote *), Bash(git branch *)
---

# Discovery Skill: Repository Exploration, Context Synthesis & AI Memory

Esta skill orienta a exploração metódica e a engenharia de contexto de bases de código preexistentes (brownfield ou legadas). Seu propósito central é sintetizar a arquitetura, stack, convenções e modelos de dados do repositório em arquivos markdown padronizados de memória para assistentes de IA.

> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧭 **Skill Ativa**: `_discovery``

> [!CAUTION]
> ### 🔒 Política de Ativação Restrita: Exclusivamente Explícita
> Esta skill **NUNCA deve ser executada de forma implícita ou automática** em tarefas cotidianas de codificação, refatoração ou correção de bugs.
> - **Gatilhos Válidos (Apenas Explícitos)**: Pedidos diretos como *"faça o discovery do projeto"*, *"explore este repositório e gere o contexto"*, *"crie ou atualize o CONTEXT.md / AGENTS.md / DATA.md"*, *"mapeie a arquitetura desta base de código"*.
> - **Operação Silenciosa nas Demais Tarefas**: Se o usuário fizer uma pergunta pontual de código ou pedir uma alteração comum, não execute a exploração completa do repositório.

---

## 1. Processo de Execução Estruturado (Workflow)

### 1.1. Inspeção Prévia, Preservação e Resolução de Destino

Antes de iniciar qualquer varredura ou escrita:
1. **Verificação de Documentos Existentes**: Inspecione na raiz (`./`), nas pastas de agentes (`./.agents/`, `./agents/`) e de documentação (`./docs/`) se já existem:
   - `PROJECT.md` ou `CONTEXT.md`
   - `AGENTS.md` ou `GEMINI.md`
   - `DATA.md` ou `DATABASE.md`
   - `TASKS.md` (ou legado `TASK.md`)
2. **Resolução de Destino e Pergunta Obrigatória**:
   - **Cenário A (Arquivos Encontrados)**: Preserve o local onde já se encontram. Jamais crie arquivos duplicados em outro diretório nem execute sobrescrita cega. Leia-os primeiro para preservar anotações manuais e decisões de negócio já registradas.
   - **Cenário B (Nenhum Arquivo Localizado)**: O agente **NÃO DEVE** criar arquivos em local arbitrário por presunção. **Deve obrigatoriamente perguntar ao usuário** o local de destino desejado antes de criar os arquivos:
     > *"Não identifiquei arquivos de contexto existentes no repositório. Onde você prefere que eu crie os novos artefatos de memória (`CONTEXT.md`, `AGENTS.md`, `DATA.md`)?*
     > *1. Na raiz do projeto (`./`)*
     > *2. Na pasta oculta de configuração (`./.agents/`)*
     > *3. Na pasta de agentes (`./agents/`)*
     > *4. Na pasta de documentação (`./docs/`)*
     > *(ou informe outro caminho de sua preferência)*"*

---

### 1.2. Varredura Multicamadas da Base de Código

A exploração deve ser cirúrgica e orientada a metadados para não sobrecarregar tokens desnecessariamente:

1. **Camada 1 — Identidade e Dependências (Manifestos)**:
   - Identifique a linguagem, framework principal e versões analisando arquivos raiz: `package.json`, `pom.xml`, `*.csproj`, `pyproject.toml`, `Cargo.toml`, `composer.json`, `pubspec.yaml`, `go.mod`.
   - Inspecione arquivos de containerização e orquestração: `Dockerfile`, `docker-compose.yml`, `k8s/`.
2. **Camada 2 — Comandos Operacionais**:
   - Extraia os scripts canônicos de execução definidos nos manifestos ou `Makefile`: comando de inicialização local, build de produção, execução de testes unitários e linters.
   - Inspecione variáveis de ambiente de exemplo (`.env.example`, `.env.dist`).
3. **Camada 3 — Topologia Arquitetural**:
   - Analise a estrutura de pastas para deduzir o estilo arquitetural: Clean Architecture, Arquitetura Hexagonal (Ports & Adapters), MVC, Modular Monolith ou Microsserviços.
   - Identifique os pontos de entrada (*entrypoints*): controllers/handlers HTTP, listeners de fila/mensageria, workers e rotinas CLI.
4. **Camada 4 — Modelagem de Dados & Integrações**:
   - Mapeie ferramentas de persistência: ORMs (Prisma, Entity Framework, SQLAlchemy, Eloquent), migrations (`db/migrations`, `alembic/`, `flyway/`) ou arquivos schema SQL.
   - Identifique conexões com mensageria (RabbitMQ, Kafka), cache (Redis) e APIs externas críticas.
5. **Camada 5 — Diretrizes de Engenharia e Governança**:
   - Inspecione regras de estilo e linters (`eslint`, `prettier`, `editorconfig`, regras de tipagem estrita).
   - Inspecione pipelines de CI/CD (`.github/workflows/`, `gitlab-ci.yml`).

---

### 1.3. Geração e Sincronização dos Artefatos de Memória

A skill estrutura ou atualiza os artefatos no caminho confirmado com o usuário (ou no local preexistente já adotado pelo repositório):

#### 📄 A. `CONTEXT.md` (ou `PROJECT.md`) — Visão Executiva do Projeto
- **Missão/Propósito**: Resumo de 1 a 2 parágrafos do que o software faz e seu valor de negócio.
- **Stack & Versões**: Tabela objetiva com linguagens, runtime, frameworks, banco de dados e mensageria.
- **Comandos Essenciais**: Tabela de comandos rápidos (`instalação`, `dev`, `test`, `lint`, `build`).
- **Topologia de Pastas**: Árvore concisa anotada com a responsabilidade de cada diretório principal.

#### 📄 B. `AGENTS.md` (ou `GEMINI.md`) — Regras de Ouro e Restrições para IAs
- **Convenções Obrigatórias**: Padrão de commits (Conventional Commits), convenções de nomenclatura e arquitetura.
- **O que NÃO fazer (Restrições)**: Lista de limites estritos (ex: *não rodar migrações destrutivas*, *não ignorar tipagem estrita*, *não usar bibliotecas fora da lista aprovada*).
- **Tratamento de Erros e Padrões**: Formato padronizado de erro (ex: RFC 7807) e diretrizes de logs.

#### 📄 C. `DATA.md` — Mapa de Dados e Integrações
- **Banco de Dados Principal**: Dialeto (PostgreSQL, MySQL, SQL Server, MongoDB) e ferramenta de migração.
- **Entidades Centrais**: Lista das 5 a 10 entidades principais de domínio com seus papéis e relacionamentos.
- **Sistemas Externos**: Serviços de autenticação, gateways de pagamento, filas ou APIs terceiras consumidas.

---

### 1.4. Integração Obrigatória com `_task-management` (Ao Final)

Sempre ao término da geração ou atualização do discovery, se foram identificados débitos técnicos, discrepâncias de documentação ou ausência de testes durante a exploração:

> *"Mapeamento do repositório concluído com sucesso. Identifiquei oportunidades de melhoria e débitos técnicos durante a varredura. Deseja que eu registre essas tarefas no arquivo `TASKS.md` do projeto?"*

Ao receber a confirmação, acione a skill **`_task-management`** para registrar as pendências.

---

## 2. Snippets Canônicos de Referência

### 2.1. Exemplo Canônico de `CONTEXT.md`

```markdown
# 🧭 Contexto do Projeto: Gateway de Pagamentos

> **Versão da Documentação**: 1.0.0  
> **Última Atualização**: 2026-09-27  
> **Arquitetura**: Modular Monolith / Clean Architecture  

---

## 🎯 Propósito
Serviço responsável pelo processamento de transações financeiras (PIX, Cartão de Crédito e Boleto), gestão de idempotência de cobranças e disparo de webhooks assinados com HMAC.

---

## 🛠️ Stack Tecnológica

| Componente | Tecnologia | Versão |
| :--- | :--- | :--- |
| **Runtime** | Node.js | 20+ LTS (ESM nativo) |
| **Framework Web** | Fastify | 4.x |
| **Banco de Dados** | PostgreSQL | 16 (via Prisma ORM) |
| **Cache & Filas** | Redis & BullMQ | 7.x |
| **Testes** | Vitest | 2.x |

---

## ⚡ Comandos Rápidos

```bash
npm install            # Instala dependências
npm run dev            # Inicia servidor de desenvolvimento com hot-reload
npm run test           # Executa suíte de testes unitários com Vitest
npm run lint           # Valida regras de linter com ESLint e Prettier
npm run db:migrate     # Executa migrações pendentes do Prisma
```

---

## 🏛️ Topologia de Pastas

```text
src/
├── domain/            # Entidades de negócio puras, DTOs e regras de validação
├── application/       # Casos de uso e orquestração de transações
├── infrastructure/    # Prisma repositórios, Redis clients e adapters externos
└── presentation/      # Fastify routes, controllers e schemas RFC 7807
```
```

---

### 2.2. Exemplo Canônico de `AGENTS.md`

```markdown
# 🤖 Diretrizes para Assistentes de IA (AGENTS.md)

Instruções mandatórias que qualquer agente deve obedecer ao propor código neste repositório:

1. **Tipagem Estrita**: Nenhuma utilização de `any`. Todos os tipos e contratos de API devem ser estritamente modelados.
2. **Padrão de Erro**: Retorne sempre respostas de erro formatadas sob a RFC 7807 (Problem Details).
3. **Idempotência**: Toda mutação financeira deve exigir o cabeçalho `Idempotency-Key`.
4. **Commits**: Use estritamente o padrão Conventional Commits (`feat:`, `fix:`, `refactor:`, `test:`).
5. **Restrição Crítica**: NUNCA execute comandos destrutivos no banco de dados (`drop`, `truncate` ou `delete` sem `where`).
```

---

## 3. Armadilhas Críticas em Discovery (*Gotchas*)

- ⚠️ **Sobrescrita Destrutiva de Contexto**: Substituir arquivos de documentação preexistentes sem mesclar com o conteúdo anterior, apagando notas e instruções estratégicas da equipe humana.
- ⚠️ **Geração de Documentos Prolixos/Bloated**: Copiar arquivos inteiros de código para dentro dos markdowns. O contexto deve ser **altamente sintetizado** para economizar janela de contexto dos modelos.
- ⚠️ **Alucinação de Comandos Operacionais**: Inventar comandos como `npm start` ou `python main.py` sem verificar se o script realmente existe no manifesto de dependências ou no `Makefile`.
- ⚠️ **Execução Não Solicitada**: Ativar a varredura completa da base de código em perguntas simples de programação, desperdiçando tokens e tempo de processamento.

---

## 4. Padrão Rigoroso de Entrega

Ao conduzir o discovery:
1. **Assinatura Obrigatória**: Iniciar a resposta com `> 🧭 **Skill Ativa**: _discovery`.
2. **Confirmação de Destino**: Caso nenhum artefato exista, perguntar obrigatoriamente onde criá-los antes de gravar qualquer arquivo.
3. **Transparência**: Listar claramente os arquivos criados ou atualizados com links markdown navegáveis (`[arquivo.md](file:///...)`).
4. **Resumo Executivo**: Apresentar um resumo condensado da stack e da arquitetura identificada na resposta do chat.
5. **Integração com Backlog**: Perguntar se o usuário deseja registrar os débitos ou lacunas encontradas em `TASKS.md` via `_task-management`.
