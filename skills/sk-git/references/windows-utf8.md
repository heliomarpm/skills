# Windows: UTF-8 e finais de linha no Git

Leia este arquivo apenas quando o ambiente for Windows e a tarefa envolver mensagem de commit, corpo ou título de PR com acentos ou emojis, ou diffs causados por fim de linha.

## Conteúdo

1. Por que o texto corrompe
2. Sessão do PowerShell em UTF-8
3. Gravar mensagens e corpos de PR
4. Abrir PR com título acentuado
5. Verificar se o texto foi preservado
6. Finais de linha (CRLF e LF)
7. Configuração do Git

---

## 1. Por que o texto corrompe

No Windows PowerShell 5.1, comandos nativos (`git`, `gh`) recebem texto na codificação da sessão (`$OutputEncoding`, por padrão ASCII) e em code pages ANSI ou OEM. Acentos, cedilha e emojis passados pela linha de comando viram `?` ou sequências como `Ã§` e `Ã£`. O `Invoke-RestMethod` do PS 5.1 também trata corpos em string como ISO-8859-1. Scripts `.ps1` salvos sem BOM são lidos como ANSI.

Git Bash costuma preservar UTF-8, mas a regra mais segura vale para os dois: **texto acentuado vai por arquivo UTF-8, não por argumento de linha de comando.**

## 2. Sessão do PowerShell em UTF-8

Use uma codificação UTF-8 **sem BOM** (valide no ambiente, pois o comportamento varia por versão):

```powershell
$utf8 = New-Object System.Text.UTF8Encoding $false
[Console]::InputEncoding  = $utf8
[Console]::OutputEncoding = $utf8
$OutputEncoding = $utf8
chcp 65001 > $null
```

`[System.Text.Encoding]::UTF8` inclui BOM e pode contaminar a entrada de comandos nativos.

## 3. Gravar mensagens e corpos de PR

- Crie os arquivos com a ferramenta `Write` (UTF-8 sem BOM), em um diretório temporário do sistema, **nunca dentro do repositório**. Não precisa apagar depois.
- Evite `echo > arquivo` e `Out-File` no PS 5.1: gravam UTF-16 ou ANSI.
- Commit: `git commit -F <arquivo-de-mensagem>`.
- Corpo da PR: `gh pr create --title "..." --body-file <arquivo-de-corpo>`.
- Quebras de linha no PowerShell: dentro de aspas duplas, `\n` **não** é quebra de linha (é uma barra e um `n`); use `` `n `` ou here-string. Em arquivos criados com `Write`, isso não é problema.

## 4. Abrir PR com título acentuado

O título de `--title` ainda passa pela linha de comando. No PS 5.1, para título com acento ou emoji, use `gh api` com um arquivo JSON UTF-8 criado com `Write`:

```json
{
  "title": "feat(auth): suporte a PKCE no login móvel",
  "head": "feat/T-004-pkce",
  "base": "main",
  "body": "## Resumo\n\nValidação, atenção e experiência preservadas.\n"
}
```

```bash
gh api repos/{owner}/{repo}/pulls --input pr.json
```

`{owner}` e `{repo}` são resolvidos pelo `gh` a partir do repositório atual. No JSON, `\n` é quebra de linha válida.

Não extraia tokens do gerenciador de credenciais para chamar a API manualmente. Se o `gh` não estiver disponível ou autenticado (`gh auth status`), entregue título e corpo prontos e o link de comparação do remoto para o usuário abrir a PR.

## 5. Verificar se o texto foi preservado

Após o commit ou a PR, confira:

```bash
git log -1 --format=%B
gh pr view --json title,body
```

Se aparecerem `?` ou `Ã§`, refaça pelo caminho de arquivo UTF-8 (seções 3 e 4). Para commit já criado e **não publicado**, a correção é `git commit --amend -F <arquivo>`, com confirmação do usuário.

## 6. Finais de linha (CRLF e LF)

Diferenças de fim de linha geram diffs enormes e poluem commits. Recomendação:

```text
# .gitattributes
* text=auto eol=lf
```

Para arquivos que já estão no repositório com CRLF, `git add --renormalize .` aplica a regra, mas produz um commit grande: peça confirmação e faça-o em commit separado.

## 7. Configuração do Git

- `core.quotepath false` exibe caminhos acentuados legíveis. Prefira `git config --local`; a configuração global altera o ambiente inteiro do usuário e exige confirmação.
- `i18n.commitEncoding` já é `utf-8` por padrão; não é necessário alterá-lo.
- Renomeações que mudam só a caixa do nome (`Arquivo.md` para `arquivo.md`) precisam de `git mv` em sistemas que ignoram maiúsculas.
- Caminhos muito longos podem exigir `core.longpaths` (configuração local, com confirmação).