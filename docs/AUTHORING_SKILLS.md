# Guia de Autoria de Skills (`sk-*`)

Diretriz técnica para propor, criar e evoluir skills deste catálogo garantindo validação integral no CI ([validate_skills.py](../scripts/validate_skills.py)).

---

## 1. Quando criar uma skill nova vs. adicionar uma referência

Para preservar o orçamento de tokens fixos por turno, **evite criar uma skill nova se o assunto já pertence a uma existente**:

- **Crie uma `references/<tema>.md` dentro de uma skill existente** quando o tema é um subdomínio especializado carregado apenas em tarefas específicas (ex.: `sk-security/references/lgpd-and-privacy.md`, `sk-tech-react/references/ssr-and-metaframeworks.md`). Custo fixo por turno adicional: **0 tokens**.
- **Crie uma nova skill `sk-<nome>`** apenas quando houver fluxo próprio de trabalho, persona/regras de operação distintas, ferramentas exclusivas (`allowed-tools`) ou um ecossistema/stack completo (`sk-tech-*`).

---

## 2. Estrutura de diretório

```text
skills/sk-<nome>/
├── SKILL.md                  # Obrigatorio (compacto, direto, ate ~250 linhas quando possivel)
├── references/               # Guias detalhados sob demanda (opcional)
├── examples/                 # Implementacoes concretas de referencia (opcional)
├── templates/                # Esqueletos prontos de documentos/configs (opcional)
└── scripts/                  # Utilitarios locais sem dependencias externas (opcional)
```

- **Zero arquivos órfãos**: todo arquivo dentro de `references/`, `examples/`, `templates/` ou `scripts/` **precisa** estar linkado via caminho relativo dentro do `SKILL.md`.
- **Zero ilhas**: toda nova skill precisa ser referenciada por pelo menos outra skill `sk-*` do catálogo.

---

## 3. Contrato do Frontmatter YAML

O `SKILL.md` deve iniciar na linha 1 com `---` (em LF):

```yaml
---
name: sk-<nome>
description: "O que faz + 3 a 5 gatilhos + 'NÃO use para ... (sk-...)'. Max 360 chars em linha unica."
disable-model-invocation: true   # somente se a skill for de ativacao explicita
allowed-tools: Read, Edit, Write, Grep, Glob
---
```

Regras obrigatórias do frontmatter:
1. **`name`**: idêntico ao nome da pasta em `skills/`.
2. **`description`**:
   - **Máximo exato de 360 caracteres**, em **uma única linha** entre aspas duplas (os instaladores `install.ps1` e `install.sh` fazem parsing linha a linha).
   - Deve trazer o que faz, quando acionar e exclusões claras (`NÃO use para ...`) apontando para skills irmãs.
   - Se `disable-model-invocation: true` estiver presente, a `description` **deve começar** exatamente com `ATIVAÇÃO EXPLÍCITA: `.
3. **`allowed-tools`**:
   - Pré-aprove apenas leitura, edição (se a skill altera arquivos) e comandos específicos e previsíveis (ex.: `Bash(cargo test *)`, `Bash(npx vitest *)`).
   - **Nunca** use curingas amplos que executam código arbitrário (`Bash(npm run *)`, `Bash(npx *)`, `Bash(python *)`, `Bash(bash *)`).
   - Operações destrutivas ou que alteram o remoto (`git push`, `terraform apply`, `install` de pacotes externos, etc.) ficam **fora** de `allowed-tools` para sempre exigirem confirmação.

---

## 4. Contrato estrutural do `SKILL.md`

1. **Primeira seção `##`**: deve começar exatamente com `## 0. Regras de operação`.
2. **Assinatura obrigatória**: dentro do corpo deve constar exatamente:
   ```markdown
   > 🧠 **Skill Ativada**: `sk-<nome>`
   ```
3. **Ordem exata das 3 últimas seções `##`**:
   - Antepenúltima: `## N. Integrações` (ou `## N. Integrações e registro via \`sk-tasks\``)
   - Penúltima: `## N+1. Armadilhas` — **obrigatoriamente em bullet list (`- `)**, nunca tabela Markdown.
   - Última: `## N+2. Padrão de entrega` — o item `1.` **deve iniciar com a palavra `Assinatura`** (ex.: `1. Assinatura na primeira mensagem (seção 0)...`).
4. **Regras técnicas obrigatórias por tipo**:
   - **Circuit Breaker**: obrigatório em todas as `sk-tech-*` e em skills executoras/validadoras listadas em `CIRCUIT_BREAKER_REQUIRED` no `validate_skills.py` (teto de 3 tentativas consecutivas sobre a mesma falha).
   - **Banco e índices (`sk-tech-*`)**: toda stack que implementa acesso a banco SQL, ORM ou banco local (SQLite/Drift/Room/SQLDelight/sqlx/EF/JPA/PDO) deve exigir consultas performáticas (sem `SELECT *` nem N+1) e entrega obrigatória do script/migration de índices adequados com rollback.
5. **Cuidado com tokens `sk-*` no texto**: o validador verifica toda palavra no padrão `\bsk-[a-z][a-z0-9-]*\b` dentro de `SKILL.md` e falha se não existir uma pasta correspondente. Para mascarar segredos em exemplos use `sk-****`; não escreva placeholders fictícios com prefixo `sk-`.

---

## 5. Autocontenção, neutralidade e encoding

- **Neutralidade de cliente e modelo**: dentro de `skills/sk-*/**` e `rules/sk-core.md`, não cite caminhos fixos de clientes, versões fixas de modelos de IA proprietários nem ferramentas externas fora do repositório.
- **Estilo (Camada 0)**: siga [rules/sk-core.md](../rules/sk-core.md) — voz ativa, PT-BR, sem preenchimento nem elogios artificiais.
- **Encoding e fim de linha**: todos os `.md`, `.json`, `.py`, `.sh`, `.js` e `.cjs` devem usar **UTF-8 sem BOM** com fim de linha **LF** (somente `*.ps1` usa CRLF).

---

## 6. Checklist ao adicionar uma nova skill

- [ ] Pasta `skills/sk-<nome>/SKILL.md` (+ `references/` ou `examples/` linkados) criada em UTF-8 sem BOM + LF.
- [ ] Skill adicionada em **exatamente 1** dos 5 Pilares em [profiles.json](../profiles.json) (e nos perfis compostos pertinentes).
- [ ] Se tiver ativação explícita ou Circuit Breaker, incluída em [rules/sk-core.md](../rules/sk-core.md) e `CIRCUIT_BREAKER_REQUIRED` em [scripts/validate_skills.py](../scripts/validate_skills.py).
- [ ] Origem adicionada em [skills/sk-tasks/SKILL.md](../skills/sk-tasks/SKILL.md) e links cruzados adicionados nas skills relacionadas (zero ilhas).
- [ ] Tabela e contagens atualizadas no [README.md](../README.md) com os valores medidos pelos scripts.
- [ ] Validação local 100% aprovada antes do commit:
  - `python scripts/validate_skills.py` retorna `ALL CHECKS PASSED`;
  - `powershell -ExecutionPolicy Bypass -File scripts/install.ps1 -List` (ou `./scripts/install.sh --list`) lista todos os perfis sem erro.
