---
name: -api-design
description: "Projeta e revisa contratos de API: OpenAPI 3.1 contract-first, convenções REST, erros em Problem Details (RFC 9457), idempotência, paginação, concorrência (ETag), versionamento e depreciação, webhooks assinados e contratos de eventos (AsyncAPI). Use sempre que o usuário pedir 'projete a API', 'modele o contrato', 'OpenAPI', 'endpoint', 'webhook', 'Idempotency-Key', 'paginação', 'versione a API', 'isto quebra o contrato?' ou revisar uma API, mesmo sem dizer 'design'. NÃO use para autenticação e autorização em profundidade (isso é -security), mensageria e arquitetura (isso é -system-design), esquema de banco (isso é -sql) nem para implementar controllers."
allowed-tools: Read, Edit, Write, Grep, Glob
---

# API Design: contratos claros, seguros e evolutivos

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativa**: `-api-design`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Escopo de escrita.** A skill escreve **contratos** (OpenAPI, AsyncAPI, JSON Schema), por padrão em `docs/api/openapi.yaml` ou no arquivo já existente. Não implementa controllers nem altera código de aplicação.

**Siga o projeto.** Respeite as convenções existentes (idioma das rotas, camelCase ou snake_case, estilo de versionamento). A decisão de design é do usuário: apresente opções e recomende uma.

**Sem segredos.** Exemplos usam valores fictícios.

**Idioma.** O do usuário; nomes de rotas e campos seguem o projeto.

---

## 1. Modos de operação

| Modo | Quando |
| :--- | :--- |
| **Projetar** | API ou endpoint novo |
| **Evoluir** | Mudar API existente sem quebrar consumidores (seção 7) |
| **Revisar** | Avaliar um contrato contra este guia |
| **Documentar** | Gerar ou completar o OpenAPI a partir do que existe |

---

## 2. Workflow

1. **Contexto**: leia o OpenAPI existente, `AGENTS.md`, `GUIDELINE.md`, ADRs e a spec relacionada. Se o projeto usa Spectral ou oasdiff, siga as regras e use-os para checar compatibilidade.
2. **Requisitos**: consumidores, volume, necessidade de idempotência, autenticação, SLA.
3. **Contrato primeiro**: escreva o OpenAPI 3.1 antes do código (seção 10).
4. **Revise** contra as convenções (seção 3) e a compatibilidade (seção 7).
5. **Entregue** o contrato, as decisões em aberto e as integrações (seção 11).

---

## 3. Convenções

- **Recursos**: substantivos no plural (`/v1/pedidos`, `/v1/clientes/{id}/pedidos`). Verbos HTTP: `GET` leitura, `POST` criação e ações, `PUT` substituição, `PATCH` atualização parcial (JSON Merge Patch), `DELETE` remoção.
- **Status**: 400 requisição malformada, 401 não autenticado, 403 sem permissão, 404 não encontrado, 409 conflito de estado, 412 `If-Match` falhou, 422 validação semântica, 429 limite excedido.
- **Paginação**: cursor (keyset) para listas grandes ou mutáveis, com `limit` máximo e `nextCursor`. Offset é aceitável em listas pequenas ou administrativas. Documente a ordenação.
- **Concorrência**: `ETag` na leitura e `If-Match` na escrita para evitar atualizações perdidas.
- **Operações longas**: `202 Accepted` com um recurso de status consultável.
- **Rate limit**: `429` com `Retry-After`; cabeçalhos de limite documentados.
- **Dados**: datas em ISO 8601 UTC; dinheiro como inteiro (menor unidade) ou string decimal, nunca float; IDs opacos.
- **Autorização por recurso**: toda rota que recebe um ID valida que o chamador pode acessá-lo (BOLA/IDOR). Detalhes no `-security`.

---

## 4. Erros: Problem Details (RFC 9457)

Todos os erros usam `application/problem+json` (a RFC 9457 substitui a 7807), sem stack traces nem detalhes internos; correlacione por `traceId`.

```json
{
  "type": "https://api.exemplo.com/problemas/plano-nao-encontrado",
  "title": "Plano não encontrado",
  "status": 404,
  "detail": "O plano informado não existe.",
  "instance": "/v1/assinaturas",
  "code": "PLAN_NOT_FOUND",
  "traceId": "9f1c2e7a"
}
```

Para validação, acrescente `errors[]` com campo e motivo.

---

## 5. Idempotência

Exija `Idempotency-Key` em `POST` não repetíveis (cobranças, pedidos). Regras do contrato:

- A chave tem escopo: **cliente + método + rota**. Nunca global.
- Mesma chave com **corpo diferente**: `422`.
- Mesma chave ainda em processamento: `409` com `Retry-After`.
- Repetição de operação concluída: devolve a resposta original gravada.
- Retenção: ~24 horas, com limpeza periódica.

Para operações financeiras, registre a chave **no banco, na mesma transação do efeito**; Redis serve só como best-effort.

```sql
CREATE TABLE idempotency_keys (
  scope           text        NOT NULL,   -- cliente + método + rota
  key             text        NOT NULL,
  request_hash    text        NOT NULL,   -- hash do corpo
  response_status int,
  response_body   jsonb,
  created_at      timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (scope, key)
);
```

```text
Na transação do efeito:
  INSERT (scope, key, hash) ON CONFLICT DO NOTHING
  se inseriu: executa a operação e grava a resposta antes do COMMIT
  senão: lê o registro
    hash diferente  -> 422
    sem resposta    -> 409 (efeito ainda em curso)
    com resposta    -> devolve a resposta gravada
```

A chave única serializa requisições duplicadas simultâneas. Se o efeito é externo ao banco, use um estado `IN_PROGRESS` explícito.

---

