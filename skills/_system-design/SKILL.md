---
name: _system-design
description: Orienta a arquitetura de sistemas distribuídos, padrões de mensageria assíncrona (RabbitMQ, Kafka), Transactional Outbox, Saga Pattern, estratégias de cache e resiliência.
---

# Global Skill: Distributed Systems & Scalable System Design

Diretrizes técnicas especializadas para o design de sistemas distribuídos de alta escala, mensageria assíncrona, consistência eventual e padrões de resiliência.


> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧭 **Skill Ativa**: `_system-design``

---

## 1. Processo de Execução de System Design

Ao projetar sistemas distribuídos ou desacoplar microsserviços:

1. **Requisitos Não Funcionais & Trade-offs**: Identifique claramente as metas de SLA/SLO, taxa de requisições por segundo (RPS), latência aceitável e tolerância a inconsistência temporária (Teorema CAP / PACELC).
2. **Desacoplamento Assíncrono com Mensageria**: Escolha a ferramenta correta:
   - **RabbitMQ / SQS**: Para roteamento flexível de mensagens pontuais e filas de trabalho (*Task Queues*).
   - **Apache Kafka / AWS Kinesis**: Para streaming contínuo de eventos ordenados por chave com múltiplos consumidores (*Event Sourcing / Log Streams*).
3. **Padrão Transactional Outbox**: Nunca grave no banco de dados e publique em uma fila no mesmo método sem uma transação unificada. Grave o evento na tabela `outbox` dentro da mesma transação local do banco de dados e use um worker para publicar.
4. **Idempotência no Consumidor (*Idempotent Consumer*)**: Todo consumidor de fila deve ser idempotente, tolerando o recebimento duplicado da mesma mensagem (*At-least-once delivery*).
5. **Estratégias de Caching Distribuído**: Utilize *Cache-Aside* com TTL obrigatório e trate o problema de *Cache Stampede* através de *Locks distribuídos* ou *Probabilistic Early Expiration* (XFetch).

---

## 2. Snippets Canônicos de Referência

### 2.1. Padrão Transactional Outbox (PostgreSQL + Worker)
```sql
-- 1. Transação atômica única: salva a regra de negócio E o evento na Outbox
BEGIN;

INSERT INTO orders (id, customer_id, total, status)
VALUES ('ord-123', 'cust-456', 250.00, 'CREATED');

INSERT INTO outbox_events (id, aggregate_type, aggregate_id, event_type, payload, status)
VALUES (
  gen_random_uuid(),
  'Order',
  'ord-123',
  'OrderCreated',
  '{"orderId": "ord-123", "customerId": "cust-456", "total": 250.00}'::jsonb,
  'PENDING'
);

COMMIT;
```

### 2.2. Consumidor Idempotente com Deduplicação no Redis
```typescript
import Redis from 'ioredis';

const redis = new Redis();

interface EventMessage {
  eventId: string;
  type: string;
  data: any;
}

export async function processEventSafely(event: EventMessage, handler: (data: any) => Promise<void>) {
  const lockKey = `processed_event:${event.eventId}`;

  // Tenta registrar a chave no Redis (apenas se não existir - SET NX) com TTL de 7 dias
  const isNewEvent = await redis.set(lockKey, 'PROCESSED', 'EX', 60 * 60 * 24 * 7, 'NX');

  if (!isNewEvent) {
    console.log(`[Deduplicação] Evento ${event.eventId} já foi processado anteriormente. Ignorando.`);
    return;
  }

  try {
    await handler(event.data);
  } catch (error) {
    // Se o processamento falhar, remove a chave para permitir reprocessamento pela DLQ
    await redis.del(lockKey);
    throw error;
  }
}
```

---

## 3. Armadilhas Críticas em Sistemas Distribuídos (*Gotchas*)

- ⚠️ **Dual-Write Problem**: Salvar no banco de dados e logo em seguida chamar `producer.send()` sem o padrão *Outbox*. Se a publicação na fila falhar ou o processo cair no meio, o banco fica atualizado mas a fila nunca recebe o evento, gerando inconsistência silenciosa irreparável.
- ⚠️ **Ausência de Dead Letter Queue (DLQ)**: Uma mensagem com payload corrompido que falha continuamente em um consumidor sem DLQ entra em loop infinito de retry, travando toda a partição da fila (*Poison Message*).
- ⚠️ **Cache Stampede (Thundering Herd no Cache)**: Quando uma chave de cache muito acessada expira ao mesmo tempo que milhares de requisições chegam simultaneamente, todas as conexões atingem o banco de dados de uma vez. Use *Early Expiration* ou *Mutex Locks* de regeneração.

---

## 4. Padrão de Entrega do Agente

Ao propor designs de sistemas ou integrações distribuídas:
1. Apresente diagramas textuais claros de fluxo entre componentes.
2. Identifique explicitamente a garantia de entrega da mensageria (*At-least-once*, *At-most-once*).
3. Inclua sempre mecanismos de deduplicação e tratamento de falhas com Dead Letter Queues (DLQ).

---

## 5. 📝 Decomposição do Roadmap com `_task-management` (Sempre ao Final)

Sempre ao término de uma proposta ou desenho de arquitetura de sistemas distribuídos, **pergunte obrigatoriamente ao usuário ao final da resposta**:

> *"Concluí o desenho da arquitetura. Deseja que eu decomponha a implementação em etapas e tarefas no arquivo `TASKS.md` do projeto?"*

Ao receber a confirmação do usuário (ou se instruído a decompor automaticamente):
1. **Ativação da Skill**: Acione a skill **`_task-management`** para realizar a criação ou atualização do backlog da arquitetura.
2. **Localização em Cascata**: A skill `_task-management` buscará por `./TASKS.md` ➔ `./agents/TASKS.md` ➔ `./.agents/TASKS.md` (com tolerância a `TASK.md` / `task.md`).
3. **Mapeamento das Etapas da Arquitetura**:
   - `🚨 1. Bloqueadores / Alta Prioridade`: Provisionamento da infraestrutura base (tabelas Outbox, tópicos/filas principais, migrações de banco com zero downtime).
   - `⚠️ 2. Média Prioridade`: Implementação de producers, consumers idempotentes com deduplicação, Dead Letter Queues (DLQ) e workers assíncronos.
   - `💡 3. Baixa Prioridade / Otimização`: Camada de caching com TTL, métricas de observabilidade distribuída e dashboards de monitoramento.
   - `✅ 4. Concluído recentemente`: Marcos e contratos já finalizados e validados na sessão com `- [x]`.
4. **Navegabilidade**: Cada tarefa cadastrada deve manter referências diretas com links navegáveis aos arquivos ou schemas propostos (`[arquivo.ext](file:///...)`).
