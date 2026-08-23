# 🚀 Antigravity Skills: Enterprise Engineering Toolbox

Repositório central de **Habilidades de Engenharia de Software (Skills)** para agentes de IA do **Google Antigravity**. Este conjunto padronizado eleva a atuação do agente ao nível de **Engenheiro de Software Sênior e Arquiteto de Sistemas**, combinando diretrizes universais de arquitetura com idiomatismos de ponta para os principais ecossistemas tecnológicos.

---

## 🏛️ Arquitetura do Repositório

As habilidades estão estruturadas em dois grupos com separação estrita de responsabilidades:

1. **🌐 Skills Globais (100% Agnósticas a Linguagem / Framework)**: Princípios universais de arquitetura, segurança, bancos de dados, contratos de API, sistemas distribuídos, testes, refatoração e DevOps.
2. **🛠️ Skills Especialistas de Tecnologia (`tech-*`)**: Idiomatismos, novidades sintáticas, APIs modernas e prevenção de armadilhas (*gotchas*) específicas de cada linguagem ou framework.

```
skills/
├── api-design/        # Design de APIs, Contratos OpenAPI 3.1, Idempotência e Webhooks HMAC
├── code-review/       # Revisão Bidimensional (Spec vs Standards) em Subagentes Paralelos
├── core-tech/         # Mindset Sênior, SOLID, Contratos RFC 7807, SemVer e Observabilidade
├── database-sql/      # Modelagem Relacional, Keyset Pagination, EXPLAIN e Concorrência ACID
├── devops/            # Docker Multi-Stage, Non-Root, CI/CD GitHub Actions e OIDC
├── git-workflow/      # Trunk-Based, Rebase Interativo, Conventional Commits e Releases
├── refactoring/       # Regra dos Dois Chapéus, Testes de Caracterização e Padrões GoF
├── security-appsec/   # OAuth 2.1/OIDC, Argon2id, RBAC/ABAC, Proteção contra IDOR e CSP
├── system-design/     # Transactional Outbox, Mensageria, Consumidores Idempotentes e Cache
├── testing/           # Pirâmide de Testes, Padrão AAA, Test Data Builders e waitFor
├── tech-angular/      # Angular 18/19+, Signals, Resource API, Deferrable Views e OnPush
├── tech-csharp/       # C# 13 Lock, .NET 9 HybridCache, IAsyncEnumerable e Minimal APIs
├── tech-flutter/      # Dart 3+, Riverpod 2.x AsyncNotifier, Isolates e RepaintBoundary
├── tech-nodejs/       # Node 20+ ESM, Streams Pipeline, AbortController nativo e Zod
├── tech-php/          # PHP 8.4 Property Hooks, Asymmetric Visibility, PDO e OPcache
├── tech-python/       # Python 3.12+ PEP 695 Generics, TaskGroup e Pydantic v2
├── tech-react/        # React 19 (useActionState, useOptimistic), TanStack Query e Zustand
└── tech-vue/          # Vue 3.5 defineModel, Props Destructure, Composables e Pinia
```

---

## 📋 Tabela Rápida de Referência

