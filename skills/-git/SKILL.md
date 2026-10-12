---
name: -git-workflow
description: Orienta fluxos de trabalho no Git, estratégias de branching (Trunk-Based), rebase interativo, Conventional Commits, integridade de codificação UTF-8 no Windows/PowerShell, abertura de Pull Requests e automação de releases.
allowed-tools: Read, Grep, Glob, Bash(git status *), Bash(git diff *), Bash(git log *), Bash(git show *), Bash(git branch *), Bash(git checkout *), Bash(git switch *), Bash(git add *), Bash(git commit *), Bash(git fetch *), Bash(git pull *), Bash(git rebase *), Bash(git rev-parse *), Bash(gh pr *), Bash(gh release *)
---

# Global Skill: Professional Git Workflow, Branching & Release Management

Diretrizes técnicas especializadas para fluxos de trabalho avançados no Git, integridade absoluta de codificação de caracteres (UTF-8), histórico limpo e atômico, criação padronizada de Pull Requests e automação de versões.


> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧠 **Skill Ativa**: `-git-workflow``

---

## 1. Processo de Execução no Git

Ao desenvolver, revisar, integrar branches ou interagir com repositórios remotos:

1. **Garantia de Codificação UTF-8 (Prevenção de Caracteres Inválidos / Mojibake)**:
   - Em ambientes Windows (especialmente PowerShell 5.1), comandos nativos e CLI tools (`git`, `gh`) frequentemente herdam `$OutputEncoding = ASCII` e code pages ANSI (`Windows-1252`) ou OEM (`ibm850`/`cp437`).
   - Todo commit, mensagem, título e corpo de Pull Request **deve ser preservado em UTF-8 estrito**, evitando a introdução de caracteres corrompidos (`Ã§`, `Ã£`, `ðŸš€`, `?`) em cedilhas (`ç`), acentos (`á`, `é`, `í`, `ó`, `ú`, `ã`, `õ`, `ê`, `ô`) ou emojis.
2. **Trunk-Based Development com Branches Curtas**:
   - Crie branches de curta duração (menos de 2 dias de vida) a partir da branch principal (`main` ou `develop`).
   - Integre alterações frequentemente usando *Feature Flags* para desacoplar deploy de release.
3. **Commits Atômicos & Conventional Commits**:
   - Cada commit deve representar uma única alteração lógica coesa.
   - Siga a especificação: `tipo(escopo opcional): descrição no presente imperativo` (ex: `feat(auth): add pkce support for mobile login`).
4. **Rebase Interativo para Histórico Linear**:
   - Atualize sua branch local com `git fetch origin && git rebase origin/main` para evitar commits de merge poluídos (`Merge branch 'main' into feature`).
5. **Resolução Cirúrgica de Conflitos**:
   - Resolva conflitos mantendo o histórico original intacto e validando testes unitários logo após cada passo do rebase.
6. **Abertura Padronizada de Pull Requests (PRs)**:
   - Valide se a branch local está sincronizada e limpa antes de submeter a PR.
   - Utilize templates estruturados com Conventional Commits no título, resumo das entregas e checklist de validação.
   - Para envio de corpo markdown longo, use sempre passagem por arquivo codificado em UTF-8 (`--body-file`) ou scripts em tempo de execução com encoding UTF-8 garantido (Node.js ou PowerShell com byte stream UTF-8).
7. **Automação de Versões (Semantic Release)**:
   - Gere tags automáticas e Changelogs sem intervenção manual baseando-se nos prefixos dos commits (`fix:` ➔ PATCH, `feat:` ➔ MINOR, `feat!:` / `BREAKING CHANGE:` ➔ MAJOR).

---

## 2. Snippets Canônicos de Referência

### 2.1. Blindagem de Codificação UTF-8 no Windows / PowerShell e Git
```powershell
# 1. Configura a sessão do PowerShell para UTF-8 estrito (evita caracteres corrompidos em CLI e APIs)
[Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 >$null

# 2. Configura o Git para operar estritamente em UTF-8
git config --global i18n.commitEncoding utf-8
git config --global i18n.logOutputEncoding utf-8
git config --global core.quotepath false
```

```bash
# 3. Commit seguro com acentuação via arquivo temporário UTF-8 (evita mangling do shell):
# Cria o arquivo de mensagem em UTF-8 e executa:
git commit -F .git/COMMIT_MSG_TEMP.txt
rm .git/COMMIT_MSG_TEMP.txt
```

### 2.2. Fluxo de Atualização com Rebase Limpo
```bash
# 1. Busca alterações remotas sem criar commits de merge
git fetch origin main

# 2. Reaplica seus commits sobre o topo da main atualizada
git rebase origin/main

# Se houver conflitos:
# git status                  # Visualiza os arquivos conflitantes
# [Edite os arquivos e resolva]
# git add <arquivo_resolvido>
# git rebase --continue

# 3. Publicação segura atualizando a branch remota sem sobrescrever trabalho de colegas
git push origin feature/minha-tarefa --force-with-lease
```

### 2.3. Padronização de Conventional Commits
```text
feat(billing): add stripe webhook signature verification

- Implement HMAC-SHA256 signature verification with timingSafeEqual
- Add 5-minute timestamp tolerance against replay attacks
- Include unit tests covering invalid signature scenarios

Closes #142
```

### 2.4. Limpeza de Histórico Local com Rebase Interativo
```bash
# Agrupa ou edita os últimos 3 commits antes de abrir o Pull Request
git rebase -i HEAD~3

# No editor que abrir:
# pick a1b2c3d feat(cart): add cart repository
# squash e4f5g6h fix typo in cart model       <- Junta com o commit anterior
# squash i7j8k9l fix lint errors               <- Junta com o commit anterior
```

### 2.5. Abertura Segura de Pull Request (Preservação de Acentos e Emojis)

#### Opção A: Via GitHub CLI (`gh`) com `--body-file` (Recomendado)
```bash
# Grava a descrição em arquivo Markdown UTF-8 para evitar qualquer escape indevido do terminal
gh pr create \
  --base develop \
  --head feature/minha-feature \
  --title "feat(escopo): descrição concisa no presente" \
  --body-file pr_body.md
```

#### Opção B: Via Script Node.js (Fallback Universal 100% UTF-8)
Quando o `gh` não estiver disponível, prefira executar um script Node.js temporário (que gerencia requisições HTTP e UTF-8 nativamente sem intermediários de code page do Windows):
```javascript
import { execSync } from 'node:child_process';

const creds = execSync('git credential fill', { input: 'protocol=https\nhost=github.com\n' }).toString();
const token = creds.match(/password=(.+)/)?.[1]?.trim();

const response = await fetch('https://api.github.com/repos/<owner>/<repo>/pulls', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Accept': 'application/vnd.github+json',
    'Content-Type': 'application/json; charset=utf-8',
    'User-Agent': 'Antigravity-Agent'
  },
  body: JSON.stringify({
    title: 'feat(escopo): descrição da PR com acentuação e emojis 🚀',
    head: 'feature/minha-feature',
    base: 'develop',
    body: '## 🎯 Descrição das Alterações\n\nTexto com acentuação perfeita: validação, atenção, experiência.'
  })
});
```

#### Opção C: Via PowerShell com Stream de Bytes UTF-8 Explícito
Caso utilize PowerShell (`Invoke-RestMethod`), nunca passe o corpo como string direta no PowerShell 5.1 (ele converterá para ISO-8859-1). Converta para bytes UTF-8 explicitamente:
```powershell
[Console]::OutputEncoding = $OutputEncoding = [System.Text.Encoding]::UTF8

