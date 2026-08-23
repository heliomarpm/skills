---
name: database-sql
description: Orienta a modelagem de dados, escrita e otimização de consultas SQL, estratégias de indexação, controle de concorrência e transações em bancos de dados relacionais e NoSQL.
---

# Global Skill: Database Engineering, SQL & Performance Optimization

Diretrizes técnicas especializadas para a modelagem relacional, indexação de alta performance, planos de execução, transações seguras e escalabilidade de dados em bancos como PostgreSQL, MySQL, SQL Server e Redis.

---

## 1. Processo de Execução de Engenharia de Dados

Ao modelar entidades, escrever queries ou diagnosticar lentidão em bancos de dados:

1. **Modelagem & Normalização Criteriosa**: Modele entidades normalizadas (3NF) para consistência transacional (OLTP). Desnormalize com cautela apenas para consultas analíticas de leitura intensiva (OLAP/Read Models).
2. **Análise do Plano de Execução (`EXPLAIN ANALYZE`)**: Antes de aprovar queries críticas, inspecione se há *Sequential Scans* desnecessários em tabelas volumosas e verifique o custo estimado vs real.
3. **Estratégia de Indexação Cirúrgica**: Crie índices compostos respeitando a regra da coluna mais seletiva à esquerda (*Leftmost Prefix Rule*), use índices parciais para filtros comuns e índices GIN para colunas JSONB ou busca textual.
4. **Controle de Concorrência & Níveis de Isolamento**: Escolha entre *Optimistic Locking* (via coluna `version` / `rowversion`) ou *Pessimistic Locking* (`SELECT ... FOR UPDATE SKIP LOCKED`) de acordo com o nível de contenção de escrita.
5. **Paginação Eficiente**: Substitua paginação baseada em `OFFSET` por paginação por cursor (*Keyset Pagination* baseada no último ID/timestamp indexado).

---

## 2. Snippets Canônicos de Referência

### 2.1. Paginação por Cursor (Keyset Pagination) vs Offset
```sql
-- INCORRETO: OFFSET 100000 escaneia e descarta 100.000 linhas na memória
-- SELECT id, title, created_at FROM orders ORDER BY created_at DESC LIMIT 20 OFFSET 100000;

-- CORRETO: Keyset Pagination com índice em (created_at DESC, id DESC) - Tempo O(1) constante
SELECT id, title, total, created_at
FROM orders
WHERE (created_at, id) < ('2026-08-20 14:30:00', 'ord-987654')
ORDER BY created_at DESC, id DESC
LIMIT 20;
```

### 2.2. Índice Parcial e Índice Cobertor (PostgreSQL)
```sql
-- Índice Parcial: Indexa apenas pedidos que precisam de processamento (tamanho de índice 90% menor)
CREATE INDEX idx_orders_pending_processing 
ON orders (created_at ASC) 
WHERE status = 'PENDING';

-- Índice Cobertor (Covering Index): Evita ida à tabela principal (Index-Only Scan)
CREATE INDEX idx_users_lookup 
ON users (email) 
INCLUDE (name, is_active, role);
```

### 2.3. Fila Transacional Concorrente com `FOR UPDATE SKIP LOCKED`
```sql
-- Consumo concorrente seguro de tarefas sem deadlock e sem lock em lote
WITH next_job AS (
  SELECT id 
  FROM job_queue
  WHERE status = 'QUEUED' AND scheduled_at <= NOW()
  ORDER BY priority DESC, scheduled_at ASC
  LIMIT 1
  FOR UPDATE SKIP LOCKED
)
UPDATE job_queue
SET status = 'PROCESSING', started_at = NOW()
FROM next_job
WHERE job_queue.id = next_job.id
RETURNING job_queue.*;
```

---

## 3. Armadilhas Críticas em Bancos de Dados (*Gotchas*)

- ⚠️ **Paginação com `OFFSET` Gigante**: `OFFSET 50000` força o banco de dados a ler, ordenar e descartar 50.000 registros antes de retornar os próximos 10, gerando picos massivos de I/O em disco e CPU.
- ⚠️ **Índices Excessivos em Tabelas de Alta Escrita**: Cada índice acelera leituras, mas desacelera `INSERT`, `UPDATE` e `DELETE`, além de inflar o consumo de memória RAM do buffer pool. Indexe apenas campos com alta cardinalidade usados em filtros frequentes.
- ⚠️ **Funções em Colunas Filtradas no WHERE**: Fazer `WHERE DATE(created_at) = '2026-08-20'` ou `WHERE LOWER(email) = '...'` inutiliza o índice B-Tree padrão da coluna. Crie um índice baseado em expressão (*Expression Index*) ou reescreva o filtro como intervalo: `WHERE created_at >= '2026-08-20 00:00:00' AND created_at < '2026-08-21 00:00:00'`.
- ⚠️ **Deadlocks por Ordem Inconsistente de Locks**: Se a Transação A bloqueia o Registro 1 e tenta bloquear o Registro 2, enquanto a Transação B bloqueia o Registro 2 e tenta bloquear o Registro 1, ocorre deadlock. Bloqueie múltiplos registros sempre ordenados por chave primária (`ORDER BY id`).

---

## 4. Padrão de Entrega do Agente

Ao entregar consultas SQL, migrações de banco ou modelos de dados:
1. Declare tipos de dados com precisão (ex: `NUMERIC(15,2)` para valores monetários, nunca `FLOAT`).
2. Forneça scripts de DDL contendo chaves primárias, chaves estrangeiras com regras de deleção (`ON DELETE RESTRICT/CASCADE`) e índices correspondentes.
3. Garanta que todas as consultas parametrizem valores dinâmicos.
