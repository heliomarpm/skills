---
name: _git-workflow
description: Orienta fluxos de trabalho no Git, estratégias de branching (Trunk-Based), rebase interativo, Conventional Commits, resolução de conflitos e automação de releases.
---

# Global Skill: Professional Git Workflow, Branching & Release Management

Diretrizes técnicas especializadas para fluxos de trabalho avançados no Git, histórico limpo e atômico, estratégias de integração contínua e automação de versões.


> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧭 **Skill Ativa**: `_git-workflow``

---

## 1. Processo de Execução no Git

Ao desenvolver, revisar ou integrar branches:

1. **Trunk-Based Development com Branches Curtas**:
   - Crie branches de curta duração (menos de 2 dias de vida) a partir da branch principal (`main`).
   - Integre alterações frequentemente usando *Feature Flags* para desacoplar deploy de release.
2. **Commits Atômicos & Conventional Commits**:
   - Cada commit deve representar uma única alteração lógica coesa.
   - Siga a especificação: `tipo(escopo opcional): descrição no presente imperativo` (ex: `feat(auth): add pkce support for mobile login`).
3. **Rebase Interativo para Histórico Linear**:
   - Atualize sua branch local com `git fetch origin && git rebase origin/main` para evitar commits de merge poluídos (`Merge branch 'main' into feature`).
4. **Resolução Cirúrgica de Conflitos**:
   - Resolva conflitos mantendo o histórico original intacto e validando testes unitários logo após cada passo do rebase.
5. **Automação de Versões (Semantic Release)**:
   - Gere tags automáticas e Changelogs sem intervenção manual baseando-se nos prefixos dos commits (`fix:` ➔ PATCH, `feat:` ➔ MINOR, `feat!:` / `BREAKING CHANGE:` ➔ MAJOR).

---

## 2. Snippets Canônicos de Referência

### 2.1. Fluxo de Atualização com Rebase Limpo
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

### 2.2. Padronização de Conventional Commits
```text
feat(billing): add stripe webhook signature verification

- Implement HMAC-SHA256 signature verification with timingSafeEqual
- Add 5-minute timestamp tolerance against replay attacks
- Include unit tests covering invalid signature scenarios

Closes #142
```

### 2.3. Limpeza de Histórico Local com Rebase Interativo
```bash
# Agrupa ou edita os últimos 3 commits antes de abrir o Pull Request
git rebase -i HEAD~3

# No editor que abrir:
# pick a1b2c3d feat(cart): add cart repository
# squash e4f5g6h fix typo in cart model       <- Junta com o commit anterior
# squash i7j8k9l fix lint errors               <- Junta com o commit anterior
```

---

## 3. Armadilhas Críticas no Git (*Gotchas*)

- ⚠️ **`git push --force` sem `--force-with-lease`**: Usar `--force` cego sobrescreve e destrói commits que outro desenvolvedor possa ter enviado para a branch remota. Use sempre `--force-with-lease`.
- ⚠️ **Commits de Merge Cruzados (`Merge branch 'main' into 'feature'`)**: Misturar merges de sincronização com merges de entrega torna o `git bisect` ineficaz e polui a árvore histórica. Prefira `git rebase origin/main`.
- ⚠️ **Commits Gigantescos não Atômicos**: Misturar refatoração de código, mudança de formatação (linter) e nova regra de negócio no mesmo commit impede a realização de *Cherry-picks* e *Rollbacks* seguros em produção.

---

## 4. Padrão de Entrega do Agente

Ao fornecer instruções ou comandos Git:
1. Recomende sempre comandos seguros com `--force-with-lease`.
2. Forneça mensagens de commit formatadas estritamente de acordo com o padrão *Conventional Commits*.
3. Oriente a execução de testes automatizados imediatamente após qualquer resolução de conflitos.
