---
name: -changelog
description: "Cria ou atualiza o CHANGELOG.md no formato Keep a Changelog com Versionamento Semântico, a partir dos commits e tags do repositório: agrupa por tipo, ignora ruído, propõe a próxima versão, preserva as entradas já publicadas e detecta quando uma automação de releases já gera o arquivo. ATIVAÇÃO EXCLUSIVAMENTE EXPLÍCITA: use somente quando o usuário pedir 'atualize o changelog', 'documente a release', 'prepare o CHANGELOG da versão X' ou 'o CHANGELOG está desatualizado'. NÃO use para o README (isso é -readme) nem para publicar tags e releases (isso é -git e -devops)."
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(git log *), Bash(git describe *), Bash(git tag -l *), Bash(git tag --list *), Bash(git rev-list *), Bash(git remote *), Bash(git diff *), Bash(git show *), Bash(git status *), Bash(npx markdownlint-cli *)
---

# Changelog: histórico de mudanças para quem usa o projeto

Gera ou atualiza o `CHANGELOG.md` seguindo o [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o [Versionamento Semântico](https://semver.org/lang/pt-BR/). O público é quem usa ou integra o projeto, não quem leu os commits.

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativa**: `-changelog`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Ativação explícita.** Nunca execute por conta própria durante outras tarefas.

**Automação existente.** Se o projeto usa semantic-release, release-please, changesets ou standard-version (configuração, `.releaserc*`, `.changeset/`, workflow de release), o arquivo é gerado pela ferramenta: **não o edite à mão**. Explique e, se o usuário quiser, ajuste a configuração via `-devops`.

**Não reescreva o histórico publicado.** Altere apenas `[Unreleased]` e a nova versão; entradas de versões já lançadas permanecem como estão.

**Não invente.** Versão e data são propostas e confirmadas pelo usuário; links de comparação vêm do `git remote`. Todo item é rastreável a commits.

**Git.** Não crie tags nem releases, não commite e não abra PR sem pedido. Se o usuário pedir, siga o `-git` e o `-devops`.

**Idioma.** O do CHANGELOG existente; sem ele, o do repositório. Títulos de seção: os do arquivo existente; em arquivo novo, os padrões do Keep a Changelog (`Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`).

---

## 1. Modos de operação

| Modo | Quando |
| :--- | :--- |
| **Criar** | O projeto não tem CHANGELOG |
| **Atualizar** | Acrescentar as mudanças recentes em `[Unreleased]` |
| **Fechar versão** | Promover `[Unreleased]` a uma versão com data |
| **Revisar** | Relatório de lacunas e erros, sem editar |

---

## 2. Workflow

1. **Detecte a automação** (seção 0). Se houver, pare e explique.
2. **Defina o intervalo**: a última tag (`git describe --tags --abbrev=0`) até `HEAD`, com `git log --no-merges`. Sem tags, use o histórico inteiro e confirme com o usuário antes de criar a entrada inicial.
3. **Classifique** os commits (seção 3).
4. **Redija** para o usuário final: o que mudou e por que importa, não a mensagem do commit. Referencie PR ou issue (`#123`) quando houver; não cite hashes.
5. **Proponha a versão** (seção 4) e aguarde a confirmação, no modo Fechar versão.
6. **Links de comparação** no rodapé, derivados de `git remote get-url origin` (formato GitHub; ajuste para outros hospedeiros). Não invente URLs.
7. **Valide**: `markdownlint` se existir, e a coerência dos links.

---

## 3. Classificação

Com **Conventional Commits**:

| Commit | Seção |
| :--- | :--- |
| `feat` | Added |
| `fix` | Fixed |
| `perf` | Changed |
| `!` ou `BREAKING CHANGE` | Changed, com o prefixo **BREAKING** |
| Descontinuação explícita | Deprecated |
| Remoção de funcionalidade | Removed |
| Correção de vulnerabilidade | Security |
| `docs`, `test`, `ci`, `chore`, `style`, `build` | Ignorar |
| `refactor` | Ignorar, salvo mudança visível ao usuário |

Sem Conventional Commits, classifique pela mensagem e pelo diff (`git show --stat`) e marque `(inferido)` quando houver ambiguidade. Agrupe commits que descrevem a mesma mudança.

---

## 4. Versão

Proponha o próximo número pelo SemVer, conforme as mudanças do intervalo: quebra de contrato gera MAJOR (em `0.y.z`, siga a convenção do projeto), `feat` gera MINOR e `fix` gera PATCH. A data (ISO 8601) vem do contexto da conversa e só entra ao fechar a versão. Sempre confirme com o usuário.

---

## 5. Modelo

````markdown
# Changelog

Todas as mudanças relevantes deste projeto são documentadas neste arquivo.
O formato segue o [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o projeto adota o [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Added
- Exportação de pedidos em CSV pela tela de relatórios (#42).

## [1.2.0] - 2026-10-13

### Changed
- **BREAKING:** o endpoint `GET /v1/pedidos` agora exige o parâmetro `periodo` (#51).

### Fixed
- Correção do total arredondado errado em pedidos com desconto (#48).

[Unreleased]: https://github.com/ORG/REPO/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/ORG/REPO/compare/v1.1.0...v1.2.0
````

`[Unreleased]` fica sempre no topo. Seções sem itens não aparecem.

---

## 6. Entrega

1. Arquivo criado ou atualizado, com link relativo, e o que foi acrescentado.
2. A versão proposta e o motivo, quando aplicável.
3. Itens `(inferido)` e commits ignorados, para o usuário conferir.
4. Sugestões: link do CHANGELOG no `README.md` (`-readme`); commit (`docs(changelog): ...`) e tag via `-git`; automação de releases via `-devops`, sob confirmação.
5. Se restaram pendências, pergunte se o usuário quer registrá-las no `TASKS.md` via `-tasks` (modo Importar, origem `changelog`, P2 a P3; fallback em lista no chat).

---

## 7. Armadilhas

- **Despejar o `git log`**: o CHANGELOG não é a lista de commits.
- **Reescrever versões já publicadas.**
- **Inventar a versão, a data ou os links.**
- **Incluir ruído** (`chore`, `ci`, formatação).
- **Editar à mão um arquivo gerado por automação.**
- **Texto técnico demais**: descreva o efeito para quem usa o projeto.
- **Perder as quebras de contrato**: devem aparecer em destaque.