# Referência: NoSQL e Cache (`sk-sql`)

Consulte este guia quando o sistema persistir dados fora do modelo relacional (MongoDB/documentos, DynamoDB/chave-valor, Redis/cache).

## 1. Critério de escolha antes de sair do relacional
- Se o dado exige transações ACID entre várias entidades, joins frequentes ou consultas *ad-hoc*, prefira o banco relacional (`sk-adr` + `sk-system-design`).
- Adote NoSQL ou cache quando houver padrão de acesso bem conhecido (chave-valor, documento agregado, TTL, contagem de alta taxa, feed) ou necessidade medida de escala horizontal.

---

## 2. Bancos de documentos (MongoDB)

### Modelagem: embed vs referência
- **Embed** quando os filhos pertencem exclusivamente ao pai, têm cardinalidade **limitada e previsível** (ex.: itens de um pedido, endereços de entrega) e são lidos juntos.
- **Referência** quando o array cresce sem limite (ex.: logs, comentários ilimitados, eventos de auditoria — estoura o limite de 16 MB do BSON e fragmenta o documento) ou quando a entidade é compartilhada e atualizada de forma independente.

### Índices obrigatórios e regra ESR
Para toda nova consulta (`find`, `aggregate`), analise filtros, ordenações e paginação, confira `explain("executionStats")` (não aceite `COLLSCAN` em coleções grandes) e **entregue o script de criação do índice + rollback**:

- **Ordem ESR** em índices compostos:
  1. **E**quality (`status: "PAID"`) — campos com igualdade estrita;
  2. **S**ort (`createdAt: -1, _id: -1`) — ordenação, com desempate único;
  3. **R**ange (`amount: { $gte: 100 }`) — intervalos (`$gt`, `$lt`, `$in` amplo).
- **Índices parciais e TTL**: use `partialFilterExpression` para indexar só documentos ativos (`deletedAt: null`) e `expireAfterSeconds` para expiração automática.
- **Projeção explícita**: peça somente os campos necessários e limite o retorno; use cursor (`createdAt`/`_id`) em vez de `skip()` alto.

```javascript
// Criação (script idempotente / migration)
db.orders.createIndex(
  { tenantId: 1, status: 1, createdAt: -1, _id: -1 },
  {
    name: "idx_orders_tenant_status_created",
    partialFilterExpression: { deletedAt: null },
    background: true // em MongoDB < 4.2; em 4.2+ o build ja e otimizado por padrão
  }
);

// Rollback obrigatório
// db.orders.dropIndex("idx_orders_tenant_status_created");
```

---

## 3. Chave-valor e tabela única (DynamoDB)
- **Desenho guiado pelas queries (Access Patterns)**: liste todas as leituras antes de modelar `PK` (Partition Key) e `SK` (Sort Key).
- **Evite *hot partitions***: `PK` precisa de alta cardinalidade e distribuição uniforme (nunca `status` ou `data` isolados como `PK`). Use sufixo *sharded* (`EVENT#2026-11#shard-04`) se houver pico em uma chave.
- **Proíba `Scan` em produção**: toda consulta operacional usa `GetItem` ou `Query` sobre a tabela base ou um **GSI/LSI** dedicado.
- **Projeção em GSI**: projete apenas `KEYS_ONLY` ou `INCLUDE` estrito para evitar duplicação excessiva de armazenamento e RCU/WCU.
- **Paginação**: use `ExclusiveStartKey` (keyset nativo) e trate `LastEvaluatedKey` em consultas que filtram após a leitura.

---

## 4. Redis e padrões de cache

### Estruturas certas e higiene de comandos
| Caso de uso | Estrutura | Armadilha a evitar |
| :--- | :--- | :--- |
| Cache de objeto/JSON, rate limit simples | `String` (`SET k v EX ttl`) | Gravar sem `TTL` e vazar memória até eviction descontrolado |
| Sessão, atributos parciais | `Hash` (`HSET` / `HGETALL`) | Hashes gigantes com dezenas de milhares de campos |
| Fila curta / buffer limitado | `Stream` (`XADD ... MAXLEN ~ N`) | Lista sem limite crescendo indefinidamente |
| Ranking, janelas temporais, filas agendadas | `Sorted Set` (`ZADD` / `ZRANGE`) | Esquecer limpeza de membros antigos |
| Deduplicação de IDs / tags | `Set` (`SADD` / `SISMEMBER`) | Chave única global concentrando todo o tráfego em cluster |

- **Proíba `KEYS *` e `FLUSHALL`/`FLUSHDB` em produção**: bloqueiam a thread principal do Redis. Use `SCAN` iterativo com `COUNT` limitado.
- **Use `UNLINK` em vez de `DEL`** para chaves grandes (desaloca memória em background).

### TTL, stampede e política de eviction
- **TTL obrigatório com *jitter***: some aleatoriedade (ex.: `300s + random(0..45s)`) para evitar expiração em massa no mesmo segundo (*thundering herd*).
- **Stampede protection**: combine TTL curto em cache com *singleFlight* por chave na aplicação (detalhes em `sk-system-design`).
- **Eviction conforme papel do Redis**:
  - Cache puro: `allkeys-lru` ou `allkeys-lfu`.
  - Fila, sessão crítica ou lock distribuído: **instância separada** com `noeviction` (falha explicitamente se lotar, em vez de apagar sessões ou locks silenciosamente!).
- **Lock distribuído**: exige valor aleatório por dono + `SET key token NX PX ms` + liberação atômica via Lua/Compare-and-Delete; para exclusão mútua estrita em escritas críticas, o recurso protegido deve validar um **fencing token** monotônico (`sk-system-design`).

---

## 5. Armadilhas específicas
- **`COLLSCAN` / `Scan` em tabela ou coleção de produção**: degrada latência e esgota IOPS conforme o volume cresce.
- **Índice composto fora da ordem ESR no MongoDB**: o índice não cobre ordenação nem evita varredura parcial pesada.
- **Array sem limite em documento BSON**: degrada escrita por realocação e atinge o teto de 16 MB.
- **Misturar fila/lock com cache LRU no mesmo Redis**: eviction silencioso derruba locks ativos e sessões.
- **`KEYS *` em produção**: congela todas as outras requisições no servidor Redis.
- **Nova consulta NoSQL sem script/migration de índice e rollback entregues.**
