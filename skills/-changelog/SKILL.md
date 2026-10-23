---
name: -changelog
description: "Cria ou atualiza o CHANGELOG.md no formato Keep a Changelog com Versionamento Semântico, a partir das tags do repositório e dos commits entre elas: gera uma entrada por versão publicada, acrescenta ao arquivo existente as versões que ainda não constam nele, recalcula o [Unreleased] (commits desde a última tag), preserva as entradas já publicadas e detecta quando uma automação de releases já gera o arquivo. ATIVAÇÃO EXCLUSIVAMENTE EXPLÍCITA: use somente quando o usuário pedir 'crie o changelog', 'atualize o changelog', 'sincronize o changelog com as tags', 'documente a release', 'prepare o CHANGELOG da versão X' ou 'o CHANGELOG está desatualizado'. NÃO use para o README (isso é -readme) nem para publicar tags e releases (isso é -git e -devops)."
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(git log *), Bash(git describe *), Bash(git tag -l *), Bash(git tag --list *), Bash(git for-each-ref *), Bash(git rev-list *), Bash(git remote *), Bash(git diff *), Bash(git show *), Bash(git status *), Bash(npx markdownlint-cli *)
---

# Changelog: histórico por versão para quem usa o projeto

Gera ou atualiza o `CHANGELOG.md` seguindo o [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o [Versionamento Semântico](https://semver.org/lang/pt-BR/). **As tags são a fonte da verdade das versões**: cada tag publicada tem a sua entrada, e o `[Unreleased]` guarda só o que veio depois da última tag. O público é quem usa ou integra o projeto, não quem leu os commits.

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativa**: `-changelog`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Ativação explícita.** Nunca execute por conta própria durante outras tarefas.

**Automação existente.** Se o projeto usa semantic-release, release-please, changesets ou standard-version (configuração, `.releaserc*`, `.changeset/`, workflow de release), o arquivo é gerado pela ferramenta: **não o edite à mão**. Explique e, se o usuário quiser, ajuste a configuração via `-devops`.

**Não reescreva o histórico publicado.** Entradas de versões já presentes no arquivo permanecem como estão. A skill acrescenta versões novas e recalcula o `[Unreleased]`.

**Nada escrito por pessoas se perde em silêncio.** Linhas manuais sem correspondência nos commits são mantidas e listadas no resumo.

**Não invente.** Versões e datas vêm das tags; links de comparação vêm do `git remote`. Todo item é rastreável a commits.

**Git.** Não crie tags nem releases, não commite e não abra PR sem pedido. Se o usuário pedir, siga o `-git` e o `-devops`.

**Idioma.** O do CHANGELOG existente; sem ele, o do repositório. Títulos de seção: os do arquivo existente; em arquivo novo, os padrões do Keep a Changelog (`Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`).

---

## 1. Modos de operação

| Modo | Quando |
| :--- | :--- |
| **Criar** | O projeto não tem CHANGELOG: gera uma entrada por tag |
| **Atualizar** | O arquivo existe: acrescenta as versões que faltam e recalcula o `[Unreleased]` |
| **Fechar versão** | Preparar uma release ainda sem tag: promove o `[Unreleased]` a uma versão |
| **Revisar** | Relatório de lacunas e erros, sem editar |

---

## 2. Workflow

1. **Detecte a automação** (seção 0). Se houver, pare e explique.
2. **Liste as versões**: `git tag -l --sort=-v:refname`, mantendo as tags SemVer (`vX.Y.Z` ou `X.Y.Z`). Ignore pré-lançamentos (`-rc`, `-beta`) e tags de outros pacotes, salvo se o usuário pedir; em monorepo, confirme o padrão das tags. Datas: `git for-each-ref --format='%(refname:short) %(creatordate:short)' refs/tags`.
3. **Defina o que gerar**:
   - **Criar**: uma entrada para **cada tag**, da mais antiga à mais recente. Se houver muitas (mais de ~15), proponha limitar às últimas N versões (sugestão: 12) e acrescentar a seção "Versões anteriores" com link para as tags. Confirme com o usuário antes.
   - **Atualizar**: leia as versões já presentes (`## [x.y.z]`). Gere uma entrada para **cada tag mais nova que a última versão do arquivo**. Tags que faltam no meio do histórico são apenas relatadas, com a oferta de preencher.
   - **`[Unreleased]`**: sempre recalculado com os commits desde a última tag (`git log --no-merges <última-tag>..HEAD`).
4. **Para cada versão**, use os commits de `<tag-anterior>..<tag>` (na primeira tag, desde o início do histórico), classifique (seção 3) e redija para o usuário final: o que mudou e por que importa, não a mensagem do commit. Referencie PR ou issue (`#123`) quando houver; não cite hashes.
5. **Reconcilie o `[Unreleased]` antigo**: linhas que agora pertencem a uma versão nova saem do `[Unreleased]` (casam por número de PR ou issue, ou pelo conteúdo dos commits). Linhas escritas por pessoas sem correspondência são mantidas e listadas no resumo para conferência.
6. **Versão e data**: vêm das tags (a data é a da tag). Só no modo **Fechar versão**, quando a tag ainda não existe, a versão é proposta pelo SemVer (seção 4) e confirmada pelo usuário.
7. **Links de comparação** no rodapé, derivados de `git remote get-url origin` (formato GitHub; ajuste para outros hospedeiros): um por versão, `[x.y.z]: .../compare/v<anterior>...v<x.y.z>`; a primeira versão aponta para `.../releases/tag/v<x.y.z>`; e `[Unreleased]: .../compare/v<última>...HEAD`. Não invente URLs.
8. **Valide**: `markdownlint` se existir, ordem decrescente das versões e coerência dos links.

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

Sem Conventional Commits, classifique pela mensagem e pelo diff (`git show --stat`) e marque `(inferido)` quando houver ambiguidade. Agrupe commits que descrevem a mesma mudança. Uma versão cujos commits são todos ruído não ganha entrada vazia: registre "sem mudanças relevantes para o usuário" apenas se o usuário quiser manter a linha da versão.

---

## 4. Versão (modo Fechar versão)

Proponha o próximo número pelo SemVer, conforme as mudanças desde a última tag: quebra de contrato gera MAJOR (em `0.y.z`, siga a convenção do projeto), `feat` gera MINOR e `fix` gera PATCH. A data (ISO 8601) vem do contexto da conversa. Sempre confirme com o usuário.

---

## 5. Modelo

````markdown
# Changelog

Todas as mudanças relevantes deste projeto são documentadas neste arquivo.

O formato segue o [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o projeto adota o [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Added
- Exportação de pedidos em CSV pela tela de relatórios (#42).

### Changed
- O processamento de cenários passou a considerar choques de volatilidade. (inferido)

## [1.2.0] - 2026-10-13

### Changed
- **BREAKING:** o endpoint `GET /v1/pedidos` agora exige o parâmetro `periodo` (#51).

### Fixed
- Correção do total arredondado errado em pedidos com desconto (#48).

## [1.1.0] - 2026-10-02

### Added
- Filtro de pedidos por status.

## Versões anteriores

O histórico das versões anteriores a 1.1.0 está disponível nas [tags do repositório](https://github.com/ORG/REPO/tags?after=v1.1.0).

[Unreleased]: https://github.com/ORG/REPO/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/ORG/REPO/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/ORG/REPO/compare/v1.0.0...v1.1.0
````

`[Unreleased]` fica sempre no topo, as versões em ordem decrescente e as seções sem itens não aparecem. A seção "Versões anteriores" só existe quando o histórico foi limitado.

---

## 6. Entrega

1. Arquivo criado ou atualizado, com link relativo.
2. **Versões adicionadas** (com datas), lacunas antigas encontradas e o intervalo coberto no `[Unreleased]`.
3. Itens `(inferido)`, commits ignorados e linhas manuais mantidas sem correspondência, para o usuário conferir.
4. Sugestões: link do CHANGELOG no `README.md` (`-readme`); commit (`docs(changelog): ...`) e tag via `-git`; automação de releases via `-devops`, sob confirmação.
5. Se restaram pendências, pergunte se o usuário quer registrá-las no `TASKS.md` via `-tasks` (modo Importar, origem `changelog`, P2 a P3; fallback em lista no chat).

---

## 7. Armadilhas

- **Gerar só o `[Unreleased]` e ignorar as tags**: o histórico por versão é o objetivo.
- **Deixar no `[Unreleased]` o que já foi lançado**: depois de uma release nova, o `[Unreleased]` volta a conter só o que veio depois dela.
- **Não acrescentar as versões novas** a um arquivo existente.
- **Despejar o `git log`**: o CHANGELOG não é a lista de commits.
- **Reescrever versões já publicadas.**
- **Inventar versão, data ou links.**
- **Incluir ruído** (`chore`, `ci`, formatação).
- **Editar à mão um arquivo gerado por automação.**
- **Texto técnico demais**: descreva o efeito para quem usa o projeto.
- **Perder as quebras de contrato**: devem aparecer em destaque.