## 6. Webhooks

- **Assinatura**: HMAC-SHA256 calculado sobre `timestamp.corpoBruto`, em `X-Signature-SHA256`, com `X-Timestamp` para barrar replay. O receptor verifica sobre o **corpo bruto**, não sobre o JSON reserializado.
- **Entrega**: o receptor responde 2xx rápido e processa de forma assíncrona; o emissor faz retry com backoff e permite reenvio manual.
- **Eventos**: cada evento tem `id` único e `type` versionado; o receptor deduplica pelo `id`.
- **Segredo**: um por cliente, com rotação que aceite dois segredos durante a troca.

```typescript
import { createHmac, timingSafeEqual } from 'node:crypto';

export function verifyWebhook(
  rawBody: Buffer,
  signatureHex: string,
  secret: string,
  timestamp: number,
  toleranceSeconds = 300,
): boolean {
  const now = Math.floor(Date.now() / 1000);
  if (Math.abs(now - timestamp) > toleranceSeconds) return false;

  const expected = createHmac('sha256', secret)
    .update(`${timestamp}.`)
    .update(rawBody)
    .digest();
  const received = Buffer.from(signatureHex, 'hex');

  return received.length === expected.length && timingSafeEqual(received, expected);
}
```

---

## 7. Versionamento e depreciação

- **Quebra de contrato (breaking)**: remover ou renomear campo ou rota, tornar opcional em obrigatório, mudar tipo ou semântica, restringir valores, mudar código de status.
- **Compatível**: adicionar campo opcional na resposta, nova rota, novo valor em enum que o cliente tolera.
- Siga o estilo de versão do projeto (caminho `/v1` ou cabeçalho). Uma quebra exige versão nova ou período de convivência.
- Depreciação: cabeçalhos `Deprecation` e `Sunset`, janela de suporte comunicada e documentada.

---

## 8. Segurança no contrato

Declare os `securitySchemes` do OpenAPI e aplique-os por rota. Autenticação, tokens e autorização em profundidade são do `-security`. Nunca exponha detalhes internos em erros e valide todo schema de entrada.

---

## 9. Eventos assíncronos

Descreva os contratos de eventos em AsyncAPI ou JSON Schema, com versão e regras de compatibilidade. A arquitetura de mensageria (entrega, DLQ, idempotência do consumidor) é do `-system-design`.

---

## 10. Exemplo de OpenAPI 3.1

```yaml
openapi: 3.1.0
info: { title: API de Assinaturas, version: 1.0.0 }
paths:
  /v1/assinaturas:
    post:
      operationId: criarAssinatura
      parameters:
        - name: Idempotency-Key
          in: header
          required: true
          schema: { type: string, maxLength: 255 }
      requestBody:
        required: true
        content:
          application/json:
            schema: { $ref: '#/components/schemas/CriarAssinatura' }
      responses:
        '201':
          description: Criada
          content:
            application/json:
              schema: { $ref: '#/components/schemas/Assinatura' }
        '404': { $ref: '#/components/responses/Problema' }
        '409': { $ref: '#/components/responses/Problema' }
        '422': { $ref: '#/components/responses/Problema' }
components:
  schemas:
    CriarAssinatura:
      type: object
      required: [planoId, clienteId]
      properties:
        planoId: { type: string }
        clienteId: { type: string }
    Assinatura:
      type: object
      required: [id, status]
      properties:
        id: { type: string }
        status: { type: string, enum: [active, canceled] }
    Problema:
      type: object
      required: [type, title, status]
      properties:
        type: { type: string, format: uri }
        title: { type: string }
        status: { type: integer }
        detail: { type: string }
        code: { type: string }
        traceId: { type: string }
  responses:
    Problema:
      description: Erro
      content:
        application/problem+json:
          schema: { $ref: '#/components/schemas/Problema' }
```

---

## 11. Registro via `-tasks` e integrações

Se o design tem etapas de implementação, pergunte ao final:

> *"Deseja que eu registre as tarefas de implementação e testes no `TASKS.md` do projeto?"*

Com a confirmação, acione a skill `-tasks` (modo Importar), com origem `api-design`, links relativos para o contrato e a prioridade: autenticação, validação de entrada e idempotência P1; endpoints e erros P2; paginação, rate limiting e documentação P3. **Fallback**: lista no chat.

| Skill | Como se integra |
| :--- | :--- |
| `-spec` | Alimenta a seção de contratos da spec |
| `-testing` | Testes de contrato contra o OpenAPI |
| `-security` | Autenticação, autorização e BOLA |
| `-system-design` | Eventos, mensageria e resiliência |
| `-sql` | Esquema que suporta o contrato e a idempotência |
| `-adr` | Decisões de versionamento e estilo de API |
| `-code-review` | Usa o contrato para checar compatibilidade |

Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 12. Armadilhas

- **Chave de idempotência global**: vaza respostas entre clientes.
- **Ignorar o corpo da repetição**: mesma chave com payload diferente deve falhar.
- **Idempotência sem atomicidade**: registrar a chave fora da transação do efeito.
- **Webhook verificado sobre JSON reserializado**: a assinatura nunca confere.
- **Comparação de assinatura sem tempo constante.**
- **Erro com detalhes internos**: stack trace ou SQL na resposta.
- **Float para dinheiro.**
- **Mudar tipo ou semântica sem versão**: quebra consumidores.
- **Paginação sem ordenação definida**: resultados instáveis.
- **Rota com ID sem checar o dono**: BOLA.

---

## 13. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado (seção 1).
2. Contrato criado ou alterado, com link relativo, e decisões em aberto.
3. Resultado da checagem de compatibilidade, quando houver contrato anterior.
4. Pendências e a pergunta sobre o registro em tarefas (seção 11).