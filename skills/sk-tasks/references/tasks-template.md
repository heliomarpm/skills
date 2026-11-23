# Modelo de Referência de `TASKS.md` (`sk-tasks`)

Ilustrativo. Em arquivo existente, adapte-se ao formato dele (seção 3.1 do `SKILL.md`).

````markdown
# Tarefas do Projeto

> **Meta:** autenticação OAuth 2.1 com PKCE e proteção CSRF nas APIs públicas\
> **Organização:** Prioridade simples | **Status:** em desenvolvimento | **Progresso:** 3/10 (30%) | **WIP:** 1/2 | **Atualizado em:** 2026-10-11

## Em progresso

- [ ] **T-004 · P1 · Implementar middleware de validação do code challenge (PKCE)**
  - Origem: spec 003 / T-02 | Dep.: T-003
  - Ref: [auth_middleware.ts](./src/middlewares/auth_middleware.ts)
  - DoD:
    - [x] Validar desafio SHA-256 em tempo constante
    - [ ] Rejeitar requisição sem `code_verifier` válido
    - [ ] Testes unitários com os vetores da RFC 7636

## Bloqueadas

- [ ] **T-009 · P3 · [BLOQUEADA] Adicionar métricas Prometheus de tokens emitidos e revogados**
  - Origem: discovery | Dep.: nenhuma
  - Bloqueio: stack de observabilidade ainda não decidida. Ação: definir com a equipe.

## Backlog

### Alta Prioridade

