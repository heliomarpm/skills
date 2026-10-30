---
name: sk-sql
description: "Orienta modelagem relacional, escrita e otimização de consultas SQL, indexação, transações e concorrência, migrações seguras sem downtime e diagnóstico de lentidão em bancos relacionais (PostgreSQL como referência; MySQL e SQL Server com ressalvas). Use sempre que o usuário pedir 'modele o banco', 'otimize esta query', 'crie o índice', 'migration', 'EXPLAIN', 'paginação', 'deadlock', 'transação', 'corrija estes dados' ou 'por que a consulta está lenta', mesmo sem a palavra 'SQL'. NÃO use para NoSQL ou cache, para o uso de ORMs (isso é a sk-tech-* da stack), para contratos de API (isso é sk-api-design), para arquitetura (isso é sk-system-design) nem para infraestrutura e backup (isso é sk-devops)."
allowed-tools: Read, Edit, Write, Grep, Glob
---

# SQL: dados relacionais corretos, rápidos e migráveis

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-sql`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Sem shell.** A skill não executa SQL. Passe o comando ao usuário e analise a saída que ele colar. `EXPLAIN ANALYZE` **executa** a consulta: em `INSERT`, `UPDATE` ou `DELETE`, envolva em transação com `ROLLBACK`.

**Dialeto.** Detecte o banco e a ferramenta de migração do projeto (Flyway, Liquibase, Prisma, Entity Framework, Alembic etc.) e siga-os. Os exemplos são PostgreSQL; a skill indica o que não é portável.

**Operações destrutivas.** Nenhum DDL ou DML destrutivo sem pedido explícito. Dados reais em desenvolvimento são mascarados.

**Evidência.** Recomendações de desempenho citam o plano, a estatística ou a medição observada. Sem dado, é hipótese; não invente ganhos percentuais.

**Idioma.** O do usuário; nomes de tabelas e colunas seguem o projeto.

---

## 1. Modos de operação

| Modo | Quando |
| :--- | :--- |
| **Modelar** | Tabelas, tipos, constraints e relacionamentos |
| **Consultar e otimizar** | Escrever ou acelerar consultas e índices |
| **Migrar** | Mudar o esquema com segurança (seção 6) |
| **Revisar** | Avaliar esquema, consultas ou migrações existentes |

---

## 2. Workflow

1. **Contexto**: leia `DATA.md`, `ARCHITECTURE.md`, os ADRs, o esquema e as migrações existentes.
2. Aplique a seção do modo.
3. Para desempenho, peça o plano (`EXPLAIN (ANALYZE, BUFFERS)`) e a definição das tabelas e índices antes de opinar.
4. Entregue DDL e consultas parametrizadas, com o script de rollback das migrações.
5. Registre as pendências (seção 9).

---

## 3. Modelagem

- **OLTP**: normalize até 3NF; desnormalize apenas com motivo medido (leitura intensiva, relatórios).
- **Tipos**: `NUMERIC(p,s)` para dinheiro (nunca `FLOAT`), `timestamptz` para instantes, texto com limite quando houver regra, estratégia de ID explícita (bigint sequencial ou UUIDv7).
- **Constraints**: `NOT NULL`, `CHECK`, `UNIQUE` e chaves estrangeiras sempre que a regra for do dado.
- **`ON DELETE`**: `RESTRICT` por padrão; `CASCADE` só quando a filha não tem vida própria.
- **Soft delete**: use com índices parciais (`WHERE deleted_at IS NULL`) e unicidade que o considere.
- **Multitenancy**: `tenant_id` em toda tabela de dados e, quando fizer sentido, *row-level security*.
- **Privacidade**: minimização de dados, retenção e anonimização conforme a LGPD.

---

## 4. Consultas e índices

### 4.1. Paginação por cursor (keyset)

Offset grande lê e descarta linhas. O keyset usa um índice e o custo não cresce com a profundidade da página. Exige ordenação **única** (desempate por `id`), colunas `NOT NULL` ou NULL tratado, e cursor opaco (o par codificado).

```sql
-- Índice: (created_at DESC, id DESC)
SELECT id, total, created_at
FROM orders
WHERE created_at < :ultimo_created_at
   OR (created_at = :ultimo_created_at AND id < :ultimo_id)
