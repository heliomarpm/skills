<div id="top" align="center">
  <h1>🧠 Antigravity & Agent Skills: Engineering Toolbox <a href="https://navto.me/heliomarpm" target="_blank"><img src="https://navto.me/assets/navigatetome-brand.png" width="32"/></a></h1>

   [![Skills](https://img.shields.io/badge/Skills-27%20Specialized-blueviolet?style=for-the-badge&logo=openai)](./skills/)
   [![Environment](https://img.shields.io/badge/Environment-Antigravity%20%7C%20Gemini%20%7C%20Claude-0052CC?style=for-the-badge)](https://github.com/)
   [![Changelog](https://img.shields.io/badge/Changelog-Keep%20a%20Changelog-orange?style=for-the-badge)](./CHANGELOG.md)
   [![Maintenance](https://img.shields.io/badge/Maintained%3F-Yes-green?style=for-the-badge)](https://github.com/)
   [![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

  <div class="badges">

  [![GitHub Sponsors][url-github-sponsors-badge]][url-github-sponsors]
  [![PayPal][url-paypal-badge]][url-paypal]
  [![Ko-fi][url-kofi-badge]][url-kofi]
  [![Liberapay][url-liberapay-badge]][url-liberapay]
    
  </div>
</div>

> Repositório central para versionamento, desenvolvimento e catalogação de **Habilidades de Agente (Agent Skills)** voltadas para engenharia de software de alto nível com assistentes como **Google Antigravity**, **Gemini**, **Claude Code** e IDEs agênticas.

---

## 🛡️ Assinatura Obrigatória de Resposta

Para garantir total transparência e permitir auditar imediatamente se a skill correta foi ativada, **todas as skills deste repositório assinam obrigatoriamente a primeira linha da resposta**:

```markdown
> 🧠 **Skill Ativa**: `-nome-da-skill`
```

---

## 🏛️ Arquitetura do Repositório

Todas as 27 habilidades residem centralizadas no diretório `skills/`, padronizadas com o prefixo `-` para evitar colisões de namespace e facilitar a identificação visual:

```text
./skills/
├── -ai-engineering/        # LLMs, RAG, Function Calling, Semantic Search e Embeddings
├── -api-design/            # Contratos OpenAPI 3.1, Idempotência e Webhooks HMAC
├── -arch-adr/              # C4 Model em Mermaid, ADRs e Post-Mortems de Incidente
├── -code-review/           # Revisão Bidimensional (Spec vs Standards) em Subagentes
├── -core-tech/             # Mindset Sênior, SOLID, RFC 7807 e Observabilidade
├── -database-sql/          # Modelagem Relacional, Keyset Pagination e EXPLAIN
├── -design-system/         # Tokens Semânticos, WCAG 2.2 AA (A11y), Estados de UI e Componentes
├── -devops/                # Docker Multi-stage, CI/CD GitHub Actions e OIDC
├── -discovery/             # Onboarding, Engenharia de Contexto e Memória de IA (Explícita)
├── -git-workflow/          # Trunk-Based, Rebase Interativo e Conventional Commits
├── -observability-sre/     # OpenTelemetry, SLI/SLO, Graceful Shutdown e Debug de Heap
├── -refactor/              # Testes de Caracterização e Padrões de Refatoração
├── -sdd/                   # Spec-Driven Development, Estruturação de SPEC.md e Contratos
├── -security-appsec/       # OAuth 2.1/OIDC, Argon2id, RBAC/ABAC e OWASP
├── -system-design/         # Transactional Outbox, Mensageria e Cache
├── -task-management/       # Gestão Dinâmica, Decomposição e Atualização de TASKS.md
├── -testing/               # Pirâmide de Testes, Padrão AAA e Data Builders
├── -tech-angular/          # Angular 18/19+, Signals, Resource API e @defer
├── -tech-dotnet/           # C# 13, .NET 9, HybridCache e Lock nativo
├── -tech-flutter/          # Dart 3+, Riverpod 2.x, Isolates e RepaintBoundary
├── -tech-golang/           # Go 1.22+, Goroutines/Channels, sync.ErrGroup e log/slog
├── -tech-java/             # Java 21+ LTS, Virtual Threads/Loom, Spring Boot 3.x e JPA
├── -tech-nodejs/           # Node 20+ LTS, ESM, Streams e AbortController
├── -tech-php/              # PHP 8.4 Property Hooks, Asymmetric Visibility e PDO
├── -tech-python/           # Python 3.12/3.13, PEP 695 Generics e Pydantic v2
├── -tech-react/            # React 19, useActionState, TanStack Query e Zustand
└── -tech-vue/              # Vue 3.5 defineModel, Props Destructure e Pinia
```

---

## 📚 Catálogo de Habilidades e Exemplos de Uso

### 🌐 1. Fundações & Arquitetura Global (Agnósticas a Linguagem)

| Skill | Gatilho / Foco | Exemplo de Uso (Prompt) | Documentação |
| :--- | :--- | :--- | :---: |
| **`-ai-engineering`** | LLMs, Tool Calling estruturado, RAG híbrido, Embeddings e Evals | *"Implemente um pipeline de RAG com busca híbrida, embeddings e structured outputs validado por Pydantic."* | [`skills/-ai-engineering`](./skills/-ai-engineering/SKILL.md) |
| **`-api-design`** | Contratos OpenAPI 3.1, middleware de idempotência e Webhooks com HMAC | *"Modele o contrato OpenAPI 3.1 para a API de pagamentos com chave de idempotência e webhooks assinados."* | [`skills/-api-design`](./skills/-api-design/SKILL.md) |
| **`-arch-adr`** | Modelagem C4 em Mermaid, Architecture Decision Records (ADRs) e Post-Mortems | *"Documente a decisão de migração para mensageria com uma ADR formal e diagrama de contêineres C4."* | [`skills/-arch-adr`](./skills/-arch-adr/SKILL.md) |
| **`-code-review`** | Revisão bidimensional (especificação vs qualidade) e análise de diffs | *"Faça o code review completo do diff em relação à branch main e aponte eventuais débitos técnicos."* | [`skills/-code-review`](./skills/-code-review/SKILL.md) |
| **`-core-tech`** | SOLID, Clean Code, contratos de erro RFC 7807 e observabilidade | *"Revise a arquitetura deste serviço aplicando princípios SOLID e padronização RFC 7807 para erros."* | [`skills/-core-tech`](./skills/-core-tech/SKILL.md) |
| **`-database-sql`** | Modelagem 3NF, Keyset Pagination, análise `EXPLAIN` e concorrência ACID | *"Otimize esta query com lentidão no PostgreSQL usando Keyset Pagination e analise o plano EXPLAIN."* | [`skills/-database-sql`](./skills/-database-sql/SKILL.md) |
| **`-design-system`** | Design Tokens semânticos, WCAG 2.2 AA (A11y), estados de tela e componentização | *"Modele a arquitetura de Design Tokens semânticos com suporte a Dark Mode e componente de botão acessível."* | [`skills/-design-system`](./skills/-design-system/SKILL.md) |
| **`-devops`** | Imagens Docker multi-stage sem root, GitHub Actions, CI/CD e OIDC | *"Crie um Dockerfile multi-stage non-root e uma pipeline do GitHub Actions com autenticação OIDC."* | [`skills/-devops`](./skills/-devops/SKILL.md) |
| **`-discovery`** 🔒 | Exploração metódica, síntese de contexto e memória para IAs (PROJECT, AGENTS, DATA) *(Ativação Exclusivamente Explícita)* | *"Faça o discovery deste repositório e crie os arquivos de contexto e memória para os assistentes de IA."* | [`skills/-discovery`](./skills/-discovery/SKILL.md) |
| **`-git-workflow`** | Trunk-Based Development, rebase linear e Conventional Commits | *"Guie a limpeza dos últimos commits com rebase interativo linear e Conventional Commits antes do PR."* | [`skills/-git-workflow`](./skills/-git-workflow/SKILL.md) |
| **`-observability-sre`** | OpenTelemetry (Traces/Metrics/Logs), SLIs/SLOs, mitigação de memory leaks | *"Configure instrumentação OpenTelemetry e colete métricas RED para diagnosticar picos de latência."* | [`skills/-observability-sre`](./skills/-observability-sre/SKILL.md) |
| **`-refactor`** | Regra dos dois chapéus, testes de caracterização prévios e transformações | *"Refatore este módulo legado com segurança, criando testes de caracterização antes de alterar a estrutura."* | [`skills/-refactor`](./skills/-refactor/SKILL.md) |
| **`-sdd`** | Spec-Driven Development, estruturação de SPEC.md e contratos | *"Crie a especificação da nova feature em um arquivo SPEC.md antes de iniciarmos o código."* | [`skills/-sdd`](./skills/-sdd/SKILL.md) |
| **`-security-appsec`** | OAuth 2.1, OIDC, hashing Argon2id, RBAC/ABAC e proteção contra IDOR | *"Audite a segurança deste fluxo de login, migrando para Argon2id e adicionando proteção contra IDOR."* | [`skills/-security-appsec`](./skills/-security-appsec/SKILL.md) |
| **`-system-design`** | Transactional Outbox, mensageria assíncrona, consumidores idempotentes | *"Projete uma arquitetura orientada a eventos com Transactional Outbox e consumidores idempotentes no Kafka."* | [`skills/-system-design`](./skills/-system-design/SKILL.md) |
| **`-task-management`** | Planejamento, rastreamento e atualização contínua de `TASKS.md` | *"Gere o backlog das tarefas da sprint em TASKS.md e marque como em progresso a tarefa T-002."* | [`skills/-task-management`](./skills/-task-management/SKILL.md) |
| **`-testing`** | Pirâmide de testes, determinismo, padrão AAA e builders | *"Escreva testes unitários no padrão AAA com builders para cobrir todos os cenários de borda desta regra."* | [`skills/-testing`](./skills/-testing/SKILL.md) |

### 🛠️ 2. Especialistas por Ecossistema (`-tech-*`)

| Skill | Tecnologias & Versões Alvo | Exemplo de Uso (Prompt) | Documentação |
| :--- | :--- | :--- | :---: |
| **`-tech-angular`** | Angular 18/19+, Signals, Resource API, Deferrable Views (`@defer`), OnPush | *"Desenvolva um componente com Signals, Resource API assíncrona e visualizações diferidas com @defer."* | [`skills/-tech-angular`](./skills/-tech-angular/SKILL.md) |
| **`-tech-dotnet`** | C# 13, .NET 9, `Lock` nativo, `HybridCache`, `IAsyncEnumerable`, Minimal APIs | *"Construa um endpoint em Minimal API com .NET 9 usando HybridCache e o novo tipo System.Threading.Lock."* | [`skills/-tech-dotnet`](./skills/-tech-dotnet/SKILL.md) |
| **`-tech-flutter`** | Dart 3+, Riverpod 2.x `AsyncNotifier`, `Isolate.run()`, `RepaintBoundary` | *"Estruture o gerenciamento de estado desta tela complexa com Riverpod AsyncNotifier e Isolate.run."* | [`skills/-tech-flutter`](./skills/-tech-flutter/SKILL.md) |
| **`-tech-golang`** | Go 1.22+, Goroutines/Channels, `sync.ErrGroup`, `context`, `slog`, `net/http` nativo | *"Construa um microsserviço em Go 1.22+ com roteamento nativo, graceful shutdown e concorrência estruturada."* | [`skills/-tech-golang`](./skills/-tech-golang/SKILL.md) |
| **`-tech-java`** | Java 21+ LTS, Virtual Threads (Loom), Spring Boot 3.x, Records, JPA anti-N+1 | *"Desenvolva uma API no Spring Boot 3 com Virtual Threads e consultas otimizadas no JPA sem N+1."* | [`skills/-tech-java`](./skills/-tech-java/SKILL.md) |
| **`-tech-nodejs`** | Node 20+ LTS, ESM nativo, Streams Pipeline, AbortController, Zod | *"Implemente um worker de processamento de stream em Node 20+ com AbortController e validação Zod."* | [`skills/-tech-nodejs`](./skills/-tech-nodejs/SKILL.md) |
| **`-tech-php`** | PHP 8.3/8.4, Property Hooks, Asymmetric Visibility, DTOs readonly, PDO | *"Modele uma entidade de domínio em PHP 8.4 com Property Hooks, visibilidade assimétrica e DTOs readonly."* | [`skills/-tech-php`](./skills/-tech-php/SKILL.md) |
| **`-tech-python`** | Python 3.12/3.13, PEP 695 Type Parameters, Pydantic v2, `asyncio.TaskGroup` | *"Crie uma rotina assíncrona com asyncio.TaskGroup, tipagem PEP 695 e validação com Pydantic v2."* | [`skills/-tech-python`](./skills/-tech-python/SKILL.md) |
| **`-tech-react`** | React 19 (`useActionState`, `useOptimistic`), TanStack Query v5, Zustand | *"Crie um formulário interativo no React 19 usando useActionState, useOptimistic e TanStack Query."* | [`skills/-tech-react`](./skills/-tech-react/SKILL.md) |
| **`-tech-vue`** | Vue 3.5, `defineModel()`, Reactive Props Destructure, Composables com `toValue()` | *"Implemente um componente Vue 3.5 com defineModel, desestruturação reativa de props e Pinia store."* | [`skills/-tech-vue`](./skills/-tech-vue/SKILL.md) |

---

## ⚡ Como as Skills Funcionam e Política de Ativação

O Antigravity adota o padrão de **Divulgação Progressiva (*Progressive Disclosure*)** com duas modalidades claras de ativação:

1. **Ativação Contextual Inteligente (Implícita)**:
   - A maioria das skills é ativada dinamicamente quando o próprio prompt do usuário traz indícios suficientes da tarefa (ex: ao pedir uma refatoração, testes unitários, query SQL ou desenvolvimento em React 19).
   - Não é necessário que o usuário digite o nome da skill explicitamente; as palavras-chave da intenção disparam a leitura sob demanda (*Just-in-Time*).
2. **Ativação Restrita (🔒 Exclusivamente Explícita)**:
   - Skills estruturais e de varredura ampla (como **`-discovery`**) **NUNCA são ativadas por inferência implícita**.
   - Elas exigem pedido expresso do usuário (ex: *"faça o discovery do projeto"*, *"mapeie o repositório"*), prevenindo varreduras acidentais ou desperdício de tokens em tarefas pontuais de codificação.
3. **Assinatura Obrigatória**:
   - Toda resposta gerada sob uma skill inicia assinando no topo: `> 🧠 **Skill Ativa**: -nome-da-skill`.

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

Cada skill deve ser criada sob uma pasta própria iniciada por `-` contendo obrigatoriamente um arquivo **`SKILL.md`** estruturado nos **4 Pilares do Padrão Ouro**:

```markdown
---
name: -tech-nome-da-skill
description: "Descrição concisa contendo as palavras-chave e gatilhos exatos para ativação."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(npm test *), Bash(npm run *)
disallowed-tools: Bash  # (Opcional) Bloqueia terminal em skills puramente documentais/design
---

# Título da Skill

> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧠 **Skill Ativa**: `-tech-nome-da-skill``

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

### 🔒 Gestão de Permissões e Sandboxing (`allowed-tools` / `disallowed-tools`)

Todas as skills definem pré-aprovação de ferramentas e limites de segurança no frontmatter:
- **`allowed-tools`**: Pré-aprova comandos óbvios e rotineiros (leitura de arquivos, buscas, comandos Git seguros, runners de teste), eliminando solicitações repetitivas de confirmação.
- **`disallowed-tools`**: Restringe ferramentas desnecessárias ao escopo da skill (ex: bloqueia `Edit`/`Write` em `-code-review` e `-security-appsec` para garantir modo estritamente analítico; bloqueia `Bash` em skills puramente conceituais ou documentais).

---

## 🤝 Padrão de Commits (Conventional Commits)

Utilize mensagens semânticas ao commitar melhorias ou novas skills:

| Prefixo | Exemplo |
| :--- | :--- |
| `feat(skill)` | `feat(-tech-react): adiciona regras para React 19 Actions` |
| `fix(skill)` | `fix(-database-sql): corrige exemplo de Keyset Pagination` |
| `docs` | `docs: atualiza catálogo do README com exemplos de uso` |
| `refactor` | `refactor(-core-tech): aprimora diretrizes de observabilidade` |


---

## 🤝 Contribuições & Suporte

- Quer contribuir com uma nova stack ou melhoria? Veja nosso [Guia de Contribuição](docs/CONTRIBUTING.md).
- Precisa de ajuda ou encontrou um problema? Consulte nosso [Suporte](docs/SUPPORT.md) ou abra uma [Issue](https://github.com/heliomarpm/skills/issues).
- Leia o [Código de Conduta](docs/CODE_OF_CONDUCT.md).

Obrigado a todos que já contribuíram para o projeto!

<a href="https://github.com/heliomarpm/skills/graphs/contributors" target="_blank">
<img src="https://contrib.nn.ci/api?repo=heliomarpm/skills&no_bot=true" />
</a>

###### Criado com [contrib.nn](https://contrib.nn.ci/?repo=heliomarpm/skills&no_bot=true).

Dito isso, existem várias maneiras de contribuir para este projeto, como:

⭐ Marcando o repositório com uma estrela (star) \
🐞 Relatando bugs \
💡 Sugerindo funcionalidades \
🧾 Melhorando a documentação \
📢 Compartilhando este projeto e recomendando-o aos seus amigos

---

## 📄 Licença

Distribuído sob a licença [MIT](LICENSE) © [Heliomar P. Marques](https://github.com/heliomarpm). <a href="#top">🔝</a>

Sinta-se livre para utilizar, customizar e estender estas habilidades nos seus ambientes de desenvolvimento.

----
<!-- Sponsor badges -->

[url-github-sponsors]: https://github.com/sponsors/heliomarpm
[url-github-sponsors-badge]: https://img.shields.io/badge/GitHub%20-Sponsor-1C1E26?style=for-the-badge&labelColor=1C1E26&color=db61a2
[url-kofi]: https://ko-fi.com/heliomarpm
[url-kofi-badge]: https://img.shields.io/badge/kofi-1C1E26?style=for-the-badge&labelColor=1C1E26&color=ff5f5f
[url-liberapay]: https://liberapay.com/heliomarpm
[url-liberapay-badge]: https://img.shields.io/badge/liberapay-1C1E26?style=for-the-badge&labelColor=1C1E26&color=f6c915
[url-paypal]: https://bit.ly/paypal-sponsor-heliomarpm
[url-paypal-badge]: https://img.shields.io/badge/donate%20on-paypal-1C1E26?style=for-the-badge&labelColor=1C1E26&color=0475fe