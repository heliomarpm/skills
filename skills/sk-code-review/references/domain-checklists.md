# Checklists de Domínio para Revisão de Código (Eixo 2)

Use este checklist enxuto para revisar o diff no Eixo 2 sem carregar múltiplas skills inteiras. Abra a skill completa da área apenas se o diff exigir desenho profundo ou diagnóstico especializado.

## 1. Segurança (`sk-security`)
- **Autorização por recurso (BOLA/IDOR)**: toda rota ou handler que recebe ID valida posse/permissão do chamador; nunca confiar apenas em autenticação.
- **Injeções e entrada**: queries parametrizadas (sem concatenação SQL), schemas validados na borda, caminhos confinados (anti-path-traversal), escape de HTML/XSS.
- **Segredos e dados**: zero chaves, tokens ou senhas no código ou logs; valores sensíveis mascarados (`sk-****`); sem PII em logs ou respostas de erro.
- **Criptografia e web**: Argon2id/bcrypt para senhas (nunca MD5/SHA-1/SHA-256); cookies `HttpOnly`/`Secure`/`SameSite`; comparação em tempo constante para tokens/assinaturas HMAC.

## 2. Banco de dados e SQL (`sk-sql`)
- **Queries novas**: verificar `WHERE`, `JOIN`, `ORDER BY` e `GROUP BY`; exigir confirmação de performance e entrega do script/migration de **índices adequados** (com rollback).
- **N+1 e paginação**: evitar consultas em laço, `EAGER` acidental e `JOIN FETCH` com paginação em memória; preferir projeção direta e paginação por cursor (keyset) em listas grandes.
- **Segurança de migrations**: padrão *expand and contract*, índices `CONCURRENTLY` (sem travar tabela em produção), `lock_timeout` curto e script de rollback.
- **Integridade**: dinheiro com `NUMERIC`/`Decimal`/centavos (nunca `float`); `UPDATE`/`DELETE` sempre com `WHERE`; transações curtas sem chamadas externas.

## 3. Contratos de API e Mensageria (`sk-api-design`, `sk-system-design`)
- **Compatibilidade**: remoção/renomeação de campo ou mudança de tipo/status quebra consumidores; exige versionamento ou convivência.
- **Erros e idempotência**: respostas de erro em Problem Details (RFC 9457), sem stack trace interno; mutações críticas com `Idempotency-Key` atômica no banco; webhooks validados sobre o **corpo bruto**.
- **Confiabilidade**: timeouts definidos em clientes HTTP/broker; consumidores de eventos idempotentes; sem dual-write desprotegido quando perder evento é crítico.

## 4. Observabilidade e Operação (`sk-observability`, `sk-devops`)
- **Logs e métricas**: logs estruturados correlacionados (`trace_id`), sem PII e sem alta cardinalidade em rótulos de métrica (`user_id`, `order_id`).
- **Saúde e shutdown**: liveness não consulta dependências externas; graceful shutdown drena conexões.
- **Contêineres e CI**: imagem não root, sem segredos em `ARG`/`ENV`, actions por SHA, permissões mínimas no workflow.

## 5. Testes (`sk-testing`)
- **Cobertura comportamental**: caminho feliz, bordas e ao menos um caso de falha; asserções específicas (não apenas "não nulo").
- **Determinismo e isolamento**: zero `sleep` fixo, sem dependência de relógio do sistema ou ordem de execução; dublês apenas nas fronteiras; testes de regressão ou referência aos IDs `CA-NN` quando houver spec.

## 6. Design System e Acessibilidade (`sk-design-system`)
- **Tokens**: sem cores ou espaçamentos fixos espalhados quando o projeto usa tokens semânticos.
- **WCAG 2.2 AA**: elementos nativos (`button`, `a`, `dialog`), `:focus-visible`, rótulos associados, `aria-invalid`/`aria-describedby` em formulários, estados carregando/vazio/erro tratados.
