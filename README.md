# 🧠 Antigravity & Agent Skills: Engineering Toolbox

[![Skills](https://img.shields.io/badge/Skills-19%20Specialized-blueviolet?style=for-the-badge&logo=openai)](./global/skills/)
[![Environment](https://img.shields.io/badge/Environment-Antigravity%20%7C%20Gemini%20%7C%20Claude-0052CC?style=for-the-badge)](https://github.com/)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-Yes-green?style=for-the-badge)](https://github.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

> Repositório central para versionamento, desenvolvimento e catalogação de **Habilidades de Agente (Agent Skills)** voltadas para engenharia de software de alto nível com assistentes como **Google Antigravity**, **Gemini**, **Claude Code** e IDEs agênticas.

---

## 🏛️ Arquitetura do Repositório

O repositório está organizado em camadas para separar claramente as habilidades globais daquelas específicas de projetos e workspaces:

```text
skills/
├── global/                         # Habilidades globais reutilizáveis
│   ├── README.md                   # Documentação detalhada da suite global
│   └── skills/                     # Catálogo de skills ativas
│       ├── api-design/             # Design de APIs RESTful, OpenAPI 3.1 e Idempotência
│       ├── code-review/            # Revisão de Código Bidimensional com Subagentes
│       ├── core-tech/              # Mindset Sênior, SOLID, RFC 7807 e Observabilidade
│       ├── database-sql/           # Modelagem Relacional, Keyset Pagination e EXPLAIN
│       ├── devops/                 # Docker Multi-stage, CI/CD GitHub Actions e OIDC
│       ├── git-workflow/           # Trunk-Based, Rebase Interativo e Conventional Commits
│       ├── refactoring/            # Testes de Caracterização e Padrões de Refatoração
│       ├── security-appsec/        # OAuth 2.1/OIDC, Argon2id, RBAC/ABAC e OWASP
│       ├── system-design/          # Transactional Outbox, Mensageria e Cache
│       ├── task-management/        # Gestão, Decomposição e Atualização de TASKS.md
│       ├── testing/                # Pirâmide de Testes, Padrão AAA e Data Builders
│       ├── tech-angular/           # Angular 18/19+, Signals, Resource API e @defer
│       ├── tech-csharp/            # C# 13, .NET 9, HybridCache e Lock nativo
│       ├── tech-flutter/           # Dart 3+, Riverpod 2.x, Isolates e RepaintBoundary
│       ├── tech-nodejs/            # Node 20+ LTS, ESM, Streams e AbortController
│       ├── tech-php/               # PHP 8.4 Property Hooks, Asymmetric Visibility e PDO
│       ├── tech-python/            # Python 3.12/3.13, PEP 695 Generics e Pydantic v2
│       ├── tech-react/             # React 19, useActionState, TanStack Query e Zustand
│       └── tech-vue/               # Vue 3.5 defineModel, Props Destructure e Pinia
│
├── workspace/                      # Habilidades locais e específicas de projetos
│   └── README.md
│
├── .gitignore                      # Regras de exclusão do Git
└── README.md                       # Documentação principal da raiz
```

---

## 📚 Catálogo de Habilidades

### 🌐 1. Fundações & Arquitetura Global (Agnósticas a Linguagem)

| Skill | Gatilho / Foco | Documentação |
| :--- | :--- | :---: |
| **Core Engineering** | SOLID, Clean Code, contratos de erro RFC 7807 e observabilidade | [`global/skills/core-tech`](./global/skills/core-tech/SKILL.md) |
| **Task Management** | Planejamento, rastreamento e atualização contínua de `TASKS.md` | [`global/skills/task-management`](./global/skills/task-management/SKILL.md) |
| **Code Review** | Revisão bidimensional (especificação vs qualidade) e análise de diffs | [`global/skills/code-review`](./global/skills/code-review/SKILL.md) |
| **Refactoring** | Regra dos dois chapéus, testes de caracterização prévios e transformações | [`global/skills/refactoring`](./global/skills/refactoring/SKILL.md) |
| **Testing** | Pirâmide de testes, determinismo, padrão AAA e builders | [`global/skills/testing`](./global/skills/testing/SKILL.md) |
| **Database & SQL** | Modelagem 3NF, Keyset Pagination, análise `EXPLAIN` e concorrência ACID | [`global/skills/database-sql`](./global/skills/database-sql/SKILL.md) |
| **API Design** | Contratos OpenAPI 3.1, middleware de idempotência e Webhooks com HMAC | [`global/skills/api-design`](./global/skills/api-design/SKILL.md) |
| **Security & AppSec** | OAuth 2.1, OIDC, hashing Argon2id, RBAC/ABAC e proteção contra IDOR | [`global/skills/security-appsec`](./global/skills/security-appsec/SKILL.md) |
| **System Design** | Transactional Outbox, mensageria assíncrona, consumidores idempotentes | [`global/skills/system-design`](./global/skills/system-design/SKILL.md) |
| **DevOps** | Imagens Docker multi-stage sem root, GitHub Actions, CI/CD e OIDC | [`global/skills/devops`](./global/skills/devops/SKILL.md) |
| **Git Workflow** | Trunk-Based Development, rebase linear e Conventional Commits | [`global/skills/git-workflow`](./global/skills/git-workflow/SKILL.md) |

### 🛠️ 2. Especialistas por Ecossistema (`tech-*`)

| Skill | Tecnologias & Versões Alvo | Documentação |
| :--- | :--- | :---: |
| **Node.js** | Node 20+ LTS, ESM nativo, Streams Pipeline, AbortController, Zod | [`global/skills/tech-nodejs`](./global/skills/tech-nodejs/SKILL.md) |
| **Python** | Python 3.12/3.13, PEP 695 Type Parameters, Pydantic v2, `asyncio.TaskGroup` | [`global/skills/tech-python`](./global/skills/tech-python/SKILL.md) |
| **C# / .NET** | C# 13, .NET 9, `Lock` nativo, `HybridCache`, `IAsyncEnumerable`, Minimal APIs | [`global/skills/tech-csharp`](./global/skills/tech-csharp/SKILL.md) |
| **PHP** | PHP 8.3/8.4, Property Hooks, Asymmetric Visibility, DTOs readonly, PDO | [`global/skills/tech-php`](./global/skills/tech-php/SKILL.md) |
| **React** | React 19 (`useActionState`, `useOptimistic`), TanStack Query v5, Zustand | [`global/skills/tech-react`](./global/skills/tech-react/SKILL.md) |
| **Angular** | Angular 18/19+, Signals, Resource API, Deferrable Views (`@defer`), OnPush | [`global/skills/tech-angular`](./global/skills/tech-angular/SKILL.md) |
| **Vue** | Vue 3.5, `defineModel()`, Reactive Props Destructure, Composables com `toValue()` | [`global/skills/tech-vue`](./global/skills/tech-vue/SKILL.md) |
| **Flutter** | Dart 3+, Riverpod 2.x `AsyncNotifier`, `Isolate.run()`, `RepaintBoundary` | [`global/skills/tech-flutter`](./global/skills/tech-flutter/SKILL.md) |

---

## ⚡ Como as Skills Funcionam

O Antigravity adota o padrão de **Divulgação Progressiva (*Progressive Disclosure*)**:

1. **Indexação Leve**: Na inicialização do assistente, apenas o `name` e a `description` do cabeçalho YAML são lidos.
2. **Ativação Just-in-Time**: Quando uma tarefa envolve um tópico específico (ex: refatoração em React 19 ou otimização SQL), o agente lê o arquivo `SKILL.md` correspondente.
3. **Eficiência de Contexto**: Garante máxima profundidade técnica sem poluir o consumo de tokens em tarefas não relacionadas.

---

## 🔗 Instalação e Sincronização Local

### Vinculação com o Antigravity / Gemini CLI

Para conectar este repositório ao diretório de configuração do assistente:

#### No Windows (PowerShell):
```powershell
# Criação de link simbólico para a pasta global de skills
New-Item -ItemType SymbolicLink -Path "$HOME\.gemini\config\skills\global-skills" -Target "d:\WORKS\DEV\SKILLS\skills\global\skills"
```

#### No Linux / macOS:
```bash
ln -s "$(pwd)/global/skills" "$HOME/.gemini/config/skills/global-skills"
```

---

## 🏗️ Padrão de Construção de Novas Skills

Cada skill deve ser criada sob uma pasta própria contendo obrigatoriamente um arquivo **`SKILL.md`** estruturado nos **4 Pilares do Padrão Ouro**:

```markdown
---
name: tech-nome-da-skill
description: "Descrição concisa contendo as palavras-chave e gatilhos exatos para ativação."
---

# Título da Skill

## 1. Processo de Execução Estruturado (Workflow)
Etapas analíticas e de validação antes de alterar código.

## 2. Snippets Canônicos de Referência
Exemplos práticos e modernos da tecnologia.

## 3. Armadilhas em Produção (Gotchas)
Checklist de armadilhas comuns (vazamentos, deadlocks, concorrência).

## 4. Padrão Rigoroso de Entrega
Requisitos obrigatórios de entrega (tipagem, testes, sem TODOs).
```

---

## 🤝 Padrão de Commits (Conventional Commits)

Utilize mensagens semânticas ao commitar melhorias ou novas skills:

| Prefixo | Exemplo |
| :--- | :--- |
| `feat(skill)` | `feat(tech-react): adiciona regras para React 19 Actions` |
| `fix(skill)` | `fix(database-sql): corrige exemplo de Keyset Pagination` |
| `docs` | `docs: atualiza catálogo do README principal` |
| `refactor` | `refactor(core-tech): aprimora diretrizes de observabilidade` |

---

## 📄 Licença

Distribuído sob a licença [MIT](LICENSE). Sinta-se livre para utilizar, customizar e estender estas habilidades nos seus ambientes de desenvolvimento.