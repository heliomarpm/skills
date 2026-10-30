---
name: sk-git
description: "Orienta e executa fluxos de Git com segurança: commits atômicos e Conventional Commits, nomes de branch, atualização de branch, higiene de histórico local, resolução de conflitos, abertura de Pull Requests e recuperação de erros, respeitando a estratégia e as convenções do projeto, incluindo integridade UTF-8 e finais de linha no Windows. Use sempre que o usuário pedir 'faça o commit', 'mensagem de commit', 'abra a PR', 'crie a branch', 'faça o rebase', 'resolva o conflito', 'limpe o histórico', 'squash', 'desfaça este commit' ou 'como fica o fluxo de branches', mesmo sem a palavra 'git'. NÃO use para revisar código (isso é sk-code-review) nem para pipelines de CI/CD e automação de releases (isso é sk-devops)."
allowed-tools: Read, Write, Grep, Glob, Bash(git status *), Bash(git diff *), Bash(git log *), Bash(git show *), Bash(git branch *), Bash(git switch *), Bash(git add *), Bash(git commit *), Bash(git fetch *), Bash(git rev-parse *), Bash(git merge-base *), Bash(git symbolic-ref *), Bash(git remote *), Bash(git reflog *), Bash(gh auth status), Bash(gh pr create *), Bash(gh pr view *), Bash(gh pr diff *), Bash(gh pr checks *), Bash(gh pr list *)
---

# Git: fluxo profissional, seguro e rastreável

Commits atômicos, histórico legível, PRs claros e nenhuma operação destrutiva por acidente. A skill se adapta ao projeto e não impõe uma estratégia.

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-git`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Autonomia.** Proponha a mensagem de commit e a lista de arquivos; só execute `add` e `commit` quando o usuário pedir. Push, rebase, qualquer reescrita de histórico, merge de PR e criação de release exigem confirmação explícita **no momento**, mesmo que o usuário já tenha pedido algo parecido antes. Os comandos de escrita que não estão em `allowed-tools` (push, rebase, reset, merge) vão gerar pedido de permissão: isso é intencional.

**Operações de risco**

| Operação | Regra |
| :--- | :--- |
| `reset --hard`, `clean -fd`, `restore .`, `checkout -- .`, `branch -D`, `stash drop` | Nunca sem pedido explícito. Antes, crie um ponto de retorno (branch de backup) |
| `push --force` | Somente `--force-with-lease`, nunca em branch principal ou protegida, e com confirmação |
| `rebase` ou `commit --amend` de commits já publicados | Só com confirmação e aviso de que reescreve o histórico compartilhado |
| `--no-verify`, `--no-gpg-sign` | Não use. Se um hook falhar, corrija a causa |
| `git add -A` e `git add .` | Evite. Faça stage por caminho |
| `git config --global` | Pergunte antes; prefira `--local` |
| `gh pr merge`, `gh pr close`, `gh release` | Só se o usuário pedir |

**Segredos.** Antes de commitar, confira o que está staged (`.env`, chaves, tokens, binários grandes) e o `.gitignore`. Se um segredo já foi commitado, trate-o como comprometido: a credencial deve ser rotacionada (veja `sk-security`) e só depois se considera reescrever o histórico.

**Não interativo.** Evite o que abre editor, paginador ou prompt: use `git --no-pager`, `GIT_EDITOR=true` para continuar operações e `-F arquivo` para mensagens. `git rebase -i` e `git add -p` não funcionam para um agente (seção 5).

**Idioma.** Mensagens e PRs seguem o idioma do histórico do repositório; a conversa, o do usuário.

---

## 1. Modos de operação

| Modo | Quando |
| :--- | :--- |
| **Commitar** | Gerar mensagem e, se pedido, criar o commit |
| **Atualizar branch** | Trazer a base para a branch de trabalho |
| **Higienizar histórico** | Limpar commits locais ainda não publicados |
| **Resolver conflitos** | Merge ou rebase com conflito |
| **Abrir PR** | Preparar e, se pedido, criar a Pull Request |
| **Orientar** | Explicar ou desenhar o fluxo, sem executar |

---

## 2. Detectar as convenções do projeto

Antes de agir, leia: `git branch -a`, `git log --oneline -20`, `CONTRIBUTING.md`, configuração de `commitlint`, `.github/pull_request_template.md`, `.gitattributes` e a configuração de release. Dali saem:

- **Estratégia de branches** (Trunk-Based, GitHub Flow, GitFlow, base `main` ou `develop`): siga a do projeto. Recomende Trunk-Based (branches curtas, integração frequente, feature flags) somente se não houver convenção.
- **Política de integração** (squash, merge commit ou rebase): respeite-a e nunca escolha a estratégia de merge de uma PR.
- **Formato e idioma dos commits**: se o repositório não usa Conventional Commits, siga o padrão que ele usa.
- **Ambiente**: se for Windows (caminhos `C:\`, PowerShell ou Git Bash), aplique a seção 8.

---

## 3. Commits

**Atômicos**: uma mudança lógica coesa por commit. Não misture refatoração, formatação e regra de negócio no mesmo commit; isso impede cherry-pick e rollback seguros.

**Conventional Commits** (quando o projeto os usa): `tipo(escopo opcional): gitmoji descrição no imperativo`, com assunto de até ~72 caracteres.

- Tipos: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
- Quebra de contrato: `!` após o tipo (`feat(api)!:`) ou rodapé `BREAKING CHANGE:`.
- Rodapés: `Refs: T-005` (tarefa do `sk-tasks`), `Closes #142`.
- Relação com versão SemVer: `fix` gera PATCH, `feat` gera MINOR, quebra de contrato gera MAJOR. A automação que aplica isso é do `sk-devops`.

