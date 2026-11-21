# Padrões de Resiliência e Consistência (`sk-system-design`)

## 1. Outbox com relay (PostgreSQL)

```sql
CREATE TABLE outbox_events (
  id             uuid PRIMARY KEY,           -- gerado na aplicação
  aggregate_type text        NOT NULL,
  aggregate_id   text        NOT NULL,
  event_type     text        NOT NULL,
  payload        jsonb       NOT NULL,
  created_at     timestamptz NOT NULL DEFAULT now(),
  published_at   timestamptz,
  attempts       int         NOT NULL DEFAULT 0
);
CREATE INDEX outbox_pendentes_idx ON outbox_events (created_at) WHERE published_at IS NULL;

-- Produtor: regra de negócio e evento na MESMA transação
BEGIN;
INSERT INTO orders (id, customer_id, total, status) VALUES (:id, :cliente, :total, 'CREATED');
INSERT INTO outbox_events (id, aggregate_type, aggregate_id, event_type, payload)
VALUES (:evento_id, 'Order', :id, 'OrderCreated', :payload);
COMMIT;

-- Relay: lote em transação curta
SELECT id, aggregate_id, event_type, payload
FROM outbox_events
WHERE published_at IS NULL
ORDER BY created_at
LIMIT 100
FOR UPDATE SKIP LOCKED;
-- publica no broker, com aggregate_id como chave; depois:
UPDATE outbox_events SET published_at = now() WHERE id = ANY(:ids);
```

Notas: se o relay cair entre publicar e atualizar, o evento sai de novo (at-least-once), por isso os consumidores precisam ser idempotentes. Com vários relays, `SKIP LOCKED` pode alterar a ordem; se a ordem por agregado importa, particione os relays por hash de `aggregate_id` ou use um só. Limpe periodicamente os publicados antigos.

## 2. Consumidor idempotente (inbox)

```sql
-- Mesma transação do efeito no domínio
BEGIN;
INSERT INTO processed_events (event_id, processed_at)
VALUES (:event_id, now())
ON CONFLICT (event_id) DO NOTHING;
-- 0 linhas inseridas: evento duplicado. COMMIT e ignore.
-- 1 linha inserida: aplique o efeito no domínio (UPDATE ou INSERT).
COMMIT;
```

Notas: a deduplicação e o efeito precisam estar na mesma transação; gravar a chave antes e apagá-la no erro perde eventos se o processo cair no meio. Se o efeito é externo (e-mail, pagamento), use uma chave de idempotência no sistema externo. Redis com `SET NX` serve só para deduplicação *best-effort* de efeitos não críticos.

## 3. Cache sem tempestade (stampede)

```text
funcao obter(chave):
    valor = cache.get(chave)
    se valor existe e nao expirou: retorne valor
    retorne singleFlight(chave, () ->
        valor = origem.carregar(chave)
        cache.set(chave, valor, ttl = base + aleatorio(0, jitter))
        retorne valor)
```

`singleFlight` deixa uma única chamada regenerar a chave enquanto as demais aguardam. Alternativas: servir o valor antigo enquanto revalida, ou expiração antecipada probabilística. TTL é obrigatório, cache nunca é fonte de verdade, e a invalidação, o cache negativo e a taxa de acertos fazem parte do desenho.
