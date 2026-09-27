---
name: code-review
description: Realiza revisão técnica bidimensional de código e Pull Requests (especificação/escopo vs qualidade/segurança) executada em subagentes paralelos, com severidades, diffs acionáveis e geração automática de TASKS.md.
---

# Code Review Skill: Bidimensional & Rigorous Engineering Review

Esta skill conduz revisões técnicas aprofundadas comparando o `HEAD` com um ponto fixo (branch base, commit, tag ou PR) sob dois eixos independentes executados em **subagentes paralelos** para evitar contaminação de contexto:

- **Eixo 1 — Especificação e Escopo (Spec)**: O código atende estritamente à tarefa/issue solicitada? Há requisitos faltantes ou complexidade desnecessária não solicitada (*scope creep*)?
- **Eixo 2 — Engenharia, Segurança e Padrões (Standards & Quality)**: O código é seguro (OWASP), performático (N+1, concorrência), livre de *code smells* e segue os padrões do repositório?

---

## 1. Processo de Execução

### 1.1. Definição do Ponto Fixo e Obtenção do Diff
1. Identifique o ponto fixo de comparação indicado pelo usuário (ex: `main`, `origin/main`, `HEAD~5` ou SHA de commit). Se omitido, use a branch principal (`main` ou `master`).
2. Valide o ponto fixo via `git rev-parse <ponto-fixo>`.
3. Capture o diff e histórico:
   - `git diff <ponto-fixo>...HEAD` (três pontos para comparar a partir da base de merge comum).
   - `git log <ponto-fixo>..HEAD --oneline` (lista de commits da alteração).

### 1.2. Descoberta de Fontes de Especificação e Padrões
- **Especificação**: Issues citadas nos commits (`#123`, `Closes #45`), arquivos em `docs/`, `specs/` ou instruções diretas do usuário.
- **Padrões**: Documentos de estilo (`CONTRIBUTING.md`, `CODING_STANDARDS.md`), regras ativas e a **Linha de Base de Code Smells** (abaixo).

---

## 2. Execução em Subagentes Paralelos

Inicie ambos os subagentes em paralelo com contextos isolados:

### 🤖 Subagente 1: Especificação e Escopo (Spec)
**Foco**: Fidelidade à solicitação e integridade do escopo.
- **(a) Requisitos Faltantes**: Itens da issue/especificação que não foram implementados.
- **(b) Expansão de Escopo (*Scope Creep*)**: Códigos, funcionalidades ou abstrações criadas que não foram solicitadas.
- **(c) Implementações Incorretas**: Regras de negócio implementadas com divergência em relação ao requisito original.

### 🤖 Subagente 2: Engenharia, Segurança e Padrões (Standards)
**Foco**: Rigor técnico, robustez, segurança e design de código.

#### Diretrizes de Engenharia & Segurança:
1. **Segurança (OWASP)**: Zero chaves/tokens gravados no código, consultas SQL parametrizadas contra injeções, validação de schemas de entrada e validação de permissões antes da execução.
2. **Performance & Recursos**: Prevenção de consultas N+1, liberação obrigatória de streams/listeners (`dispose`), chamadas I/O não bloqueantes e paginação em listagens.
3. **Banco de Dados & APIs**: Migrações seguras com zero downtime (*Expand & Contract*) e retrocompatibilidade de contratos públicos (RFC 7807).

#### Linha de Base de Code Smells (Martin Fowler - *Refactoring*):
- **Mysterious Name**: Nomes de funções, variáveis ou classes que não revelam sua intenção.
- **Duplicated Code**: Blocos de lógica repetidos em mais de um trecho da alteração.
- **Feature Envy**: Métodos que acessam mais dados de objetos externos do que os seus próprios.
- **Data Clumps**: Grupos de parâmetros ou campos que sempre aparecem juntos (tipo que precisa ser criado).
- **Primitive Obsession**: Uso de strings/números primitivos para conceitos que exigem tipos de domínio.
- **Shotgun Surgery**: Uma única mudança lógica que forçou pequenas edições espalhadas por múltiplos arquivos.
- **Speculative Generality**: Abstrações ou ganchos adicionados para cenários hipotéticos não solicitados.
- **Middle Man**: Classes ou funções que apenas repassam a chamada adiante sem adicionar valor.
- **Refused Bequest**: Subclasses que rejeitam/ignoram a maior parte dos métodos herdados (prefira composição).

