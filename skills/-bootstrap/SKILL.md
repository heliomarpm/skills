---
name: -bootstrap
description: "Cria a base de um projeto novo em repositório vazio (ou quase): transforma as decisões já tomadas (stack, arquitetura, spec do MVP) em estrutura de pastas, manifesto, qualidade (linter, formatador, testes), CI mínimo, documentos de contexto iniciais e primeiro commit, sempre com plano aprovado antes de gravar. ATIVAÇÃO EXCLUSIVAMENTE EXPLÍCITA: use somente quando o usuário pedir 'inicie o projeto', 'crie a base do projeto', 'bootstrap', 'monte o esqueleto' ou 'configure um repositório novo'. NÃO use em repositório com código existente (isso é -discovery), para decidir a stack ou a arquitetura (isso é -challenge, -system-design e -adr) nem para implementar funcionalidades (isso é -spec e as -tech-*)."
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Grep, Glob, Bash(git status *), Bash(git log *), Bash(git ls-files *), Bash(git init), Bash(git branch *), Bash(git add *), Bash(git commit *), Bash(npm test *), Bash(npm run test *), Bash(npm run lint *), Bash(npm run typecheck *), Bash(npm run build *), Bash(pnpm test *), Bash(pnpm run test *), Bash(pnpm run lint *), Bash(pnpm run typecheck *), Bash(pnpm run build *), Bash(dotnet build *), Bash(dotnet test *), Bash(go build *), Bash(go test *), Bash(go vet *), Bash(pytest *), Bash(python -m pytest *), Bash(ruff *), Bash(cargo test *), Bash(flutter test *), Bash(flutter analyze *), Bash(composer test *), Bash(mvn test *), Bash(./gradlew test *)
---

# Bootstrap: da decisão ao repositório utilizável

Transforma decisões já tomadas em uma base de projeto pronta para receber código: estrutura, qualidade, testes, CI e contexto para pessoas e IAs. A skill **monta**; quem **decide** é o usuário.

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativa**: `-bootstrap`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Ativação explícita e só em repositório novo.** Use apenas em repositório vazio ou quase (por exemplo, só `README`, `LICENSE` e `.gitignore`). Se houver código, pare e sugira o `-discovery`.

**Plano antes de gravar.** Nada é criado sem a aprovação explícita do plano ("aprovado", "pode criar"). Silêncio não vale.

**As decisões não são suas.** Stack, arquitetura, banco e hospedagem vêm do usuário, dos ADRs ou da spec. Se faltarem, encaminhe para o `-challenge`, o `-system-design` e o `-adr`. Se o usuário pedir "escolha por você", registre a escolha como `(assumido)` e sugira um ADR.

**Versões.** Não fixe versões de memória. Confirme as versões estáveis ou LTS atuais na documentação oficial e registre-as no manifesto e no arquivo de versão do runtime (`.nvmrc`, `.tool-versions`, `global.json`, `go.mod`, `requires-python`).

**Execução de código de terceiros exige confirmação.** Geradores oficiais da stack (como `create-vite`, `dotnet new`, `uv init`, `flutter create`) e a instalação de dependências executam código externo: peça confirmação antes. Para estruturas simples, gere os arquivos diretamente.

**Segurança.** Nenhum segredo no repositório: `.env.example` só com nomes, e `.env` no `.gitignore`. Lockfile versionado. **Licença**: pergunte, não assuma.

**Não sobrescreva** arquivos existentes (`README`, `LICENSE`, `.gitignore`): estenda-os com o que faltar.

**Sem remoto.** Não crie repositório remoto nem faça push. Commit só com pedido, seguindo o `-git`.

**Idioma.** O do usuário; nomes de código seguem a stack.

---

## 1. Pré-requisitos

Antes do plano, confirme o que já está decidido. Se algo faltar, faça no máximo 3 perguntas ou encaminhe para a skill de decisão:

| Decisão | Exemplo |
| :--- | :--- |
| Tipo de projeto | API, aplicação web, CLI, biblioteca, aplicativo móvel |
| Stack e versão do runtime | TypeScript e Node, Go, .NET... |
| Arquitetura e estrutura | Monolito modular, camadas |
| Persistência | Banco, cache |
| Testes e CI | Runner, onde roda o pipeline |
| Contêiner e hospedagem | Só se já decidido |
| Licença e convenções | Conventional Commits, gerenciador de pacotes |

---

## 2. Workflow

1. **Verifique o repositório** (`git status`, listagem de arquivos) e **reúna as decisões** (ADRs em `docs/adr`, spec em `docs/specs`, conversa).
2. **Apresente o plano** (seção 4) e aguarde a aprovação.
3. **Gere a base** (seção 3).
4. **Valide**: com as dependências instaladas (após confirmação), rode lint, tipos, testes e build. Sem instalar, declare que a validação não foi executada.
5. **Contexto inicial**: gere `CONTEXT.md` e `AGENTS.md` a partir das decisões, no formato do `-discovery`, com o cabeçalho `> Atualizado em: <YYYY-MM-DD>`. Inclua apenas comandos que existem agora; o restante fica como `(planejado)`. `ARCHITECTURE.md` e `DATA.md` só se houver decisão correspondente.
6. **Primeiro commit**, se pedido: `chore: bootstrap do projeto` na branch principal, via `-git`.
7. **Backlog**: sugira importar o plano da spec no `-tasks` e siga para a implementação.

