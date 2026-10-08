# Changelog

Todas as alterações notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado no [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

---

## [0.7.0] - 2026-10-08

### Adicionado
- **Nova Skill Global de Interfaces e UI/UX (`-design-system`)**:
  - Diretrizes técnicas para governança de Design Systems, arquitetura de componentes escaláveis e Design Tokens semânticos em 3 camadas.
  - Conformidade estrita com acessibilidade digital WCAG 2.2 Nível AA por padrão (WAI-ARIA, foco visível `:focus-visible`, contraste e navegação por teclado).
  - Padrão dos 7 estados essenciais de interface (*Idle, Hover, Active, Focus, Disabled, Loading/Skeletons, Empty/Error*).
  - Composição com *Compound Components*, polimorfismo (`asChild`/slots) e integração direta com os especialistas de frontend (`-tech-react`, `-tech-vue`, `-tech-angular`, `-tech-flutter`).

### Modificado
- **Padronização de Nomenclatura das Skills**: Renomeação de todas as 26 skills substituindo o prefixo `_` por `-` (ex: `-ai-engineering`, `-api-design`, `-tech-react`, etc.).
- **Simplificação e Ajuste Semântico de Nomes**:
  - `-architecture-adr` renomeada para `-arch-adr` para maior ergonomia e padrão de mercado.
  - `-refactoring` renomeada para `-refactor`, harmonizando com o tipo de Conventional Commits (`refactor:`).
  - `-tech-csharp` renomeada para `-tech-dotnet`, alinhando a nomenclatura ao ecossistema e runtime da plataforma (padrão mantido em `tech-flutter` e `tech-nodejs`).
- **Assinatura Obrigatória e Metadados**: Atualização dos campos `name` e blocos de assinatura ativa em todos os arquivos `SKILL.md`.
- **Documentação Central**: Atualização do catálogo, árvore de diretórios, contagem de skills e guias de criação no `README.md`.
- **Sincronização de Ambiente**: Propagação de todas as 26 skills renomeadas para o diretório de configuração do assistente em `~/.gemini/config/skills`.

---

## [0.6.1] - 2026-09-30

### Adicionado
- **Permissões Declarativas e Sandboxing**: Adição dos metadados `allowed-tools` e `disallowed-tools` no YAML frontmatter de todas as 25 skills para controle fino de segurança e automação inteligente.
- **Pré-Aprovação Inteligente (`allowed-tools`)**:
  - Leitura e navegação de código (`Read`, `Grep`, `Glob`) pré-aprovadas em todas as skills para eliminar pedidos redundantes de autorização.
  - Comandos não destrutivos de inspeção do Git (`git status`, `git diff`, `git log`, `git show`, `git rev-parse`, `git branch`) pré-aprovados em `_code-review`, `_git-workflow` e `_discovery`.
  - Execução de testes automatizados e builds (`npm test`, `pytest`, `go test`, `dotnet test`, `mvn test`, `gradle test`, `composer test`, etc.) pré-aprovados nas skills de refatoração (`_refactoring`), testes (`_testing`) e especialistas técnicos (`_tech-*`).
- **Blindagem e Restrições Ativas (`disallowed-tools`)**:
  - `Edit, Write` bloqueados em `_code-review` e `_security-appsec`, garantindo operação estritamente analítica e impedindo modificações acidentais no código durante revisões e auditorias.
  - `Bash` bloqueado em skills puramente conceituais, de modelagem e documentais (`_architecture-adr`, `_task-management`, `_api-design`, `_system-design`, `_core-tech`, `_database-sql`, `_observability-sre`).
  - Proteção mandatória contra comandos destrutivos: operações de alto impacto (`git push --force`, `git reset --hard`, `docker rm -f`, `terraform apply`, scripts destrutivos de banco) permanecem sem pré-aprovação, exigindo autorização humana explícita.
- **Documentação de Governança**: Nova seção no `README.md` orientando o padrão de especificação de permissões para criação de novas skills.
- **Sincronização de Ambiente**: Propagação idêntica das 25 skills atualizadas para o diretório de configuração do assistente em `~/.gemini/config/skills`.

---

## [0.6.0] - 2026-09-30

### Adicionado
- **Skill Global de Git e Releases (`_git-workflow`)**:
  - Guia técnico completo para Trunk-Based Development com branches curtas (vida útil inferior a 2 dias) e commits atômicos.
  - Diretrizes obrigatórias para mitigação de corrupção de caracteres (*Mojibake*) no Windows PowerShell (preservação estrita de UTF-8 em commits, títulos e corpos de Pull Requests).
  - Protocolos de envio de Pull Requests via GitHub API com codificação binária segura (Node.js e PowerShell com `[System.Text.Encoding]::UTF8.GetBytes`).
  - Diretrizes de Rebase Interativo linear (`git rebase origin/main`) com histórico limpo e automação de versões (Semantic Release).

---

## [0.5.0] - 2026-09-27

### Adicionado
- **5 Novas Skills Especializadas** (expandindo a toolbox para 25 skills):
  - `_ai-engineering`: Engenharia com LLMs, Tool Calling com esquemas estritos (Pydantic/Zod), RAG híbrido com chunking semântico e guardrails.
  - `_architecture-adr`: Padronização de Architecture Decision Records (ADRs) canônicos, modelagem C4 em Mermaid e relatórios de causa raiz (RCA / Post-Mortem).
  - `_observability-sre`: Instrumentação com OpenTelemetry (Traces, Metrics, Logs), contratos SLI/SLO, diagnóstico de vazamentos de memória (Heap/CPU) e graceful shutdown.
  - `_tech-golang`: Go 1.22+, concorrência estruturada com `sync.ErrGroup`, `context.Context`, structured logging com `log/slog` e roteamento nativo em `net/http`.
  - `_tech-java`: Java 21+ LTS, Virtual Threads (Project Loom), Spring Boot 3.x, Records, Pattern Matching, Sealed Classes e JPA sem problemas de N+1.

### Modificado
- Ordenação alfabética rigorosa das tabelas de catálogo de skills no `README.md` para melhor usabilidade e navegação.

---

## [0.4.0] - 2026-09-27

### Adicionado
- **Skill Estrutural de Exploração e Memória (`_discovery`)**:
  - Onboarding e exploração metódica de repositórios existentes para síntese de contexto técnico.
  - Geração padronizada de artefatos de contexto e memória para IAs (`PROJECT.md`, `CONTEXT.md`, `AGENTS.md`, `DATA.md`).
  - **Mecanismo de Ativação Restrita (🔒 Exclusivamente Explícita)**: A skill nunca é ativada por inferência implícita de contexto, exigindo instrução explícita do desenvolvedor para evitar consumo excessivo de tokens.
  - Pergunta interativa de destino para novos artefatos, permitindo ao usuário escolher entre a raiz (`./`), `./agents/` ou `./.agents/`.

---

## [0.3.0] - 2026-09-27

### Modificado
- **Padronização de Namespace com Prefixo `_`**:
  - Renomeação de todas as pastas e metadados de skills adicionando o prefixo `_` (ex: `_code-review`, `_tech-react`), eliminando conflitos de escopo com ferramentas de sistema e padronizando identificação visual.
- **Assinatura Obrigatória da Conversa**:
  - Implementação de cabeçalho obrigatório na primeira linha de resposta de qualquer skill (`> 🧠 **Skill Ativa**: _nome-da-skill`), permitindo auditar instantaneamente qual inteligência especializada está operando.
- **Consolidação Documental Centralizada**:
  - Unificação de toda a documentação dispersa (`global/README.md`, `workspace/README.md`) em um único `README.md` canônico na raiz.
  - Adição de catálogo detalhado com exemplos práticos de prompts para cada uma das habilidades catalogadas.

---

## [0.2.0] - 2026-09-27

### Adicionado
- **Skill de Gestão Dinâmica de Tarefas (`_task-management`)**:
  - Criação de skill para gerenciar, decompor e atualizar tarefas em `TASKS.md`.
  - Mecanismo de busca e localização em cascata tolerante (`./TASKS.md` → `./agents/TASKS.md` → `./.agents/TASKS.md`).
  - Integração transversal com 6 skills existentes (`_code-review`, `_security-appsec`, `_refactoring`, `_testing`, `_system-design`, `_api-design`), com pergunta ao término do relatório para registrar pendências no backlog.
  - Matriz de mapeamento de severidades técnicas para prioridades operacionais de tarefas.

### Modificado
- Reorganização estrutural de diretórios: migração dos arquivos de skills de `global/skills/` para a pasta consolidada `skills/` na raiz do repositório.

---

## [0.1.0] - 2026-08-22

### Adicionado
- **Lançamento Inicial da Toolbox de Engenharia Agêntica**:
  - 18 skills especializadas para agentes de IA:
    - **Fundações Globais**: `api-design`, `code-review`, `core-tech`, `database-sql`, `devops`, `git-workflow`, `refactoring`, `security-appsec`, `system-design`, `testing`.
    - **Especialistas por Tecnologia**: `tech-angular`, `tech-csharp`, `tech-flutter`, `tech-nodejs`, `tech-php`, `tech-python`, `tech-react`, `tech-vue`.
  - Padrão estrutural fundacional baseado nos 4 Pilares do Padrão Ouro:
    1. Processo de Execução Estruturado (Workflow).
    2. Snippets Canônicos de Referência.
    3. Armadilhas em Produção (*Gotchas*).
    4. Padrão Rigoroso de Entrega.
