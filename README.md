<div id="top" align="center">
  <h1>🧠 Antigravity & Agent Skills: Engineering Toolbox <a href="https://navto.me/heliomarpm" target="_blank"><img src="https://navto.me/assets/navigatetome-brand.png" width="32"/></a></h1>

   [![Skills](https://img.shields.io/badge/Skills-31%20Specialized-blueviolet?style=for-the-badge&logo=openai)](./skills/)
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

Todas as 31 habilidades residem centralizadas no diretório `skills/`, padronizadas com o prefixo `-` para evitar colisões de namespace e facilitar a identificação visual:

```text
./skills/
├── -adr/                   # C4 Model em Mermaid, ADRs e Post-Mortems de Incidente
├── -ai-engineering/        # LLMs, RAG, Function Calling, Semantic Search e Embeddings
├── -api-design/            # Contratos OpenAPI 3.1, Idempotência e Webhooks HMAC
├── -challenge/             # Stress-Test Intelectual, Árvore de Decisão e Entrevista Socrática
├── -changelog/             # Histórico Keep a Changelog, SemVer e Detecção de Automações
├── -code-review/           # Revisão Bidimensional (Spec vs Standards) em Subagentes
├── -debug/                 # Detecção de Causa Raiz, Testes de Regressão e Correção Mínima
├── -design-system/         # Tokens Semânticos, WCAG 2.2 AA (A11y), Estados de UI e Componentes
├── -devops/                # Docker Multi-stage, CI/CD GitHub Actions e OIDC
├── -discovery/             # Onboarding, Engenharia de Contexto e Memória de IA (Explícita)
├── -git/                   # Trunk-Based, Rebase Interativo e Conventional Commits
├── -observability/         # OpenTelemetry, SLI/SLO, Graceful Shutdown e Debug de Heap
├── -readme/                # Documentação de Entrada Baseada em Evidências e Manifestos
├── -refactor/              # Testes de Caracterização e Padrões de Refatoração
├── -security/              # OAuth 2.1/OIDC, Argon2id, RBAC/ABAC e OWASP
├── -spec/                  # Spec-Driven Development, Estruturação de SPEC.md e Contratos
├── -sql/                   # Modelagem Relacional, Keyset Pagination e EXPLAIN
├── -system-design/         # Transactional Outbox, Mensageria e Cache
├── -tasks/                 # Gestão Dinâmica, Decomposição e Atualização de TASKS.md
├── -tech-angular/          # Angular 18/19+, Signals, Resource API e @defer
├── -tech-dotnet/           # C# 13, .NET 9, HybridCache e Lock nativo
├── -tech-flutter/          # Dart 3+, Riverpod 2.x, Isolates e RepaintBoundary
├── -tech-golang/           # Go 1.22+, Goroutines/Channels, sync.ErrGroup e log/slog
├── -tech-java/             # Java 21+ LTS, Virtual Threads/Loom, Spring Boot 3.x e JPA
├── -tech-nodejs/           # Node 20+ LTS, ESM, Streams e AbortController
├── -tech-php/              # PHP 8.4 Property Hooks, Asymmetric Visibility e PDO
├── -tech-python/           # Python 3.12/3.13, PEP 695 Generics e Pydantic v2
├── -tech-react/            # React 19, useActionState, TanStack Query e Zustand
├── -tech-typescript/       # TypeScript 5.x, TSX, Generics e Type Assertions
├── -tech-vue/              # Vue 3.5 defineModel, Props Destructure e Pinia
└── -testing/               # Pirâmide de Testes, Padrão AAA e Data Builders
```

---

## 📚 Catálogo de Habilidades e Exemplos de Uso

### 1. Fluxo de trabalho

Skills com etapas, pontos de aprovação e integração entre si. Ordem típica: `-discovery`, `-challenge` (ideação e decisões), `-spec`, `-tasks`, implementação (com `-testing` e as `-tech-*`), `-code-review`, `-git`.

| Skill | Foco | Quando usar? | Exemplo de uso (prompt) |
| :--- | :--- | :--- | :--- |
| `-discovery` 🔒 | Mapear um repositório e gerar os documentos de contexto (`CONTEXT.md`, `AGENTS.md` e outros, conforme o repositório) | Ao entrar num projeto novo ou legado, ou ao atualizar o contexto. Só por pedido explícito | "Faça o discovery deste repositório e crie os arquivos de contexto para os assistentes de IA." |
| `-challenge` | Questionar um plano, decisão ou ideia em rodadas, com recomendação própria | Antes de especificar ou decidir, para testar o raciocínio. Não para esclarecer um pedido simples (isso o `-spec` já faz) | "Me questione sobre este plano de migração antes de eu escrever a spec." |
| `-spec` | Especificação testável e rastreável, aprovada antes do código | Feature nova ou mudança que altera comportamento, contrato ou dados. Não para bug simples ou ajuste trivial | "Crie a especificação da cobrança recorrente antes de iniciarmos o código." |
| `-tasks` | Backlog vivo em `TASKS.md` | Planejar, quebrar, atualizar ou auditar tarefas, e receber as pendências das outras skills | "Gere o backlog da sprint em TASKS.md e marque a T-002 como em progresso." |
| `-code-review` | Revisão em dois eixos: especificação e qualidade | Antes do merge de um PR ou diff, ou para auditar um módulo existente. Não para corrigir o código | "Faça o code review do diff em relação à main e aponte os débitos técnicos." |
| `-refactor` | Reestruturar sem mudar o comportamento | Código legado ou complexo, com rede de testes. Não para bug nem funcionalidade nova | "Refatore este módulo legado criando testes de caracterização antes de alterar a estrutura." |
| `-testing` | Estratégia e automação de testes | Escrever, auditar ou gerar testes a partir dos critérios da spec, e tratar testes instáveis | "Escreva os testes dos critérios de aceite da spec 003." |
| `-git` | Commits atômicos, PRs, histórico e conflitos | Ao commitar, abrir PR, atualizar branch, limpar histórico ou desfazer algo. Não para pipelines | "Prepare o commit e a PR desta mudança no padrão do projeto." |
| `-debug` | Causa raiz de bugs, correção mínima e teste de regressão | Erro, stack trace, comportamento inesperado, regressão ou falha só em produção ou CI | "Este endpoint retorna 500 de forma intermitente; ache a causa e corrija." |
| `-readme` 🔒	| `README.md` de um repositório, a partir de evidências, preservando o texto da equipe	| Quando o `README` não existe ou está desatualizado. Só por pedido explícito	| "Atualize o README deste repositório com a stack e os comandos atuais." |
| `-changelog` 🔒	| `CHANGELOG.md` no formato Keep a Changelog, a partir de commits e tags | Ao preparar uma release ou quando o CHANGELOG está desatualizado. Só por pedido explícito; não edita arquivo gerado por automação | "Atualize o CHANGELOG com as mudanças desde a última tag." |

> 💡 **[Guia prático com exemplo de uso do -spec (SDD)](docs/GUIA_PRATICO_SDD.md)**


## 2. Domínios e práticas

Guias consultados conforme o assunto da tarefa.

| Skill | Foco | Quando usar? | Exemplo de uso (prompt) |
| :--- | :--- | :--- | :--- |
| `-api-design` | Contratos OpenAPI 3.1, erros, idempotência, versionamento e webhooks | Criar, revisar ou evoluir contratos de API, ou checar se uma mudança quebra consumidores | "Modele o contrato da API de pagamentos com chave de idempotência e webhooks assinados." |
| `-adr` | Registro de decisões técnicas (ADR) | Decisão cara de reverter, que atravessa módulos ou que alguém vai questionar depois | "Registre a decisão de migrar para mensageria com um ADR e as alternativas descartadas." |
| `-system-design` | Arquitetura de sistemas, mensageria, resiliência, cache e diagramas C4 | Projetar ou avaliar uma arquitetura, ou decidir se e como distribuir. Não para registrar a decisão (`-adr`) | "Projete uma arquitetura orientada a eventos com Outbox e consumidores idempotentes." |
| `-sql` | Modelagem relacional, consultas, índices, transações e migrações | Modelar tabelas, otimizar consultas, criar índices, escrever migrações ou corrigir dados | "Otimize esta consulta lenta no PostgreSQL e proponha o índice, com o plano EXPLAIN." |
| `-security` | Autenticação, autorização, OWASP e segredos | Auditar ou projetar proteção de dados e acesso, ou tratar um segredo vazado | "Audite este fluxo de login e proponha as correções por severidade." |
| `-observability` | OpenTelemetry, SLOs, alertas, health checks e post-mortem | Instrumentar, definir SLOs e alertas, investigar desempenho em produção ou analisar um incidente | "Defina os SLOs da API de pagamentos e os alertas por burn rate." |
| `-devops` | Contêineres, CI/CD, OIDC, releases e Terraform | Dockerfile, Compose, pipeline, deploy, release automática ou infraestrutura como código | "Crie um Dockerfile multiestágio não root e um pipeline do GitHub Actions com OIDC." |
| `-design-system` | Tokens, acessibilidade WCAG 2.2 AA e API de componentes | Criar tokens, projetar componentes, auditar acessibilidade ou migrar valores fixos para tokens | "Modele os tokens semânticos com tema escuro e um botão acessível." |
| `-ai-engineering` | Integração com LLMs: saídas estruturadas, ferramentas, RAG e avaliações | Integrar um LLM, criar agentes ou RAG, ou medir a qualidade das respostas | "Implemente um RAG com busca híbrida, filtro de permissões e um conjunto de avaliação." |

## 3. Stacks (`-tech-*`)

Cada skill lê a versão do projeto no manifesto e aplica só o que ela suporta. Regras de tipagem em `-tech-typescript`.

| Skill | Foco | Quando usar? | Exemplo de uso (prompt) |
| :--- | :--- | :--- | :--- |
| `-tech-typescript` | `tsconfig` estrito, sem `any`, validação de fronteira | Tipar código, remover `any`, configurar o `tsconfig` ou migrar para TypeScript | "Remova os `any` deste módulo e valide a entrada com um schema." |
| `-tech-nodejs` | ESM, configuração validada, streams, encerramento gracioso | Serviços, workers, streams e ferramentas em Node.js | "Implemente um worker de compressão com streams, cancelamento e caminho confinado." |
| `-tech-react` | Componentes tipados, estado de servidor, React 19 | Componentes, hooks, formulários e dados em React | "Crie um formulário com `useActionState`, atualização otimista e TanStack Query." |
| `-tech-vue` | `script setup`, `defineModel`, composables, Pinia | Componentes, composables e estado em Vue 3 | "Implemente um composable de busca sem condição de corrida e um componente com `defineModel`." |
| `-tech-angular` | Signals, standalone, `OnPush`, `@defer` | Componentes, serviços de estado, rotas e formulários em Angular, ou migração para signals | "Crie um serviço de estado com signals e um componente de busca com `model` e `toSignal`." |
| `-tech-dotnet` | EF Core eficiente, async, Minimal APIs | APIs, serviços e acesso a dados em C# e .NET | "Construa um endpoint Minimal API com projeção no EF Core e `TypedResults`." |
| `-tech-java` | Spring Boot 3, Virtual Threads, JPA sem N+1 | APIs Spring Boot e persistência com JPA | "Desenvolva uma API Spring Boot com consultas JPA sem N+1 e projeção em record." |
| `-tech-golang` | `context`, `errgroup`, `net/http`, `slog` | Serviços HTTP, concorrência e ferramentas em Go | "Construa um serviço em Go com roteamento nativo, encerramento gracioso e `errgroup`." |
| `-tech-python` | Tipagem, Pydantic v2, `asyncio.TaskGroup` | Scripts, APIs e tarefas assíncronas em Python | "Crie uma rotina assíncrona com `TaskGroup`, tipagem moderna e validação com Pydantic." |
| `-tech-php` | `strict_types`, PDO seguro, PHP 8.4 | Aplicações web e APIs em PHP, puro ou com framework | "Modele um DTO em PHP 8.4 com property hook e um repositório PDO seguro." |
| `-tech-flutter` | Dart 3, Riverpod, camadas, renderização eficiente | Telas, estado e navegação em aplicativos Flutter | "Estruture o estado desta tela com Riverpod `AsyncNotifier` e um repositório." |

---

## ⚡ Como as Skills Funcionam e Política de Ativação

O Antigravity adota o padrão de **Divulgação Progressiva (*Progressive Disclosure*)** com duas modalidades claras de ativação:

1. **Ativação Contextual Inteligente (Implícita)**:
   - A maioria das skills é ativada dinamicamente quando o próprio prompt do usuário traz indícios suficientes da tarefa (ex: ao pedir uma refatoração, testes unitários, query SQL ou desenvolvimento em React 19).
   - Não é necessário que o usuário digite o nome da skill explicitamente; as palavras-chave da intenção disparam a leitura sob demanda (*Just-in-Time*).
2. **Ativação Restrita (🔒 Exclusivamente Explícita)**:
   - Skills estruturais e de varredura ampla (como **`-discovery`**, **`-readme`** e **`-changelog`**) **NUNCA são ativadas por inferência implícita**.
   - Elas exigem pedido expresso do usuário (ex: *"faça o discovery do projeto"*, *"atualize o README"*, *"prepare o changelog"*), prevenindo varreduras acidentais ou desperdício de tokens em tarefas pontuais de codificação.
3. **Assinatura Obrigatória**:
   - Toda resposta gerada sob uma skill inicia assinando no topo: `> 🧠 **Skill Ativa**: -nome-da-skill`.

---

## 🔗 Instalação e Sincronização Local

### Vinculação com o Antigravity / Gemini CLI

Para conectar este repositório ao diretório de configuração global do assistente:

#### No Windows (PowerShell):
```powershell
# Criação de link simbólico para a pasta de skills
New-Item -ItemType SymbolicLink -Path "$HOME\.gemini\config\skills\repo-skills" -Target "${workspaceFolder}/skills"
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

### 🔒 Gestão de Permissões (`allowed-tools`)

Cada skill declara no frontmatter o campo `allowed-tools`, que **pré-aprova** apenas o que ela usa no dia a dia, eliminando confirmações repetitivas. O campo não bloqueia as demais ferramentas: o que não está listado segue o fluxo normal de permissão do cliente e pede confirmação.

- **Pré-aprovado**: leitura, busca, edição de arquivos (nas skills que escrevem) e comandos específicos de teste, build, tipos e lint de cada stack (por exemplo `npx vitest *`, `go test *`, `dotnet build *`). Não usamos curingas amplos como `npm run *`, `npx *` ou `python *`, que executam código arbitrário.
- **Pedem confirmação** (de propósito, fora do pré-aprovado): operações que alteram o mundo ou reescrevem histórico, como `git push`, `rebase`, `reset`, merge de PR, `terraform apply`, `docker push` e publicação de release.
- **Sem `Bash`**: skills conceituais (`-tasks`, `-api-design`, `-system-design`, `-sql`, `-observability`, `-design-system`). Algumas só leem o histórico do Git (`-adr`, `-spec`).
- **Modos somente leitura, por regra da skill**: `-code-review` só lê e registra pendências via `-tasks`, com confirmação; `-security` só edita no modo Corrigir, com aprovação. É uma instrução da skill, não um bloqueio técnico.
- **Ativação explícita**: `-discovery`, `-readme` e `-changelog` usam `disable-model-invocation: true` e só rodam quando o usuário as invoca expressamente.

> Para um bloqueio técnico real, use regras de `deny` nas configurações do cliente.

---

## 🤝 Padrão de Commits (Conventional Commits)

Utilize mensagens semânticas ao commitar melhorias ou novas skills:

| Prefixo | Exemplo |
| :--- | :--- |
| `feat(skill)` | `feat(-tech-react): adiciona regras para React 19 Actions` |
| `fix(skill)` | `fix(-debug): corrige exemplo de detecção de causa raiz` |
| `docs` | `docs: atualiza catálogo do README com exemplos de uso` |
| `refactor` | `refactor(-observability): aprimora diretrizes de observabilidade` |


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