---
name: api-design
description: Orienta o design de contratos de APIs, especificações RESTful, OpenAPI 3.1, padrões de idempotência, paginação, segurança de webhooks e comunicação síncrona/assíncrona.
---

# Global Skill: API Design, Contracts & Integration Architecture

Diretrizes técnicas especializadas para o design de APIs públicas e privadas, especificações rigorosas de contratos (OpenAPI 3.1), mecanismos de idempotência e protocolos modernos de integração.

---

## 1. Processo de Execução de Design de APIs

Ao planejar, modelar ou expor novos endpoints:

1. **Abordagem Contract-First**: Modele o contrato de entrada e saída (OpenAPI 3.1 / JSON Schema) antes de escrever o código dos controllers.
2. **Nomenclatura Semântica & Recursos REST**:
   - Use substantivos no plural para recursos (`/api/v1/pedidos`, `/api/v1/usuarios/{id}/transacoes`).
   - Use verbos HTTP padronizados (`GET` para leitura pura, `POST` para criação/ações complexas, `PUT` para substituição total, `PATCH` para atualização parcial, `DELETE` para remoção).
3. **Idempotência em Mutações Críticas**: Implemente o cabeçalho `Idempotency-Key` (UUIDv4) para transações financeiras, cobranças e operações de mutação não repetíveis.
4. **Padronização de Erros**: Retorne 100% dos erros no formato **RFC 7807 (Problem Details)** com códigos HTTP semânticos (400, 401, 403, 404, 409, 422, 429, 500).
5. **Segurança de Webhooks**: Assine todos os eventos enviados para clientes com HMAC-SHA256 no cabeçalho `X-Signature-SHA256` acompanhado de um timestamp `X-Timestamp` para mitigar ataques de repetição (*Replay Attacks*).

---

## 2. Snippets Canônicos de Referência

### 2.1. Padrão de Idempotência com Chave e Redis (Exemplo TypeScript)
```typescript
import { Request, Response, NextFunction } from 'express';
import Redis from 'ioredis';

const redis = new Redis();

export async function idempotencyMiddleware(req: Request, res: Response, next: NextFunction) {
  const idempotencyKey = req.header('Idempotency-Key');
  if (!idempotencyKey) return next();

  const cacheKey = `idempotency:${idempotencyKey}`;
  const cachedResponse = await redis.get(cacheKey);

  if (cachedResponse) {
    const { status, body, headers } = JSON.parse(cachedResponse);
    return res.status(status).set(headers).set('X-Cache-Lookup', 'HIT').json(body);
  }

  // Intercepta a resposta original para salvar no Redis
  const originalJson = res.json.bind(res);
  res.json = (body: any) => {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      redis.set(cacheKey, JSON.stringify({
        status: res.statusCode,
        body,
        headers: { 'Content-Type': 'application/json' }
      }), 'EX', 86400); // Expira em 24h
    }
    return originalJson(body);
  };

  next();
}
```

### 2.2. Assinatura e Verificação Segura de Webhooks (HMAC-SHA256)
```typescript
import crypto from 'node:crypto';

export function generateWebhookSignature(payload: string, secret: string, timestamp: number): string {
  const signaturePayload = `${timestamp}.${payload}`;
  return crypto.createHmac('sha256', secret).update(signaturePayload).digest('hex');
}

export function verifyWebhookSignature(
  payload: string,
  signature: string,
  secret: string,
  timestamp: number,
  toleranceSeconds = 300
): boolean {
  // 1. Mitigação de Replay Attack: valida se o evento é recente (ex: max 5 minutos)
  const now = Math.floor(Date.now() / 1000);
  if (Math.abs(now - timestamp) > toleranceSeconds) {
    return false;
  }

  // 2. Comparação segura contra Timing Attacks
  const expectedSignature = generateWebhookSignature(payload, secret, timestamp);
  const signatureBuffer = Buffer.from(signature, 'utf-8');
  const expectedBuffer = Buffer.from(expectedSignature, 'utf-8');

  if (signatureBuffer.length !== expectedBuffer.length) return false;
  return crypto.timingSafeEqual(signatureBuffer, expectedBuffer);
}
```

---

## 3. Armadilhas Críticas em APIs (*Gotchas*)

- ⚠️ **Mutações Não Idempotentes em Redes Instáveis**: Quando um cliente envia um `POST /api/v1/pagamentos` e a conexão cai antes de receber a resposta, o cliente costuma reenviar. Sem `Idempotency-Key`, a cobrança ocorre em duplicidade.
- ⚠️ **Timing Attacks na Validação de Assinaturas/Tokens**: Usar `signature === expectedSignature` simples vaza informações sobre o tempo de comparação de strings. Use sempre funções de tempo constante (`crypto.timingSafeEqual`).
- ⚠️ **Vazamento de Detalhes Internos em Erros**: Retornar stacktraces de banco de dados ou exceções internas em respostas HTTP de produção facilita a exploração de vulnerabilidades. Responda com IDs de correlação (`traceId`) e mensagens sanitizadas.

---

## 4. Padrão de Entrega do Agente

Ao entregar designs ou implementações de API:
1. Especifique os métodos HTTP, rotas, cabeçalhos obrigatórios e códigos de status esperados.
2. Defina contratos de entrada e saída completos no formato JSON Schema / OpenAPI.
3. Inclua sempre suporte a paginação por cursor em endpoints de listagem.

---

## 5. 📝 Planejamento de Endpoints com `task-management` (Sempre ao Final)

Sempre ao término do design, modelagem ou especificação de contratos de APIs (OpenAPI, endpoints, webhooks), **pergunte obrigatoriamente ao usuário ao final da resposta**:

> *"Concluí o design dos contratos da API. Deseja que eu registre as tarefas de implementação e testes no arquivo `TASKS.md` do projeto?"*

Ao receber a confirmação do usuário (ou se instruído a planejar automaticamente):
1. **Ativação da Skill**: Acione a skill **`task-management`** para estruturar o backlog dos endpoints.
2. **Localização em Cascata**: A skill `task-management` buscará por `./TASKS.md` ➔ `./agents/TASKS.md` ➔ `./.agents/TASKS.md` (com tolerância a `TASK.md` / `task.md`).
3. **Mapeamento de Tarefas de API**:
   - `🚨 1. Bloqueadores / Alta Prioridade`: Middleware de autenticação/autorização (OAuth 2.1 / PKCE), validação de schemas de entrada e idempotência (`Idempotency-Key`).
   - `⚠️ 2. Média Prioridade`: Implementação dos endpoints CRUD, controllers, rotas e tratamento de erros RFC 7807.
   - `💡 3. Baixa Prioridade / Otimização`: Paginação por cursor (Keyset), rate limiting e documentação Swagger UI interativa.
   - `✅ 4. Concluído recentemente`: Especificações OpenAPI e contratos JSON Schemas finalizados na sessão com `- [x]`.
4. **Navegabilidade**: Toda tarefa deve indicar as rotas e os arquivos de contrato ou controllers correspondentes (`[arquivo.ext](file:///...)`).