- [ ] **T-005 · P0 · Validar `redirect_uri` contra a whitelist no callback**
  - Origem: bug | Dep.: nenhuma
  - Ref: [callback_handler.ts](./src/handlers/callback_handler.ts#L45-L60)
  - DoD: URIs fora da whitelist ou sem `https://` retornam `400`; teste cobre os dois casos.
- [ ] **T-003 · P1 · Repositório Redis para armazenamento transitório de tokens**
  - Origem: spec 003 / T-01 | Dep.: nenhuma

### Média Prioridade

- [ ] **T-006 · P2 · Endpoint `/oauth/v2/token` (RFC 6749)**
  - Origem: spec 003 / T-03 | Dep.: T-003, T-004
- [ ] **T-007 · P2 · Rota de revogação `/oauth/v2/revoke` (RFC 7009)**
  - Origem: spec 003 / T-04 | Dep.: T-006

### Baixa Prioridade

- [ ] **T-008 · P3 · Trocar o hash síncrono por Argon2id nativo**
  - Origem: discovery | Dep.: nenhuma
- [ ] **T-010 · P3 · Documentar o fluxo de autenticação no README**
  - Origem: discovery | Dep.: nenhuma

## Rascunhos

> Ideias embrionárias sem escopo fechado (fora da contagem de progresso e sem ID `T-NNN` até promoção).

- Avaliar suporte a Passkeys / WebAuthn após estabilizar o fluxo PKCE *(origem: manual)*
- Estudar limite de sessões simultâneas por usuário *(origem: discovery)*

## Concluídas recentemente

- [x] **T-002 · P1 · Entidade `AuthorizationCode` com TTL e uso único** (2026-10-09)
  - Arquivos: [authorization_code.ts](./src/domain/authorization_code.ts)
  - Evidência: testes passaram (informado pelo usuário)
- [x] **T-001 · P1 · DTOs imutáveis de Token Request e Token Response** (2026-10-08)
- [x] **T-000 · P2 · Setup de testes unitários com Vitest** (2026-10-07)
  - Arquivos: [vitest.config.ts](./vitest.config.ts)

## Canceladas

(nenhuma)
````

---

## Exemplo de atualização: concluir a `T-004`

```diff
-> Status: em desenvolvimento | Progresso: 3/10 (30%) | WIP: 1/2 | Atualizado em: 2026-10-11
+> Status: em desenvolvimento | Progresso: 4/10 (40%) | WIP: 0/2 | Atualizado em: 2026-10-12

 ## Em progresso
-
-- [ ] **T-004 · P1 · Implementar middleware de validação do code challenge (PKCE)**
-  - Origem: spec 003 / T-02 | Dep.: T-003
+
+(nenhuma)

 ## Concluídas recentemente
+
+- [x] **T-004 · P1 · Implementar middleware de validação do code challenge (PKCE)** (2026-10-12)
+  - Arquivos: [auth_middleware.ts](./src/middlewares/auth_middleware.ts)
+  - Evidência: testes passaram (resultado na conversa)
```

---

## Pergunta de criação inicial

Apresente quando não existir `TASKS.md` e o usuário não tiver definido o formato nem pedido criação direta no padrão:

```markdown
Não encontrei um `TASKS.md` neste repositório. Antes de criar o arquivo inicial, escolha como prefere organizar o **Backlog** (o arquivo também incluirá a seção opcional **Rascunhos** para ideias embrionárias fora da contagem de progresso):

1. **Prioridade simples — Alta / Média / Baixa (`P0`–`P3`)** *(recomendado)* — menor atrito para o dia a dia.
2. **Matriz de Eisenhower (`Urgente × Importante`)** — 4 quadrantes: *Fazer agora*, *Agendar*, *Delegar/Automatizar* e *Avaliar/Eliminar*.
3. **Ações Prioritárias (`Impacto × Esforço`)** — 4 quadrantes: *Ganhos rápidos*, *Projetos estratégicos*, *Tarefas de apoio* e *Evitar/Reavaliar*.
4. **Matriz GUT (`Gravidade × Urgência × Tendência`)** — pontuação `1`–`125` em faixas; ideal para filas de bugs, incidentes e problemas operacionais.
5. **Now / Next / Later (`Agora / Próximo / Depois`)** — roadmaps contínuos sem prazo fixo.
6. **MoSCoW (`Must / Should / Could / Won't`)** — releases ou entregas de escopo fechado.

Responda com o número (ex.: `2`), o nome da opção ou `padrão` para seguir com a opção **1**. *(Se preferir sem a seção `## Rascunhos`, avise na mesma resposta.)*
```

---

## Modelos alternativos de organização do Backlog

Substitua as subseções de `## Backlog` conforme a escolha do cabeçalho, mantendo `T-NNN` e `P0`–`P3` na tarefa:

### 2. Matriz de Eisenhower (`Organização: Matriz de Eisenhower`)

```markdown
## Backlog

### Q1 · Fazer agora (Urgente + Importante)
- [ ] **T-005 · P0 · Validar `redirect_uri` contra a whitelist no callback**
  - Origem: bug | Dep.: nenhuma

### Q2 · Agendar (Importante, não urgente)
- [ ] **T-006 · P2 · Endpoint `/oauth/v2/token` (RFC 6749)**
  - Origem: spec 003 / T-03 | Dep.: T-003, T-004

### Q3 · Delegar / Automatizar (Urgente, menor importância)
(nenhuma)

### Q4 · Avaliar / Eliminar (Baixa urgência e importância)
- [ ] **T-010 · P3 · Revisar texto de ajuda secundária no README**
  - Origem: discovery | Dep.: nenhuma
```

### 3. Ações Prioritárias — Impacto × Esforço (`Organização: Ações Prioritárias (Impacto × Esforço)`)

```markdown
## Backlog

### Ganhos rápidos (Alto Impacto · Baixo Esforço)
- [ ] **T-005 · P0 · Validar `redirect_uri` contra a whitelist no callback**
  - Origem: bug | Dep.: nenhuma

### Projetos estratégicos (Alto Impacto · Alto Esforço)
- [ ] **T-006 · P2 · Endpoint `/oauth/v2/token` (RFC 6749)**
  - Origem: spec 003 / T-03 | Dep.: T-003, T-004

### Tarefas de apoio (Baixo Impacto · Baixo Esforço)
- [ ] **T-010 · P3 · Documentar variáveis de ambiente no README**
  - Origem: discovery | Dep.: nenhuma

### Evitar / Reavaliar (Baixo Impacto · Alto Esforço)
(nenhuma)
```

### 4. Matriz GUT (`Organização: Matriz GUT`)

```markdown
## Backlog

### Crítico (GUT 64–125)
- [ ] **T-005 · P0 · GUT 100 (5×5×4) · Validar `redirect_uri` contra a whitelist no callback**
  - Origem: bug | Dep.: nenhuma

### Alto (GUT 27–63)
- [ ] **T-003 · P1 · GUT 36 (4×3×3) · Repositório Redis para tokens transitórios**
  - Origem: spec 003 / T-01 | Dep.: nenhuma

### Moderado (GUT 8–26)
- [ ] **T-006 · P2 · GUT 18 (3×3×2) · Endpoint `/oauth/v2/token` (RFC 6749)**
  - Origem: spec 003 / T-03 | Dep.: T-003, T-004

### Baixo (GUT 1–7)
(nenhuma)
```

### 5. Now / Next / Later (`Organização: Now / Next / Later`)

```markdown
## Backlog

### Agora
- [ ] **T-005 · P0 · Validar `redirect_uri` contra a whitelist no callback**
  - Origem: bug | Dep.: nenhuma

### Próximo
- [ ] **T-006 · P2 · Endpoint `/oauth/v2/token` (RFC 6749)**
  - Origem: spec 003 / T-03 | Dep.: T-003, T-004

### Depois
- [ ] **T-008 · P3 · Trocar o hash síncrono por Argon2id nativo**
  - Origem: discovery | Dep.: nenhuma
```

### 6. MoSCoW (`Organização: MoSCoW`)

```markdown
## Backlog

### Must
- [ ] **T-005 · P0 · Validar `redirect_uri` contra a whitelist no callback**
  - Origem: bug | Dep.: nenhuma

### Should
- [ ] **T-006 · P2 · Endpoint `/oauth/v2/token` (RFC 6749)**
  - Origem: spec 003 / T-03 | Dep.: T-003, T-004

### Could
- [ ] **T-008 · P3 · Trocar o hash síncrono por Argon2id nativo**
  - Origem: discovery | Dep.: nenhuma

### Won't
(nenhuma)
```