```text
feat(billing): verificar assinatura do webhook

- Valida HMAC-SHA256 com comparação em tempo constante
- Tolera 5 minutos de diferença de relógio contra replay
- Inclui testes para assinatura inválida

Refs: T-005
Closes #142
```

**Antes de commitar**: `git status` e `git diff --staged`, stage por caminho, sem segredos e sem arquivos gerados. Escreva a mensagem num arquivo temporário (fora do repositório, criado com `Write`) e use `git commit -F <arquivo>`.

---

## 4. Branches e atualização

**Nomes**: `tipo/descricao-curta`, com o ID da tarefa quando houver (`feat/T-005-redirect-uri`). Branches curtas e integradas com frequência.

**Atualizar a branch com a base**, conforme a política do projeto:

- Política com rebase e branch **local ainda não publicada**: `git fetch origin` e `git rebase origin/<base>`, com confirmação.
- Branch já publicada ou compartilhada, ou política de merge: traga a base com merge, ou peça confirmação antes de reescrever.
- Após um rebase de branch já publicada, o push exige `--force-with-lease` e confirmação.

Rebase e conflitos: continue com `GIT_EDITOR=true git rebase --continue` e rode os testes após cada passo relevante.

---

## 5. Higiene de histórico (sem editor interativo)

Só para commits **locais não publicados** (confira com `git log @{u}..`). Toda reescrita pede confirmação e um ponto de retorno.

- **Juntar os últimos N commits**: `git reset --soft HEAD~N` e novo commit com mensagem revisada.
- **Corrigir um commit específico**: `git commit --fixup=<sha>` e depois `GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash <base>`.
- **Dividir mudanças dentro de um mesmo arquivo**: `git add -p` é interativo. Faça stage por arquivo; se for preciso separar hunks, peça ao usuário ou use um patch com `git apply --cached`.

---

## 6. Conflitos

Nunca resolva escolhendo `ours` ou `theirs` em bloco. Entenda os dois lados, preserve a intenção de ambos e rode os testes depois (comando do projeto ou `sk-testing`). Quando a lógica for ambígua, pergunte. Conclua com o comando de continuação adequado ao fluxo (merge ou rebase).

---

## 7. Pull Requests

1. **Pré-requisitos**: branch limpa e sincronizada, testes verificados, e push feito (com confirmação). `gh auth status` confirma o acesso; sem `gh`, entregue título e corpo prontos e o link de comparação do remoto (`git remote -v`) para o usuário abrir a PR.
2. **Título** em Conventional Commits (ou no padrão do projeto).
3. **Descrição**: use o template do repositório, se existir. Senão:

