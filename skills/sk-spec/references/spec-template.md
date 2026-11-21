# Modelo de Referência de Spec (`sk-spec`)

Ilustrativo, com o conteúdo reduzido. Em uma spec real, mantenha apenas as seções do perfil escolhido (Leve ou Completa).

````markdown
---
id: 003
titulo: Cobrança recorrente
status: rascunho
versao: 0.1.0
atualizado: 2026-10-11
depende-de: []
substitui: null
substituida-por: null
---

# Spec 003: Cobrança recorrente

## 1. Visão geral
**Objetivo:** permitir assinaturas com cobrança mensal automática.
**Dentro do escopo:** criação, cancelamento e cobrança de assinaturas via cartão.
**Fora de escopo:** boleto recorrente; troca de plano no meio do ciclo.

## 3. Requisitos
- RF-01 (MUST): o sistema cria uma assinatura com `plan_id`, `customer_id` e `start_date`.
- RNF-01 (MUST): a criação de assinatura responde em p95 abaixo de 300 ms com 200 req/s.

## 7. Critérios de aceite
- CA-01 (cobre RF-01)
  - Given um cliente ativo e um plano válido
  - When ele envia `POST /subscriptions`
  - Then recebe `201` e a assinatura com `status: active`
- CA-02 (cobre RF-01, caso de erro)
  - Given um `plan_id` inexistente
  - When ele envia `POST /subscriptions`
  - Then recebe `404` com `code: PLAN_NOT_FOUND`

## 9. Premissas, dependências, riscos e perguntas em aberto
- Premissa: o gateway de pagamento já existe e expõe tokenização de cartão.
- [A CONFIRMAR] Política de retentativa após falha de cobrança.

## 11. Rastreabilidade
| Requisito | Critério | Teste | Tarefa |
| :--- | :--- | :--- | :--- |
| RF-01 | CA-01, CA-02 | | T-01 |

## 13. Histórico de alterações
| Versão | Data | Tipo | Resumo |
| :--- | :--- | :--- | :--- |
| 0.1.0 | 2026-10-11 | criação | Primeira versão |
````
