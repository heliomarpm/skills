# Exemplos de API Design (`sk-api-design`)

## 1. Tabela de idempotência transacional (PostgreSQL)

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

## 2. Verificação de assinatura HMAC em Webhook (sobre o corpo bruto)

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

## 3. Contrato OpenAPI 3.1 com Problem Details e Idempotência

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
