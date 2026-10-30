---
name: sk-readme
description: "Cria ou atualiza o README.md de um repositório a partir de evidências (estrutura, manifestos, CI, testes, documentos de contexto), preservando o que a equipe escreveu e sem inventar informações. ATIVAÇÃO EXCLUSIVAMENTE EXPLÍCITA: use somente quando o usuário pedir 'crie o README', 'atualize o README', 'o README está desatualizado' ou 'documente este repositório'. NÃO use para o CHANGELOG (isso é sk-changelog), para os documentos de contexto de IAs (isso é sk-discovery) nem para documentação de API (isso é sk-api-design)."
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(git status *), Bash(git log *), Bash(git remote *), Bash(git branch *), Bash(git diff *), Bash(git ls-files *), Bash(npx markdownlint-cli *)
---

# README: documentação de entrada do repositório

Gera ou atualiza o `README.md` para pessoas: o que o projeto é, como rodar, como contribuir. O que o discovery mapeia para IAs (`CONTEXT.md`, `AGENTS.md`) é fonte, não substituto.

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-readme`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Ativação explícita.** Nunca execute por conta própria durante outras tarefas.

**Evidência.** Toda afirmação é rastreável a um arquivo ou commit do repositório. Sem evidência, omita a seção ou marque `[A CONFIRMAR]`. Isso vale para **licença** (leia o `LICENSE`; se não houver, `[A CONFIRMAR]`) e **status do projeto**: não invente valores padrão.

**Preserve o que a equipe escreveu.** Em um README existente, estenda e corrija, mas não reescreva textos escritos por pessoas. Mostre o diff ao final.

**Escopo.** O repositório do diretório atual. Não clone nem analise outros.

**Segredos.** Leia só `.env.example` e equivalentes; nos exemplos, apenas nomes de variáveis, nunca valores. Nunca inclua credenciais.

**Git.** Não crie branch, não commite nem abra PR sem pedido. Se o usuário pedir, siga o `sk-git`.

**Idioma.** O do README existente; sem ele, o da documentação e dos commits do repositório; sem nenhum, português do Brasil.

---

## 1. Modos de operação

| Modo | Quando |
| :--- | :--- |
| **Criar** | O projeto não tem README |
| **Atualizar** | O README existe e está desatualizado |
| **Revisar** | Relatório de lacunas e erros, sem editar |

---

## 2. Workflow

1. **Descoberta**, antes de escrever:
   - Estrutura de arquivos (`git ls-files`), manifestos (`package.json`, `*.csproj`, `pyproject.toml`, `pom.xml`, `composer.json`, `go.mod`, `pubspec.yaml`), `Dockerfile` e `docker-compose.yml`.
   - Workflows de CI (`.github/workflows/`), configuração e relatórios de teste e cobertura existentes, `LICENSE`, `CONTRIBUTING.md`, `.env.example`.
   - Documentos já gerados: `CONTEXT.md`, `ARCHITECTURE.md`, `DATA.md`, `PRD.md` e ADRs. **Aponte para eles com link, sem duplicar.**
   - README e CHANGELOG existentes, `git remote` e `git log` recente (atividade e convenção de commits).
2. **Resumo das descobertas** em poucas linhas: stack, arquitetura, testes, CI/CD, integrações e lacunas do README atual.
3. **Escrita** (seção 3), seguindo as regras de qualidade (seção 4).
4. **Validação**: links, blocos de código e, se existir, `markdownlint`.
5. **Entrega** (seção 5).

---

## 3. Estrutura do README

Adapte à realidade do projeto. **Cada seção só entra se houver dado concreto.**

1. **Título** e **badges** (CI, versão, licença), somente os detectáveis e com links verdadeiros.
2. **Descrição curta**, em uma ou duas linhas.
3. **Pré-requisitos** e **Instalação e uso**.
4. **Configuração**: variáveis de ambiente (nomes e função, sem valores).
5. **Estrutura do repositório**: árvore comentada e concisa.
6. **Arquitetura**: diagrama Mermaid apenas quando há evidência; link para o `ARCHITECTURE.md`.
7. **Testes e cobertura**: como executar.
8. **Contribuição**: link para o `CONTRIBUTING.md`, se existir.
9. **Licença** e **status**.
10. **Links**: `CHANGELOG.md`, documentação adicional.

**Comandos**: só inclua um comando rastreável a um manifesto, `Makefile` ou workflow, citando a origem na descoberta. Caso contrário, marque `não verificado`. Nunca presuma `npm start` ou equivalentes.

**Tamanho**: até ~250 linhas. O que for mais longo vai para `docs/` com link.

---

## 4. Qualidade

- Sem texto genérico: cada afirmação aponta para algo do repositório.
- Blocos de código com a linguagem indicada (`bash`, `typescript`...).
- Links relativos e **validados** (confira a existência dos arquivos com `Glob`).
- Árvores de diretório alinhadas à hierarquia real.
- Diagramas Mermaid executáveis.
- Sem erros de digitação nem mistura de idiomas.

---

## 5. Entrega

1. Arquivo criado ou atualizado, com link relativo.
2. Resumo do que mudou (`git diff --stat`) e do que foi preservado.
3. Itens `[A CONFIRMAR]` e comandos `não verificado`.
4. Sugestões: se não há CHANGELOG, ofereça o `sk-changelog`. Para commit ou PR, o `sk-git`, sob confirmação (`docs(readme): ...`).
5. Se restaram lacunas, pergunte se o usuário quer registrá-las no `TASKS.md` via `sk-tasks` (modo Importar, origem `readme`, P2 a P3; fallback em lista no chat).

---

## 6. Armadilhas

- **Inventar informação**: licença, status, comandos e arquitetura sem evidência.
- **Reescrever o texto da equipe**: apaga contexto e decisões.
- **Duplicar o conteúdo** do `ARCHITECTURE.md` e do `CONTEXT.md`: use links.
- **Links quebrados** e blocos de código sem linguagem.
- **Expor segredos** em exemplos de configuração.
- **README gigante**: o que é longo vai para `docs/`.
- **Executar sem pedido explícito.**