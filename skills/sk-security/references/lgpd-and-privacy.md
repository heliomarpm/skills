# Privacidade e LGPD (Lei 13.709/2018) na Engenharia de Software

Referência complementar da `sk-security`. Leia ao projetar fluxos com dados pessoais, revisar multitenancy, definir políticas de retenção ou implementar direitos dos titulares no código.

---

## 1. Classificação técnica dos dados no código

| Categoria | Exemplos típicos | Exigência prática na arquitetura |
| :--- | :--- | :--- |
| **Dado pessoal** | Nome, e-mail, CPF, endereço IP ligado a usuário, ID de sessão | Base legal mapeada, acesso por menor privilégio, prazo de retenção |
| **Dado pessoal sensível** (Art. 5º, II) | Biometria, saúde, origem racial/étnica, orientação sexual, convicção religiosa/política | Segregação explícita, criptografia em repouso/trânsito, auditoria de leitura e acesso restrito |
| **Dado de criança/adolescente** | Cadastro escolar, perfil infantil | Fluxo explícito de consentimento parental verificável e minimização máxima |
| **Pseudonimizado** | ID interno opaco ou hash HMAC com *pepper* secreto (reversível com chave/tabela) | Continua sujeito à LGPD; chave/tabela de vínculo fica em cofre isolado |
| **Anonimizado** | Agregações irreversíveis sem possibilidade razoável de reidentificação | Único formato seguro para analytics público, benchmarks e retenção indefinida |

---

## 2. Minimização e *Privacy by Design*

1. **Colete o mínimo necessário ao caso de uso**: se o sistema precisa apenas validar maioridade ou unicidade de CPF, armazene flag booleana ou HMAC-SHA256 com *pepper* em KMS, não o documento em claro quando evitável.
2. **Separe identidade de eventos/métricas**: tabelas analíticas e eventos de fila carregam identificadores internos opacos (`user_id` UUID) em vez de nome, e-mail ou documento no payload.
3. **Nunca exponha PII em URLs ou query strings**: parâmetros de URL vão parar em logs de proxy, histórico de navegador e cabeçalhos `Referer`. Envie identificadores em cabeçalho ou corpo TLS.
4. **Cuidado com campos de texto livre e anexos**: campos de observação e uploads frequentemente recebem CPFs, telefones ou fotos de documentos; aplique retenção, controle de acesso por objeto assinado (URLs temporárias de expiração curta) e nunca buckets públicos.

---

## 3. Consentimento auditável e finalidades

Quando a base legal for **consentimento** (ou compartilhamento opcional), armazene registro imutável (append-only) contendo:
- `subject_id` (identificador interno do titular);
- `purpose_key` (finalidade específica e granular — proibido aceite genérico agrupado);
- `policy_version` (versão exata ou hash do termo exibido);
- `granted` (`true`/`false`), timestamp em UTC, canal de origem e IP/agente apenas pelo tempo necessário à prova;
- Endpoint/mecanismo simples de **revogação** em paridade com o de aceite.

---

## 4. Direitos do titular no sistema (Art. 18)

Ao projetar endpoints ou rotinas administrativas para direitos do titular:

- **Acesso e portabilidade**: gere exportação estruturada (JSON/CSV) de forma assíncrona se volumosa, filtrada estritamente pelo `subject_id` autenticado (nunca permitir BOLA/IDOR mudando o ID da requisição), mascarando credenciais e excluindo segredos internos de negócio.
- **Retificação**: propague atualização para índices de busca, caches e projeções eventuais sem deixar nome/e-mail antigo preso em cache por tempo indeterminado.
- **Exclusão e anonimização em cascata**:
  1. Verifique antes o que possui **retenção legal obrigatória** (ex.: notas fiscais, registros contábeis, logs antifraude com base legal distinta): esses registros ficam bloqueados apenas para o fim legal, separados do uso comercial/marketing.
  2. Para todo o restante, execute anonimização irreversível (`UPDATE users SET name = 'Anonimizado', email = ..., deleted_at = NOW()`) mantendo integridade referencial sem quebrar histórico agregado de pedidos, ou exclua fisicamente.
  3. Dispare invalidação em **caches (Redis)**, **índices de busca**, **filas mortas (DLQ)** e **provedores externos** (e-mail, CRM, gateway) por evento idempotente.
  4. Documente como backups rotativos expiram por janela fixa (ex.: 30 dias) e garanta processo para não reativar dados excluídos após restauração de backup (*suppression list* com hash irreversível).

---

## 5. Logs, telemetria, IA e terceiros

- **Logs e traces (`sk-observability`)**: configure redação automática para chaves sensíveis (`cpf`, `password`, `token`, `authorization`, `cookie`, `email`, `phone`) na camada de serialização do logger — não dependa da memória de cada dev.
- **Prompts e LLMs (`sk-ai-engineering`)**: remova ou pseudonimize PII antes de enviar contexto para provedores externos de IA, valide política de retenção zero (*zero data retention*) e nunca grave prompts com dados pessoais em logs abertos.
- **Multitenancy (`sk-sql`)**: todo filtro de consulta, chave de cache, prefixo de objeto em storage e índice de busca deve incluir `tenant_id` explícito (ou Row-Level Security ativo e testado), com testes negativos automatizados tentando acesso cruzado entre tenants.

---

## 6. Checklist rápido de auditoria LGPD

- [ ] Existe mapeamento de quais tabelas/campos guardam dado pessoal e sensível (`DATA.md` ou catálogo equivalente)?
- [ ] Cada tabela com PII tem política explícita de **TTL/expurgo** automatizada e idempotente?
- [ ] Logs de aplicação, acesso HTTP, erros e traces mascaram CPF, e-mail, tokens e payloads sensíveis?
- [ ] Exportação e exclusão de titular tratam caches, filas, anexos e integrações terceiras sem quebrar obrigação legal fiscal?
- [ ] Consultas multitenant isolam `tenant_id` no servidor (jamais vindo de campo manipulável no corpo sem validação de posse)?
- [ ] Consentimentos registram versão do termo, finalidade específica, data UTC e permitem revogação efetiva?