---

## 3. Níveis de Severidade dos Apontamentos

- **`[Bloqueador/Crítico]`**: Vulnerabilidades de segurança, corrupção de dados, regressão de funcionalidade central, quebra de build/testes ou quebra de contrato público sem retrocompatibilidade.
- **`[Importante/Major]`**: Requisitos da issue ausentes, problemas sérios de performance (N+1), violações graves de camadas arquiteturais ou falta de testes essenciais.
- **`[Melhoria/Minor]`**: *Code smells*, refatorações de legibilidade, simplificação de lógica ou melhorias de tipagem.
- **`[Sugestão/Nitpick]`**: Preferências cosméticas e micro-otimizações opcionais.

---

## 4. Relatório Consolidado de Entrega

O relatório final deve consolidar os resultados de ambos os eixos sem misturá-los:

```markdown
### 📋 Resumo Executivo da Revisão
- **Veredito Geral**: [Aprovado | Aprovado com Ressalvas | Alterações Solicitadas (Bloqueante)]
- **Eixo 1 (Spec/Escopo)**: [Aprovado / Reprovado] — (ex: 1 requisito pendente)
- **Eixo 2 (Standards/Qualidade)**: [Aprovado / Reprovado] — (ex: 2 apontamentos)

---

### 🎯 Eixo 1: Especificação e Escopo (Spec)
- **Status dos Requisitos**: [Síntese da aderência à issue/especificação]
- **Apontamentos de Escopo**:
  - `[Importante]` [Falta validação de limite de crédito conforme item 3 da especificação]
  - `[Sugestão]` [Identificada criação de endpoint auxiliar não solicitado na issue]

---

### 🛡️ Eixo 2: Engenharia, Segurança e Padrões (Standards)

#### 1. [Severidade] Título do Apontamento
- **Localização**: `caminho/do/arquivo.ext:L15-L28`
- **Diagnóstico**: [Explicação técnica do problema, risco OWASP ou code smell identificado]
- **Sugestão de Correção**:
```diff
- trecho_atual()
+ trecho_corrigido()
```

---

### 💡 Destaques Positivos
- [Reconheça boas práticas aplicadas e soluções elegantes adotadas no PR]
```

---

## 5. 📝 Geração e Atualização de `TASKS.md` via `task-management` (Sempre ao Final)

Sempre ao término da revisão técnica, se houver qualquer apontamento (bloqueadores, requisitos faltantes, *code smells* ou débitos técnicos), **pergunte obrigatoriamente ao usuário ao final do relatório**:

> *"Foram identificados apontamentos na revisão. Deseja que eu registre ou atualize essas pendências no arquivo `TASKS.md` do projeto?"*

Ao receber a confirmação do usuário (ou caso tenha sido solicitado o registro automático):
1. **Ativação da Skill**: Acione a skill **`task-management`** para conduzir o processo de escrita/atualização.
2. **Localização em Cascata**: A skill `task-management` buscará automaticamente por `./TASKS.md` ➔ `./agents/TASKS.md` ➔ `./.agents/TASKS.md` (com tolerância a `TASK.md` / `task.md`), evitando criação de arquivos concorrentes.
3. **Mapeamento de Severidades**:
   - `🚨 1. Bloqueadores / Alta Prioridade`: Itens do Eixo 2 marcados como `[Bloqueador/Crítico]` (vulnerabilidades, falhas de segurança, quebra de contratos públicos).
   - `⚠️ 2. Média Prioridade`: Itens do Eixo 1 (`[Requisitos Faltantes]`) e Eixo 2 marcados como `[Importante/Major]`.
   - `💡 3. Baixa Prioridade / Otimização`: *Code smells*, refatorações de legibilidade e apontamentos `[Melhoria/Minor]`.
   - `✅ 4. Concluído recentemente`: Itens já resolvidos durante o review marcados com `- [x]`.
4. **Navegabilidade e Rastreabilidade**: Todas as tarefas cadastradas devem conter link markdown navegável (`[arquivo.ext](file:///...)`) e critérios claros de ação corretiva.