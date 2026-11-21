# Modelo de Referência de `TASKS.md` (`sk-tasks`)

Ilustrativo. Em arquivo existente, adapte-se ao formato dele (seção 3.1 do `SKILL.md`).

````markdown
# Tarefas do Projeto

> **Meta:** autenticação OAuth 2.1 com PKCE e proteção CSRF nas APIs públicas\
> **Status:** em desenvolvimento | **Progresso:** 3/10 (30%) | **WIP:** 1/2 | **Atualizado em:** 2026-10-11

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