---

## 3. Camadas da base

Cada item só entra se couber no tipo de projeto e estiver no plano aprovado. Os detalhes de cada stack vêm da `-tech-*` correspondente.

| Camada | O que inclui |
| :--- | :--- |
| **Estrutura** | Pastas no padrão da stack (código, testes, documentação) |
| **Manifesto** | Dependências com lockfile e versão do runtime fixada |
| **Qualidade** | Linter, formatador, tipagem estrita (`-tech-typescript`), `.editorconfig` |
| **Testes** | Runner configurado e um teste de fumaça (`-testing`) |
| **CI mínimo** | Pipeline que instala, valida (lint, tipos, testes) com permissões mínimas, cache e actions fixadas por SHA (`-devops`) |
| **Contêiner** | `Dockerfile` e Compose, somente se decidido (`-devops`) |
| **Higiene** | `.gitignore`, `.gitattributes` (`* text=auto eol=lf`), `.env.example`, `LICENSE` escolhida |
| **Operação básica** | Endpoint de saúde, log estruturado e configuração validada na inicialização, conforme o tipo (`-observability`, `-security`) |
| **Documentação** | README mínimo e baseado em evidência (`-readme`), `CONTEXT.md` e `AGENTS.md` iniciais, `docs/adr/` e `docs/specs/` com o que já foi decidido |
| **Convenções** | Conventional Commits e, opcionalmente, validação de mensagens (`-git`) |

Mantenha o **mínimo viável**: nada de microsserviços, orquestração ou dez ferramentas para um MVP que ainda não tem usuários.

---

## 4. Modelo do plano

````markdown
## Plano de bootstrap

| Decisão | Valor | Origem |
| :--- | :--- | :--- |
| Tipo | API REST | spec 001 |
| Stack | TypeScript e Node (versão LTS atual) | ADR-0001 |
| Gerenciador de pacotes | pnpm | (assumido) |
| Banco | PostgreSQL | ADR-0002 |
| CI | GitHub Actions | usuário |
| Licença | MIT | usuário |

**Estrutura**
```text
src/        código da aplicação
tests/      testes
docs/       adr/ e specs/
```

**Ferramentas**: ESLint, Prettier, Vitest, `tsconfig` estrito.
**Comandos de validação**: `pnpm lint`, `pnpm typecheck`, `pnpm test`.
**Não será criado**: contêiner, infraestrutura em nuvem, autenticação.
**Executa código de terceiros**: instalação de dependências (pede confirmação).
````

---

## 5. Integrações

| Skill | Como se integra |
| :--- | :--- |
| `-challenge`, `-system-design`, `-adr` | Produzem as decisões que esta skill consome |
| `-spec` | A spec do MVP define o escopo da base e do primeiro backlog |
| `-tech-*` | Convenções, ferramentas e estrutura da stack escolhida |
| `-testing`, `-devops` | Configuração de testes e pipeline de CI |
| `-security`, `-observability` | Higiene de segredos, saúde e logs |
| `-readme`, `-git` | README inicial e primeiro commit |
| `-tasks` | Backlog a partir do plano da spec |
| `-discovery` | Para quando o projeto já tiver código |

Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 6. Armadilhas

- **Decidir a stack pelo usuário**: a escolha é dele; sem decisão, encaminhe.
- **Fixar versões de memória**: confirme as versões atuais.
- **Over-engineering**: arquitetura e ferramentas além do MVP.
- **Rodar geradores ou instalar dependências sem confirmar.**
- **Segredos em `.env` versionado.**
- **Documentos com comandos que ainda não existem**: marque como `(planejado)`.
- **Sobrescrever `README`, `LICENSE` ou `.gitignore` existentes.**
- **Ignorar a spec**: criar estrutura que não serve ao MVP definido.
- **CI que nunca foi validado**: confira ao menos a sintaxe e os comandos.
- **Commit ou push sem pedido.**

---

## 7. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o plano aprovado.
2. A árvore criada, com links relativos, e o que **não** foi criado, de propósito.
3. Resultado da validação (lint, tipos, testes, build) ou o motivo de não ter executado.
4. Itens `(assumido)` e `[A CONFIRMAR]` para o usuário revisar.
5. Próximos passos: importar o plano da spec no `-tasks` e começar a implementação. Se restaram pendências, pergunte se o usuário quer registrá-las no `TASKS.md` via `-tasks` (modo Importar, origem `bootstrap`, P1 a P3; fallback em lista no chat).