ORDER BY created_at DESC, id DESC
LIMIT 20;
```

A forma expandida é portável. No PostgreSQL, a comparação de linhas `(created_at, id) < (:a, :b)` é equivalente e também usa o índice; MySQL e SQL Server exigem a forma expandida.

### 4.2. Índices

```sql
-- Parcial: indexa só o que a consulta usa
CREATE INDEX idx_orders_pendentes ON orders (created_at) WHERE status = 'PENDING';

-- Cobertura (PostgreSQL 11+ e SQL Server; não existe no MySQL)
CREATE INDEX idx_users_email ON users (email) INCLUDE (name, is_active, role);

-- Expressão: para filtrar por lower(email)
CREATE INDEX idx_users_email_lower ON users (lower(email));
```

Regras práticas:
- **Ordem das colunas** de um índice composto: igualdades primeiro, depois intervalo e ordenação, conforme as consultas reais. Seletividade ajuda, mas não é a regra única.
- Índice parcial vale também em colunas de baixa cardinalidade, quando o filtro é seletivo.
- Cada índice custa escrita e memória: crie por consulta medida, não por precaução.
- Index-only scan depende do mapa de visibilidade (vacuum em dia).
- Função na coluna filtrada (`WHERE DATE(created_at) = ...`, `WHERE lower(email) = ...`) ignora o índice comum: reescreva como intervalo (atenção ao fuso, use `timestamptz`) ou crie índice de expressão.

---

## 5. Transações e concorrência

- **Isolamento**: conheça o padrão do banco (no PostgreSQL, `READ COMMITTED`). Use `REPEATABLE READ` ou `SERIALIZABLE` quando a regra exigir e **tente de novo** em falha de serialização (código `40001`).
- **Transações curtas**; nunca faça chamadas externas dentro delas.
- **Otimista** (coluna `version`) para baixa contenção; **pessimista** (`SELECT ... FOR UPDATE`) para alta contenção.
- **Deadlocks**: trave vários registros sempre na mesma ordem (por chave primária).

### Fila de tarefas com `SKIP LOCKED` e lease

`SKIP LOCKED` evita que workers bloqueiem uns aos outros, mas não garante ordem estrita nem recupera um worker que caiu. O *lease* devolve o job à fila:

```sql
UPDATE job_queue
SET status = 'PROCESSING',
    locked_until = now() + interval '5 minutes',
    attempts = attempts + 1
WHERE id = (
  SELECT id FROM job_queue
  WHERE (status = 'QUEUED' AND scheduled_at <= now())
     OR (status = 'PROCESSING' AND locked_until < now())
  ORDER BY priority DESC, scheduled_at
  LIMIT 1
  FOR UPDATE SKIP LOCKED
)
RETURNING *;
```

Ao concluir, o worker marca `DONE`. Acima de um limite de `attempts`, o job vai para `DEAD` (DLQ), com alerta (`sk-observability`).

---

## 6. Migrações seguras

Princípios: **expand and contract** (o código novo e o antigo convivem com o esquema nos dois estados), uma mudança por migração, bloqueios curtos e **script de rollback** em todas. Teste a migração em um banco com volume realista.

```sql
SET lock_timeout = '3s';                              -- DDL falha rápido em vez de travar a tabela

-- 1. Expand: coluna nova, nullable (sem reescrever a tabela)
ALTER TABLE orders ADD COLUMN currency char(3);

-- 2. Backfill em lotes (repita até 0 linhas)
UPDATE orders SET currency = 'BRL'
WHERE id IN (SELECT id FROM orders WHERE currency IS NULL LIMIT 5000);

-- 3. Constraint sem travar, depois validação
ALTER TABLE orders ADD CONSTRAINT orders_currency_nn CHECK (currency IS NOT NULL) NOT VALID;
ALTER TABLE orders VALIDATE CONSTRAINT orders_currency_nn;

-- 4. Índice sem bloquear escritas (fora de transação)
CREATE INDEX CONCURRENTLY idx_orders_currency ON orders (currency);

