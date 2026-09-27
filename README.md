# 🧠 Antigravity & Agent Skills: Engineering Toolbox

[![Skills](https://img.shields.io/badge/Skills-19%20Specialized-blueviolet?style=for-the-badge&logo=openai)](./skills/)
[![Environment](https://img.shields.io/badge/Environment-Antigravity%20%7C%20Gemini%20%7C%20Claude-0052CC?style=for-the-badge)](https://github.com/)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-Yes-green?style=for-the-badge)](https://github.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

> Repositório central para versionamento, desenvolvimento e catalogação de **Habilidades de Agente (Agent Skills)** voltadas para engenharia de software de alto nível com assistentes como **Google Antigravity**, **Gemini**, **Claude Code** e IDEs agênticas.

---

## 🏛️ Arquitetura do Repositório

Todas as habilidades de engenharia residem centralizadas no diretório `skills/`, agrupadas em fundamentos universais e especialistas de ecossistema:

```text
skills/
├── skills/                         # Catálogo de skills ativas
│   ├── api-design/                 # Design de APIs RESTful, OpenAPI 3.1 e Idempotência
│   ├── code-review/                # Revisão de Código Bidimensional com Subagentes
│   ├── core-tech/                  # Mindset Sênior, SOLID, RFC 7807 e Observabilidade
│   ├── database-sql/               # Modelagem Relacional, Keyset Pagination e EXPLAIN
│   ├── devops/                     # Docker Multi-stage, CI/CD GitHub Actions e OIDC
│   ├── git-workflow/               # Trunk-Based, Rebase Interativo e Conventional Commits
│   ├── refactoring/                # Testes de Caracterização e Padrões de Refatoração
│   ├── security-appsec/            # OAuth 2.1/OIDC, Argon2id, RBAC/ABAC e OWASP
│   ├── system-design/              # Transactional Outbox, Mensageria e Cache
│   ├── task-management/            # Gestão, Decomposição e Atualização de TASKS.md
│   ├── testing/                    # Pirâmide de Testes, Padrão AAA e Data Builders
│   ├── tech-angular/               # Angular 18/19+, Signals, Resource API e @defer
│   ├── tech-csharp/                # C# 13, .NET 9, HybridCache e Lock nativo
│   ├── tech-flutter/               # Dart 3+, Riverpod 2.x, Isolates e RepaintBoundary
│   ├── tech-nodejs/                # Node 20+ LTS, ESM, Streams e AbortController
│   ├── tech-php/                   # PHP 8.4 Property Hooks, Asymmetric Visibility e PDO
│   ├── tech-python/                # Python 3.12/3.13, PEP 695 Generics e Pydantic v2
│   ├── tech-react/                 # React 19, useActionState, TanStack Query e Zustand
│   └── tech-vue/                   # Vue 3.5 defineModel, Props Destructure e Pinia
│
├── .gitignore                      # Regras de exclusão do Git
└── README.md                       # Documentação central e unificada do repositório
```

---

## 📚 Catálogo de Habilidades

### 🌐 1. Fundações & Arquitetura Global (Agnósticas a Linguagem)

| Skill | Gatilho / Foco | Documentação |
| :--- | :--- | :---: |
| **Core Engineering** | SOLID, Clean Code, contratos de erro RFC 7807 e observabilidade | [`skills/core-tech`](./skills/core-tech/SKILL.md) |
| **Task Management** | Planejamento, rastreamento e atualização contínua de `TASKS.md` | [`skills/task-management`](./skills/task-management/SKILL.md) |
| **Code Review** | Revisão bidimensional (especificação vs qualidade) e análise de diffs | [`skills/code-review`](./skills/code-review/SKILL.md) |
| **Refactoring** | Regra dos dois chapéus, testes de caracterização prévios e transformações | [`skills/refactoring`](./skills/refactoring/SKILL.md) |
| **Testing** | Pirâmide de testes, determinismo, padrão AAA e builders | [`skills/testing`](./skills/testing/SKILL.md) |
| **Database & SQL** | Modelagem 3NF, Keyset Pagination, análise `EXPLAIN` e concorrência ACID | [`skills/database-sql`](./skills/database-sql/SKILL.md) |
| **API Design** | Contratos OpenAPI 3.1, middleware de idempotência e Webhooks com HMAC | [`skills/api-design`](./skills/api-design/SKILL.md) |
| **Security & AppSec** | OAuth 2.1, OIDC, hashing Argon2id, RBAC/ABAC e proteção contra IDOR | [`skills/security-appsec`](./skills/security-appsec/SKILL.md) |
| **System Design** | Transactional Outbox, mensageria assíncrona, consumidores idempotentes | [`skills/system-design`](./skills/system-design/SKILL.md) |
| **DevOps** | Imagens Docker multi-stage sem root, GitHub Actions, CI/CD e OIDC | [`skills/devops`](./skills/devops/SKILL.md) |
| **Git Workflow** | Trunk-Based Development, rebase linear e Conventional Commits | [`skills/git-workflow`](./skills/git-workflow/SKILL.md) |

### 🛠️ 2. Especialistas por Ecossistema (`tech-*`)

| Skill | Tecnologias & Versões Alvo | Documentação |
| :--- | :--- | :---: |
| **Node.js** | Node 20+ LTS, ESM nativo, Streams Pipeline, AbortController, Zod | [`skills/tech-nodejs`](./skills/tech-nodejs/SKILL.md) |
| **Python** | Python 3.12/3.13, PEP 695 Type Parameters, Pydantic v2, `asyncio.TaskGroup` | [`skills/tech-python`](./skills/tech-python/SKILL.md) |
| **C# / .NET** | C# 13, .NET 9, `Lock` nativo, `HybridCache`, `IAsyncEnumerable`, Minimal APIs | [`skills/tech-csharp`](./skills/tech-csharp/SKILL.md) |
| **PHP** | PHP 8.3/8.4, Property Hooks, Asymmetric Visibility, DTOs readonly, PDO | [`skills/tech-php`](./skills/tech-php/SKILL.md) |
| **React** | React 19 (`useActionState`, `useOptimistic`), TanStack Query v5, Zustand | [`skills/tech-react`](./skills/tech-react/SKILL.md) |
| **Angular** | Angular 18/19+, Signals, Resource API, Deferrable Views (`@defer`), OnPush | [`skills/tech-angular`](./skills/tech-angular/SKILL.md) |
| **Vue** | Vue 3.5, `defineModel()`, Reactive Props Destructure, Composables com `toValue()` | [`skills/tech-vue`](./skills/tech-vue/SKILL.md) |
| **Flutter** | Dart 3+, Riverpod 2.x `AsyncNotifier`, `Isolate.run()`, `RepaintBoundary` | [`skills/tech-flutter`](./skills/tech-flutter/SKILL.md) |

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
# Criação de link simbólico para a pasta de skills
New-Item -ItemType SymbolicLink -Path "$HOME\.gemini\config\skills\skills" -Target "d:\WORKS\DEV\SKILLS\skills\skills"
```

#### No Linux / macOS:
```bash
ln -s "$(pwd)/skills" "$HOME/.gemini/config/skills/skills"
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