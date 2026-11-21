# Modelos de ADR (`sk-adr`)

## 1. Formato curto

````markdown
# ADR-007: Usar UUIDv7 como identificador de pedidos

> Status: Proposto | Data: 2026-10-11

## Contexto
IDs sequenciais expõem o volume de pedidos e dificultam a geração em múltiplos serviços.

## Decisão
Adotar UUIDv7 gerado na aplicação.

## Consequências
- Positivas: geração descentralizada e ordenação temporal aproximada.
- Negativas: índices maiores e IDs menos legíveis em suporte.
````

---

## 2. Formato completo

````markdown
# ADR-005: Transactional Outbox para eventos financeiros

> Status: Proposto | Data: 2026-09-27
> Decisores: Arquitetura e Backend | Substitui: n/a
> Relacionados: [Spec 003](../specs/003-cobranca-recorrente.md), T-012

## Contexto e forças
O serviço de pagamentos grava a transação no PostgreSQL e depois publica no Kafka. Se a rede falha entre os dois passos, o banco confirma e o evento se perde (dual-write), gerando inconsistência silenciosa. Restrições: sem aumento de infraestrutura neste trimestre; equipe conhece SQL, não conhece Debezium.

## Critérios de decisão
Consistência, complexidade operacional, prazo, domínio da equipe, custo.

## Decisão
Implementar **Transactional Outbox** com relay por polling: a mutação e o evento são gravados na tabela `outbox_events` na mesma transação; um worker lê com `SELECT ... FOR UPDATE SKIP LOCKED` e publica no Kafka, com garantia at-least-once.

## Alternativas avaliadas

| Opção | Prós | Contras |
| :--- | :--- | :--- |
| Status quo (escrita dupla) | Nada a construir | Perde eventos em falha |
| Two-phase commit (XA) | Atomicidade forte | Latência e bloqueios distribuídos |
| Outbox com CDC (Debezium) | Baixa latência, sem polling | Componente novo, curva de aprendizado |
| **Outbox com polling (escolhida)** | Simples, usa o que a equipe domina | Latência de segundos, carga de leitura no banco |

## Consequências
- Positivas: nenhum evento perdido em falha de rede; latência do Kafka fora da rota HTTP.
- Negativas: consumidores precisam ser idempotentes; novo worker para operar; latência de publicação na ordem de segundos `(estimativa)`.

## Verificação e revisão
- Como garantir: teste de integração que derruba o broker e confere a entrega; checklist de PR para toda mutação financeira.
- Reavaliar quando o volume passar de `(estimativa)` 500 eventos/s ou a latência de publicação virar requisito.
````