$jsonPayload = @{
    title = "feat(escopo): descrição com acentuação e 🚀"
    head  = "feature/minha-feature"
    base  = "develop"
    body  = "## 🎯 Descrição\n\nPreservação garantida de ç, ã, é."
} | ConvertTo-Json -Depth 5

# Converte obrigatoriamente a string JSON em array de bytes UTF-8
$utf8Bytes = [System.Text.Encoding]::UTF8.GetBytes($jsonPayload)

Invoke-RestMethod -Uri "https://api.github.com/repos/<owner>/<repo>/pulls" `
    -Headers $headers `
    -Method Post `
    -ContentType "application/json; charset=utf-8" `
    -Body $utf8Bytes
```

---

## 3. Armadilhas Críticas no Git (*Gotchas*)

- ⚠️ **Mojibake no Windows / PowerShell (Caracteres Corrompidos em PRs e Commits)**:
  - No Windows PowerShell 5.1, `$OutputEncoding` é `US-ASCII` por padrão. Passar mensagens com caracteres acentuados (`ç`, `ã`, `é`) via linha de comando (`git commit -m "..."` ou `gh pr create --body "..."`) converte caracteres especiais em `?` ou sequências corrompidas.
  - O cmdlet `Invoke-RestMethod` do PowerShell 5.1 trata corpos em formato `string` como `ISO-8859-1`. Se a requisição contiver acentos, deve-se obrigatoriamente enviar `-Body ([System.Text.Encoding]::UTF8.GetBytes($jsonPayload))`.
  - Scripts `.ps1` gerados sem UTF-8 BOM são lidos pelo PowerShell 5.1 como ANSI (`Windows-1252`), corrompendo strings no próprio momento da leitura. Prefira executar via script Node.js ou garantir salvamento com UTF-8 BOM.
- ⚠️ **`git push --force` sem `--force-with-lease`**: Usar `--force` cego sobrescreve e destrói commits que outro desenvolvedor possa ter enviado para a branch remota. Use sempre `--force-with-lease`.
- ⚠️ **Commits de Merge Cruzados (`Merge branch 'main' into 'feature'`)**: Misturar merges de sincronização com merges de entrega torna o `git bisect` ineficaz e polui a árvore histórica. Prefira `git rebase origin/main`.
- ⚠️ **Commits Gigantescos não Atômicos**: Misturar refatoração de código, mudança de formatação (linter) e nova regra de negócio no mesmo commit impede a realização de *Cherry-picks* e *Rollbacks* seguros em produção.

---

## 4. Padrão de Entrega do Agente

Ao fornecer instruções, executar comandos Git ou abrir Pull Requests:
1. **Preservação de Encoding**: Garanta que qualquer comando, commit ou submissão de PR preserve acentos, cedilhas e emojis através de configuração explícita de UTF-8.
2. **Rebase Seguro**: Recomende sempre comandos seguros com `--force-with-lease`.
3. **Conventional Commits**: Forneça mensagens de commit e títulos de PR formatados estritamente de acordo com o padrão *Conventional Commits*.
4. **Estrutura de PR Profissional**: Emita PRs com seções claras (`Descrição das Alterações`, `Principais Entregas`, `Checklist de Validação`).
5. **Validação Pós-Integração**: Oriente a execução de testes automatizados imediatamente após qualquer resolução de conflitos ou rebase.
