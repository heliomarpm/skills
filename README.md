# 🧠 Antigravity & Agent Skills: Engineering Toolbox

[![Skills](https://img.shields.io/badge/Skills-20%20Specialized-blueviolet?style=for-the-badge&logo=openai)](./skills/)
[![Environment](https://img.shields.io/badge/Environment-Antigravity%20%7C%20Gemini%20%7C%20Claude-0052CC?style=for-the-badge)](https://github.com/)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-Yes-green?style=for-the-badge)](https://github.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

> Repositório central para versionamento, desenvolvimento e catalogação de **Habilidades de Agente (Agent Skills)** voltadas para engenharia de software de alto nível com assistentes como **Google Antigravity**, **Gemini**, **Claude Code** e IDEs agênticas.

---

## 🛡️ Assinatura Obrigatória de Resposta

Para garantir total transparência e permitir auditar imediatamente se a skill correta foi ativada, **todas as skills deste repositório assinam obrigatoriamente a primeira linha da resposta**:

```markdown
> 🧭 **Skill Ativa**: `_nome-da-skill`
```

---

## 🏛️ Arquitetura do Repositório

Todas as 20 habilidades residem centralizadas no diretório `skills/`, padronizadas com o prefixo `_` para evitar colisões de namespace e facilitar a identificação visual:

```text
skills/
├── skills/
│   ├── _api-design/            # Contratos OpenAPI 3.1, Idempotência e Webhooks HMAC
│   ├── _code-review/           # Revisão Bidimensional (Spec vs Standards) em Subagentes
│   ├── _core-tech/             # Mindset Sênior, SOLID, RFC 7807 e Observabilidade
│   ├── _database-sql/          # Modelagem Relacional, Keyset Pagination e EXPLAIN
│   ├── _devops/                # Docker Multi-stage, CI/CD GitHub Actions e OIDC
│   ├── _discovery/             # Onboarding, Engenharia de Contexto e Memória de IA (Explícita)
│   ├── _git-workflow/          # Trunk-Based, Rebase Interativo e Conventional Commits
│   ├── _refactoring/           # Testes de Caracterização e Padrões de Refatoração
│   ├── _security-appsec/       # OAuth 2.1/OIDC, Argon2id, RBAC/ABAC e OWASP
│   ├── _system-design/         # Transactional Outbox, Mensageria e Cache
│   ├── _task-management/       # Gestão Dinâmica, Decomposição e Atualização de TASKS.md
│   ├── _testing/               # Pirâmide de Testes, Padrão AAA e Data Builders
│   ├── _tech-angular/          # Angular 18/19+, Signals, Resource API e @defer
│   ├── _tech-csharp/           # C# 13, .NET 9, HybridCache e Lock nativo
│   ├── _tech-flutter/          # Dart 3+, Riverpod 2.x, Isolates e RepaintBoundary
│   ├── _tech-nodejs/           # Node 20+ LTS, ESM, Streams e AbortController
│   ├── _tech-php/              # PHP 8.4 Property Hooks, Asymmetric Visibility e PDO
│   ├── _tech-python/           # Python 3.12/3.13, PEP 695 Generics e Pydantic v2
│   ├── _tech-react/            # React 19, useActionState, TanStack Query e Zustand
│   └── _tech-vue/              # Vue 3.5 defineModel, Props Destructure e Pinia
│
├── .gitignore                  # Regras de exclusão do Git
└── README.md                   # Documentação central e unificada do repositório
```

---

## 📚 Catálogo de Habilidades e Exemplos de Uso

### 🌐 1. Fundações & Arquitetura Global (Agnósticas a Linguagem)

| Skill | Gatilho / Foco | Exemplo de Uso (Prompt) | Documentação |
| :--- | :--- | :--- | :---: |
| **`_discovery`** 🔒 | Exploração metódica, síntese de contexto e memória para IAs (PROJECT, AGENTS, DATA) *(Ativação Exclusivamente Explícita)* | *"Faça o discovery deste repositório e crie os arquivos de contexto e memória para os assistentes de IA."* | [`skills/_discovery`](./skills/_discovery/SKILL.md) |
| **`_core-tech`** | SOLID, Clean Code, contratos de erro RFC 7807 e observabilidade | *"Revise a arquitetura deste serviço aplicando princípios SOLID e padronização RFC 7807 para erros."* | [`skills/_core-tech`](./skills/_core-tech/SKILL.md) |
| **`_task-management`** | Planejamento, rastreamento e atualização contínua de `TASKS.md` | *"Gere o backlog das tarefas da sprint em TASKS.md e marque como em progresso a tarefa T-002."* | [`skills/_task-management`](./skills/_task-management/SKILL.md) |
| **`_code-review`** | Revisão bidimensional (especificação vs qualidade) e análise de diffs | *"Faça o code review completo do diff em relação à branch main e aponte eventuais débitos técnicos."* | [`skills/_code-review`](./skills/_code-review/SKILL.md) |
| **`_refactoring`** | Regra dos dois chapéus, testes de caracterização prévios e transformações | *"Refatore este módulo legado com segurança, criando testes de caracterização antes de alterar a estrutura."* | [`skills/_refactoring`](./skills/_refactoring/SKILL.md) |
| **`_testing`** | Pirâmide de testes, determinismo, padrão AAA e builders | *"Escreva testes unitários no padrão AAA com builders para cobrir todos os cenários de borda desta regra."* | [`skills/_testing`](./skills/_testing/SKILL.md) |
| **`_database-sql`** | Modelagem 3NF, Keyset Pagination, análise `EXPLAIN` e concorrência ACID | *"Otimize esta query com lentidão no PostgreSQL usando Keyset Pagination e analise o plano EXPLAIN."* | [`skills/_database-sql`](./skills/_database-sql/SKILL.md) |
| **`_api-design`** | Contratos OpenAPI 3.1, middleware de idempotência e Webhooks com HMAC | *"Modele o contrato OpenAPI 3.1 para a API de pagamentos com chave de idempotência e webhooks assinados."* | [`skills/_api-design`](./skills/_api-design/SKILL.md) |
| **`_security-appsec`** | OAuth 2.1, OIDC, hashing Argon2id, RBAC/ABAC e proteção contra IDOR | *"Audite a segurança deste fluxo de login, migrando para Argon2id e adicionando proteção contra IDOR."* | [`skills/_security-appsec`](./skills/_security-appsec/SKILL.md) |
| **`_system-design`** | Transactional Outbox, mensageria assíncrona, consumidores idempotentes | *"Projete uma arquitetura orientada a eventos com Transactional Outbox e consumidores idempotentes no Kafka."* | [`skills/_system-design`](./skills/_system-design/SKILL.md) |
| **`_devops`** | Imagens Docker multi-stage sem root, GitHub Actions, CI/CD e OIDC | *"Crie um Dockerfile multi-stage non-root e uma pipeline do GitHub Actions com autenticação OIDC."* | [`skills/_devops`](./skills/_devops/SKILL.md) |
| **`_git-workflow`** | Trunk-Based Development, rebase linear e Conventional Commits | *"Guie a limpeza dos últimos commits com rebase interativo linear e Conventional Commits antes do PR."* | [`skills/_git-workflow`](./skills/_git-workflow/SKILL.md) |

### 🛠️ 2. Especialistas por Ecossistema (`_tech-*`)

| Skill | Tecnologias & Versões Alvo | Exemplo de Uso (Prompt) | Documentação |
| :--- | :--- | :--- | :---: |
| **`_tech-nodejs`** | Node 20+ LTS, ESM nativo, Streams Pipeline, AbortController, Zod | *"Implemente um worker de processamento de stream em Node 20+ com AbortController e validação Zod."* | [`skills/_tech-nodejs`](./skills/_tech-nodejs/SKILL.md) |
| **`_tech-python`** | Python 3.12/3.13, PEP 695 Type Parameters, Pydantic v2, `asyncio.TaskGroup` | *"Crie uma rotina assíncrona com asyncio.TaskGroup, tipagem PEP 695 e validação com Pydantic v2."* | [`skills/_tech-python`](./skills/_tech-python/SKILL.md) |
| **`_tech-csharp`** | C# 13, .NET 9, `Lock` nativo, `HybridCache`, `IAsyncEnumerable`, Minimal APIs | *"Construa um endpoint em Minimal API com .NET 9 usando HybridCache e o novo tipo System.Threading.Lock."* | [`skills/_tech-csharp`](./skills/_tech-csharp/SKILL.md) |
| **`_tech-php`** | PHP 8.3/8.4, Property Hooks, Asymmetric Visibility, DTOs readonly, PDO | *"Modele uma entidade de domínio em PHP 8.4 com Property Hooks, visibilidade assimétrica e DTOs readonly."* | [`skills/_tech-php`](./skills/_tech-php/SKILL.md) |
| **`_tech-react`** | React 19 (`useActionState`, `useOptimistic`), TanStack Query v5, Zustand | *"Crie um formulário interativo no React 19 usando useActionState, useOptimistic e TanStack Query."* | [`skills/_tech-react`](./skills/_tech-react/SKILL.md) |
| **`_tech-angular`** | Angular 18/19+, Signals, Resource API, Deferrable Views (`@defer`), OnPush | *"Desenvolva um componente com Signals, Resource API assíncrona e visualizações diferidas com @defer."* | [`skills/_tech-angular`](./skills/_tech-angular/SKILL.md) |
| **`_tech-vue`** | Vue 3.5, `defineModel()`, Reactive Props Destructure, Composables com `toValue()` | *"Implemente um componente Vue 3.5 com defineModel, desestruturação reativa de props e Pinia store."* | [`skills/_tech-vue`](./skills/_tech-vue/SKILL.md) |
| **`_tech-flutter`** | Dart 3+, Riverpod 2.x `AsyncNotifier`, `Isolate.run()`, `RepaintBoundary` | *"Estruture o gerenciamento de estado desta tela complexa com Riverpod AsyncNotifier e Isolate.run."* | [`skills/_tech-flutter`](./skills/_tech-flutter/SKILL.md) |

---

## ⚡ Como as Skills Funcionam e Política de Ativação

O Antigravity adota o padrão de **Divulgação Progressiva (*Progressive Disclosure*)** com duas modalidades claras de ativação:

1. **Ativação Contextual Inteligente (Implícita)**:
   - A maioria das skills é ativada dinamicamente quando o próprio prompt do usuário traz indícios suficientes da tarefa (ex: ao pedir uma refatoração, testes unitários, query SQL ou desenvolvimento em React 19).
   - Não é necessário que o usuário digite o nome da skill explicitamente; as palavras-chave da intenção disparam a leitura sob demanda (*Just-in-Time*).
2. **Ativação Restrita (🔒 Exclusivamente Explícita)**:
   - Skills estruturais e de varredura ampla (como **`_discovery`**) **NUNCA são ativadas por inferência implícita**.
   - Elas exigem pedido expresso do usuário (ex: *"faça o discovery do projeto"*, *"mapeie o repositório"*), prevenindo varreduras acidentais ou desperdício de tokens em tarefas pontuais de codificação.
3. **Assinatura Obrigatória**:
   - Toda resposta gerada sob uma skill inicia assinando no topo: `> 🧭 **Skill Ativa**: _nome-da-skill`.

---

## 🔗 Instalação e Sincronização Local

### Vinculação com o Antigravity / Gemini CLI

Para conectar este repositório ao diretório de configuração global do assistente:

#### No Windows (PowerShell):
```powershell
# Criação de link simbólico para a pasta de skills
New-Item -ItemType SymbolicLink -Path "$HOME\.gemini\config\skills\repo-skills" -Target "d:\WORKS\DEV\SKILLS\skills\skills"
```

#### No Linux / macOS:
```bash
ln -s "$(pwd)/skills" "$HOME/.gemini/config/skills/repo-skills"
```

---

## 🏗️ Padrão de Construção de Novas Skills

Cada skill deve ser criada sob uma pasta própria iniciada por `_` contendo obrigatoriamente um arquivo **`SKILL.md`** estruturado nos **4 Pilares do Padrão Ouro**:

```markdown
---
name: _tech-nome-da-skill
description: "Descrição concisa contendo as palavras-chave e gatilhos exatos para ativação."
---

# Título da Skill

> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧭 **Skill Ativa**: `_tech-nome-da-skill``

---

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
| `feat(skill)` | `feat(_tech-react): adiciona regras para React 19 Actions` |
| `fix(skill)` | `fix(_database-sql): corrige exemplo de Keyset Pagination` |
| `docs` | `docs: atualiza catálogo do README com exemplos de uso` |
| `refactor` | `refactor(_core-tech): aprimora diretrizes de observabilidade` |

---

## 📄 Licença

Distribuído sob a licença [MIT](LICENSE). Sinta-se livre para utilizar, customizar e estender estas habilidades nos seus ambientes de desenvolvimento.