-- 5. Contract (em um deploy posterior): SET NOT NULL e remoção do código antigo
-- Rollback antes do passo 5: DROP INDEX, ALTER TABLE ... DROP CONSTRAINT / DROP COLUMN
```

Renomear ou remover coluna exige as duas fases em deploys diferentes. A ordem de implantação (migração antes ou depois do código) faz parte do plano (`sk-devops`).

---

## 7. Diagnóstico de lentidão

| Sintoma | Ação (comando para o usuário rodar) |
| :--- | :--- |
| Consulta lenta | `EXPLAIN (ANALYZE, BUFFERS)`; procure varredura sequencial em tabela grande, estimativa muito diferente do real e ordenação em disco |
| Estimativa errada | Estatísticas desatualizadas: `ANALYZE` |
| Qual consulta pesa | `pg_stat_statements` |
| Muitas consultas pequenas | N+1 do ORM: veja o log de consultas |
| Conexões esgotadas | Pool (por exemplo, PgBouncer) e transações longas |
| Tabela inchada | Autovacuum e bloat |

Antes de criar um índice, confirme que a consulta é frequente e relevante.

---

## 8. Segurança e correção de dados

- **Parametrize sempre.** Identificadores dinâmicos (tabela, coluna) só por lista permitida, nunca por concatenação.
- **Privilégio mínimo**: o usuário da aplicação não faz DDL.
- **Correção de dados em produção**: só com pedido explícito, sempre com `WHERE`, contando antes e simulando em transação.

```sql
BEGIN;
SELECT count(*) FROM pedidos WHERE status = 'X' AND criado_em < :limite;      -- confira o alcance
UPDATE pedidos SET status = 'Y' WHERE status = 'X' AND criado_em < :limite;   -- sempre com WHERE
-- confira o "UPDATE n" e uma amostra; então COMMIT ou ROLLBACK
```

---

## 9. Registro via `sk-tasks` e integrações

Se houver pendências, pergunte ao final:

> *"Deseja que eu registre as pendências de banco de dados no `TASKS.md` do projeto?"*

Com a confirmação, acione a skill `sk-tasks` (modo Importar), com origem `sql`, links relativos e a prioridade: risco de perda de dados ou de bloqueio em produção P0; índice ausente em consulta crítica P1; constraints P2; ajustes P3. **Fallback**: lista no chat.

| Skill | Como se integra |
| :--- | :--- |
| `sk-api-design` | Tabela de idempotência e esquema que suporta o contrato |
| `sk-system-design` | Outbox, inbox e filas |
| `sk-security` | Parametrização, permissões e segredos |
| `sk-testing` | Testes de consulta e migração com banco real |
| `sk-devops` | Migrações no deploy |
| `sk-observability` | Consultas lentas e métricas do banco |
| `sk-adr` | Decisões de modelagem e de banco |
| `sk-tech-*` | Uso do ORM, N+1 e migrações da ferramenta |

Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 10. Armadilhas

- **Offset gigante**: lê e descarta milhares de linhas.
- **Keyset sem desempate único**: pula ou repete registros.
- **Índice por precaução**: custa escrita e memória sem benefício medido.
- **Função na coluna filtrada**: inutiliza o índice comum.
- **`NOT NULL` ou índice comum em tabela grande, de uma vez**: trava a tabela. Use as etapas da seção 6.
- **Migração sem rollback.**
- **`EXPLAIN ANALYZE` em DML fora de transação**: altera os dados.
- **`UPDATE` ou `DELETE` sem `WHERE`.**
- **Deadlock por ordem inconsistente de locks.**
- **Fila sem lease**: job preso em `PROCESSING` se o worker cair.
- **SQL montado por concatenação.**
- **`FLOAT` para dinheiro.**

---

## 11. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado (seção 1).
2. DDL e consultas, parametrizadas, com links relativos para os arquivos, e o rollback das migrações.
3. Para desempenho: o plano ou a medição usada e o que foi decidido a partir dele.
4. Ressalvas de portabilidade e premissas sobre o dialeto.
5. Pendências e a pergunta sobre o registro em tarefas (seção 9).