````markdown
## Resumo
O que muda e por quê, em poucas linhas.

## Mudanças
- Principais entregas.

## Como testar
Passos e comandos.

## Relacionados
Spec (`docs/specs/NNN-*.md`, requisitos RF e CA), tarefas (`T-NNN`) e issues.

## Checklist
- [ ] Testes passando
- [ ] Sem segredos
- [ ] Documentação atualizada
````

4. **Tamanho**: ideal até ~400 linhas alteradas; acima disso, proponha dividir (o `sk-code-review` sinaliza a partir de ~1.000). Para trabalho incompleto, abra como rascunho.
5. **Criação**: salve o corpo em arquivo UTF-8 e use `gh pr create --title "..." --body-file <arquivo>`. Título com acento no PowerShell 5.1: veja `references/windows-utf8.md`.
6. **Merge**: só se o usuário pedir, e pela estratégia que o repositório define.

---

## 8. Desfazer e recuperar

- **Desfazer algo já publicado**: `git revert` (cria um commit novo).
- **Recuperar o que parece perdido**: `git reflog` mostra para onde a branch apontou antes.
- **Guardar trabalho temporariamente**: `git stash` (sem `drop` automático).
- **Antes de qualquer operação de risco**, sugira um backup: `git branch backup/<nome>`.

---

## 9. Windows: UTF-8 e finais de linha

Aplique somente se o ambiente for Windows. Detalhes e comandos em `references/windows-utf8.md`; leia-o quando for gravar mensagem de commit, corpo de PR ou título com acentuação, ou ao lidar com diffs por fim de linha.

Regras essenciais:

- No PowerShell 5.1, passar texto acentuado ou emoji por linha de comando (`git commit -m`, `gh pr create --body`) pode corromper os caracteres. Use arquivos UTF-8 criados com `Write` (`-F` e `--body-file`).
- `echo >` e `Out-File` no PS 5.1 não gravam UTF-8 puro.
- Diffs enormes por CRLF poluem commits: o `.gitattributes` com `* text=auto eol=lf` evita o problema. Aplicá-lo a arquivos existentes (`git add --renormalize .`) gera um commit grande e pede confirmação.

---

## 10. Integrações

| Skill | Como se integra |
| :--- | :--- |
| `sk-tasks` | ID da tarefa na branch e no rodapé `Refs:` do commit |
| `sk-spec` | PR referencia a spec e os IDs de requisito e critério |
| `sk-code-review` | Limites de tamanho de PR; revisa o diff que esta skill prepara |
| `sk-refactor` | Um commit por transformação atômica (`refactor(escopo): ...`) |
| `sk-testing` | Testes após conflitos e rebases |
| `sk-security` | Rotação de credenciais vazadas |
| `sk-devops` | Automação de releases (semantic-release, changelog) e CI |

Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 11. Armadilhas

- **`git add -A` indiscriminado**: leva `.env` e binários para o commit.
- **Commit com segredo**: apagar no commit seguinte não remove do histórico.
- **Rebase de branch compartilhada**: reescreve o trabalho dos colegas.
- **`push --force` sem `--force-with-lease`**: sobrescreve commits alheios.
- **`--no-verify`**: contorna a proteção que o projeto definiu.
- **Merge de PR sem pedido**: a decisão é do usuário e da política do repositório.
- **Config global sem avisar**: altera o ambiente inteiro do usuário.
- **Comando interativo travando o agente**: editor, paginador e `-p` sem saída.
- **Commit gigante e não atômico**: impede revert e cherry-pick seguros.
- **Mojibake em commit e PR no Windows**: veja a seção 9.

---

## 12. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado (seção 1).
2. Convenções detectadas (estratégia, política de integração, formato de commit) em uma linha.
3. Para commits e PRs: a mensagem ou o texto proposto, os arquivos incluídos e o resultado da execução (ou o que falta confirmar).
4. Para reescrita de histórico: o ponto de retorno criado e o que mudou.
5. Pendências e confirmações necessárias (push, force, merge).