| Skill | Escopo | Propósito Principal |
| :--- | :--- | :--- |
| [`core-tech`](./core-tech/SKILL.md) | Global | Princípios de engenharia limpa, SOLID, contratos de erro RFC 7807 e observabilidade. |
| [`code-review`](./code-review/SKILL.md) | Global | Revisão técnica bidimensional (requisitos vs qualidade) em subagentes paralelos com diffs. |
| [`refactoring`](./refactoring/SKILL.md) | Global | Refatoração disciplinada com testes de caracterização prévios e transformações atômicas. |
| [`testing`](./testing/SKILL.md) | Global | Estratégia de testes determinísticos, padrão AAA, builders e esperas ativas. |
| [`database-sql`](./database-sql/SKILL.md) | Global | Modelagem 3NF, Keyset Pagination, análise de plano `EXPLAIN` e concorrência (`SKIP LOCKED`). |
| [`api-design`](./api-design/SKILL.md) | Global | Contratos OpenAPI 3.1, middleware de idempotência (`Idempotency-Key`) e Webhooks HMAC. |
| [`security-appsec`](./security-appsec/SKILL.md) | Global | Autenticação moderna (OAuth 2.1/OIDC), hash Argon2id, RBAC/ABAC e hardening CSP. |
| [`system-design`](./system-design/SKILL.md) | Global | Padrão *Transactional Outbox*, mensageria assíncrona, consumidores idempotentes e cache. |
| [`devops`](./devops/SKILL.md) | Global | Imagens Docker multi-stage sem root, CI/CD com concorrência e autenticação OIDC em nuvem. |
| [`git-workflow`](./git-workflow/SKILL.md) | Global | Desenvolvimento Trunk-Based, rebase interativo linear, Conventional Commits e releases. |
| [`tech-csharp`](./tech-csharp/SKILL.md) | Especialista | C# 13 & .NET 9, `Lock`, `HybridCache`, `IAsyncEnumerable` e Minimal APIs. |
| [`tech-python`](./tech-python/SKILL.md) | Especialista | Python 3.12/3.13, PEP 695 generics, Pydantic v2, `asyncio.TaskGroup` e `ParamSpec`. |
| [`tech-nodejs`](./tech-nodejs/SKILL.md) | Especialista | Node 20+ LTS, ESM nativo, Streams pipeline com `AbortController` e Fastify. |
| [`tech-php`](./tech-php/SKILL.md) | Especialista | PHP 8.3/8.4, Property Hooks, Asymmetric Visibility, DTOs imutáveis e PDO. |
| [`tech-angular`](./tech-angular/SKILL.md) | Especialista | Angular 18/19+, Signals, Resource API assíncrona, `@defer` e detecção `OnPush`. |
| [`tech-react`](./tech-react/SKILL.md) | Especialista | React 19 (`useActionState`, `useOptimistic`), TanStack Query, Zustand e Zod. |
| [`tech-vue`](./tech-vue/SKILL.md) | Especialista | Vue 3.5, `defineModel()`, Reactive Props Destructure, Composables com `toValue()` e Pinia. |
| [`tech-flutter`](./tech-flutter/SKILL.md) | Especialista | Dart 3+, Riverpod 2.x `AsyncNotifier`, `Isolate.run()` e `RepaintBoundary`. |

---

## 🏛️ Os 4 Pilares do Padrão Ouro

Cada arquivo `SKILL.md` deste repositório segue rigorosamente a estrutura de excelência:

1. **Processo de Execução Estruturado (Workflow)**: Roteiro passo a passo de raciocínio, modelagem e validação antes da entrega.
2. **Snippets Canônicos de Referência**: Código real e conciso demonstrando as práticas e novidades mais modernas da tecnologia.
3. **Catálogo de Armadilhas em Produção (*Gotchas*)**: Avisos pontuais para prevenir vazamentos de memória, deadlocks, race conditions e vulnerabilidades de segurança.
4. **Padrão Rigoroso de Entrega**: Regras claras que garantem código 100% tipado, testável, modular e sem lacunas (`TODO`s ou trechos incompletos).

---

## ⚙️ Como as Skills são Utilizadas pelo Antigravity

O sistema de customização do Antigravity utiliza o mecanismo de **Divulgação Progressiva (*Progressive Disclosure*)**:
- Na inicialização, apenas o **nome** e a **descrição** do cabeçalho YAML frontmatter de cada skill são indexados pelo modelo.
- O conteúdo completo das instruções só é carregado sob demanda no momento exato em que a tarefa exige especialização no domínio correspondente.
- Isso economiza janela de contexto e maximiza a precisão de raciocínio da IA durante sessões longas de pareamento.

---

## 📄 Licença
Distribuído sob a licença MIT. Sinta-se livre para utilizar, customizar e estender as habilidades nos seus ambientes de desenvolvimento.
