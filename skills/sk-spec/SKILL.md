---
name: sk-spec
description: "Orienta a criação, revisão e manutenção de especificações no modelo Spec-Driven Development (SDD): specs testáveis, rastreáveis e compreensíveis por IA, com ponto de parada para aprovação antes de qualquer implementação. Use sempre que o usuário pedir para especificar, criar ou atualizar uma spec ou SPEC.md, escrever requisitos, critérios de aceite, contratos de API, modelo de dados ou plano de implementação de uma funcionalidade nova ou de uma mudança relevante, ou mencionar SDD/spec-driven, mesmo que não use a palavra 'spec'. NÃO use para correções simples de bug, ajustes triviais, refatorações sem mudança de comportamento ou perguntas pontuais de código, que seguem direto para a implementação."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(git log *), Bash(git status *), Bash(git ls-files *)
---

# Spec-Driven Development (SDD)

A especificação (comportamento, contratos, dados e regras) é o artefato central: ela vem antes do código, é aprovada pelo usuário e continua sendo a fonte de verdade durante toda a implementação.

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-spec`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Sem código de implementação antes da aprovação.** Enquanto a spec não estiver aprovada, não escreva código de produção nem de teste. São permitidos, e desejáveis, os artefatos que definem o comportamento: contratos de API, schemas JSON, DDL, diagramas Mermaid, tabelas de regras e pseudocódigo de regras de negócio.

**O que conta como aprovação.** Somente confirmação explícita ("aprovado", "pode implementar", "segue com a spec"). Silêncio não vale. "Ok, mas ajusta X" também não vale: aplique o ajuste e peça nova confirmação.

**Idioma.** A spec segue o idioma dos documentos existentes do repositório; se não houver, o do pedido. Identificadores, rotas, nomes de campos e de código ficam no idioma do código.

**Evidência e incerteza.** Não invente comportamento, campos ou nomes que o contexto não sustente. Marque o que depende de decisão do usuário com `[A CONFIRMAR]` e registre na seção de premissas.

---

## 1. Quando usar e qual profundidade adotar

**Use** em funcionalidades novas, mudanças que alteram comportamento, contrato, dados ou escopo, e integrações. **Não use** em correção de bug sem mudança de contrato, ajuste de texto ou estilo, renomeações e refatorações internas: nesses casos, siga direto para a implementação.

Escolha a profundidade pela complexidade e diga qual escolheu:

| Perfil | Quando | Seções |
| :--- | :--- | :--- |
| **Leve** | Feature pequena, baixo risco, sem contrato novo | 1, 3, 7 e 9 (premissas) |
| **Completa** | Feature grande, contratos novos, dados, integração ou alto risco | Todas |

Mantenha cada spec em até ~250 linhas. Se passar disso, proponha dividi-la em specs menores, com dependências explícitas entre elas.

---

## 2. Workflow

### 2.1. Contexto do projeto (passo 0)

Antes de perguntar ou escrever, leia o que existir no repositório: `CONTEXT.md`, `AGENTS.md`, `ARCHITECTURE.md`, `DATA.md`, `GUIDELINE.md` (ou equivalentes como `PROJECT.md`, `DATABASE.md`) e as specs anteriores da pasta de specs. A spec deve partir deles e respeitar as regras e convenções ali registradas. Se não existirem, siga em frente e registre na seção de premissas que a spec foi escrita sem esses documentos.

### 2.2. Entendimento

Se o pedido for vago, apresente no chat um **esboço de escopo** (objetivo, dentro e fora do escopo) e faça de 3 a 5 perguntas objetivas por rodada. Tudo que ficar sem resposta vira premissa registrada ou `[A CONFIRMAR]`. Não encha o usuário de perguntas: o que for dedutível do contexto, deduza e registre.

### 2.3. Destino da spec

- Se o repositório já adota um local (`SPEC.md`, `.agents/specs/`, `docs/specs/`), use-o.
- Se não houver nenhum, pergunte uma vez:

> *"Onde prefere criar a especificação?*  
> *1. Na pasta de documentação (`docs/specs/`)*  
> *2. Na pasta oculta de configuração (`.agents/specs/`)*  
> *3. Na pasta de agentes (`agents/specs/`)*  
> *4. Na raiz como arquivo único (`SPEC.md`)*  
> *(ou informe outro caminho de sua preferência)*"*

Em execução não interativa, use `docs/specs/`.
- Padrão de nome: `<NNN>-<feature-em-kebab-case>.md`, com `NNN` sequencial a partir das specs existentes. Uma spec por feature.

### 2.4. Geração

Escreva a spec com a estrutura da seção 3 e as regras das seções 4 e 5. Salve com `status: rascunho`.

### 2.5. Ponto de parada obrigatório (check-in)

Após gerar, pare. Resuma em poucas linhas o que a spec define, liste as premissas e perguntas em aberto e peça revisão e aprovação explícita. Não avance para código sem ela.

### 2.6. Pós-aprovação

1. Altere o `status` para `aprovada` e registre no histórico.
2. Transforme o plano de implementação em tarefas (seção 7).
3. Implemente seguindo as tarefas; os testes cobrem os critérios de aceite (seção 5).
4. Ao concluir, altere o `status` para `implementada` e confirme que a tabela de rastreabilidade está completa.

### 2.7. Evolução da spec

Se durante a implementação surgir uma limitação técnica ou mudança de rota, atualize a spec **antes** de alterar o código.

- **Ajuste editorial** (correção de texto, exemplo, formatação, esclarecimento sem mudar comportamento): corrija direto e incremente a versão de patch.
- **Mudança material** (altera comportamento, contrato, dados, critérios ou escopo): reapresente ao usuário o que muda e por quê, aguarde aprovação, registre no histórico de alterações e incremente a versão minor (ou major se quebrar contrato).

---

## 3. Estrutura da spec

Cabeçalho de metadados no topo de toda spec:

```yaml
---
id: 003
titulo: Cobrança recorrente
status: rascunho   # rascunho | aprovada | implementada | obsoleta
versao: 0.1.0
atualizado: AAAA-MM-DD
depende-de: []     # ids de outras specs, se houver
---
```

Seções (adapte a profundidade conforme a seção 1):

1. **Visão geral**: objetivo e problema; escopo (dentro); **fora de escopo** (itens explícitos).
2. **Casos de uso**: interação de cada ator (usuário ou sistema) com a funcionalidade.
3. **Requisitos**: funcionais (`RF-NN`) e não funcionais (`RNF-NN`), incluindo desempenho, resiliência, escalabilidade, **segurança** (autenticação, autorização, dados sensíveis) e **observabilidade** (logs, métricas, alertas).
4. **Contratos de integração**: endpoints REST, queries GraphQL, gRPC ou schemas de eventos, com payload de request e response e códigos de status. Considere acionar `sk-api-design` quando o contrato não for trivial.
5. **Modelo de dados**: estrutura de banco, `erDiagram` (Mermaid) ou schemas NoSQL, com tipos, nulabilidade, chaves e índices.
6. **Regras de negócio e casos limite**: lógica condicional, cálculos, tratamento de exceções, concorrência e idempotência quando aplicável.
7. **Critérios de aceite** (`CA-NN`): regras testáveis e binárias, em Given/When/Then.
8. **Impacto no código existente**: módulos e arquivos afetados, compatibilidade com o comportamento atual, migração de dados e plano de rollback. Em projeto legado, esta é a seção que evita surpresas.
9. **Premissas, dependências, riscos e perguntas em aberto**.
10. **Plano de implementação**: etapas técnicas pequenas (`T-NN`), na ordem de execução, cada uma ligada aos requisitos que atende.
11. **Rastreabilidade**: tabela que liga requisito, critério, teste e tarefa.
12. **Glossário**: somente se a spec introduzir termos de domínio novos.
13. **Histórico de alterações**: versão, data, tipo (editorial ou material) e resumo.

---

## 4. Qualidade dos requisitos

- **Atômico**: um comportamento por requisito. Se tiver "e" ligando duas obrigações, divida.
- **Testável**: deve ser possível escrever um teste que passe ou falhe.
- **Prioridade explícita** com os termos da RFC 2119: **MUST** (obrigatório), **SHOULD** (recomendado), **MAY** (opcional).
- **Mensurável**: requisitos não funcionais com número e condição. "Rápido" não vale; "p95 abaixo de 300 ms com 200 req/s" vale.
- **Específico e determinístico**: nomes exatos de campos, tabelas, rotas, enums e códigos de erro. É isto que impede a IA de adivinhar durante a codificação.
- **Comportamento antes de solução**: descreva o quê e só imponha o como quando for uma restrição real (compatibilidade, padrão do projeto, exigência regulatória).

---

## 5. Critérios de aceite e rastreabilidade

- Escreva um cenário Given/When/Then por comportamento, cobrindo o caminho feliz e **ao menos um caso de erro** por requisito relevante.
- Numere tudo com IDs estáveis dentro da spec: `RF-01`, `RNF-01`, `CA-01`, `T-01`. Nunca reutilize um ID removido.
- Cada critério referencia o requisito que cobre. Cada teste automatizado cita o ID do critério no nome ou em comentário.
- Feche a spec com a tabela de rastreabilidade:

| Requisito | Critério | Teste | Tarefa |
| :--- | :--- | :--- | :--- |
| RF-01 | CA-01, CA-02 | `<arquivo ou nome do teste>` | T-03 |

A cobertura 1:1 significa: todo critério de aceite tem pelo menos um teste, e todo teste aponta para um critério. A coluna de teste fica vazia até a implementação.

---

## 6. Ciclo de vida

| Status | Significado | Quem muda |
| :--- | :--- | :--- |
| `rascunho` | Em elaboração ou aguardando revisão | Skill, ao criar |
| `aprovada` | Aprovada explicitamente, pronta para implementar | Skill, após a aprovação do usuário |
| `implementada` | Código e testes concluídos, rastreabilidade completa | Skill, ao fechar o trabalho |
| `obsoleta` | Substituída ou descontinuada | Skill, com confirmação, apontando a spec sucessora |

Specs `implementada` continuam vivas: qualquer mudança futura de comportamento segue a seção 2.7.

---

## 7. Integração com outras skills

| Skill | Quando entra |
| :--- | :--- |
| `sk-discovery` | Em projeto existente sem arquivos de contexto, sugira rodá-lo antes (apenas sugira) |
| `sk-adr` | Quando a spec exigir uma decisão arquitetural relevante |
| `sk-api-design` | Quando a seção de contratos for não trivial |
| `sk-tasks` | Ao fim do plano de implementação, **com confirmação do usuário**, para registrar as tarefas |
| `sk-testing` | Após a aprovação, para gerar testes a partir dos critérios de aceite |
| `sk-challenge` | Antes da spec, para testar a ideia em profundidade; o resumo vira insumo dos requisitos e das premissas |
| `sk-alignment` | Documento para o cliente confirmar o entendimento, com a spec em rascunho; as respostas voltam como mudanças propostas na spec |
| `sk-bootstrap` | Em projeto novo, cria a base depois da spec aprovada; a spec do MVP define o escopo dela |
| `sk-sql` | Seção de modelo de dados: esquema, constraints, migrações e plano de rollback |
| `sk-security` | Requisitos de segurança (autenticação, autorização, dados sensíveis) |
| `sk-system-design` | Quando a feature exige arquitetura nova ou integração entre serviços |
| `sk-refactor` | Impacto no legado: testes de caracterização antes de alterar código existente |
| `sk-code-review` | Revisão do diff contra os requisitos e critérios da spec |
| `sk-git` | A PR referencia a spec e os IDs de requisito e critério |

**Fallback**: se alguma skill não estiver disponível, siga sem ela: registre a decisão arquitetural na seção de premissas, escreva os contratos direto na spec, mantenha o plano de implementação na própria spec (em vez de `TASKS.md`) e derive os testes manualmente dos critérios.

---

## 8. Modelo de referência

Ilustrativo, com o conteúdo reduzido. Em uma spec real, mantenha apenas as seções do perfil escolhido.

````markdown
---
id: 003
titulo: Cobrança recorrente
status: rascunho
versao: 0.1.0
atualizado: 2026-10-11
depende-de: []
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

---

## 9. Armadilhas

- **Ambiguidade**: spec sem nomes exatos de campos, rotas ou códigos de erro. Obriga a IA a adivinhar.
- **Divergência entre contrato e código**: mudança técnica feita no código sem refletir na spec. Siga a seção 2.7.
- **Pulo do ponto de parada**: assumir aprovação tácita e gerar código em cascata.
- **Spec que descreve a solução, não o comportamento**: amarra a implementação sem necessidade e dificulta o teste.
- **Spec grande demais**: documento de 8 ou mais seções para uma mudança pequena. Use o perfil Leve ou divida.
- **Spec esquecida após o merge**: o documento deixa de refletir o código. Feche o ciclo com `implementada` e a rastreabilidade completa.
- **Requisito não mensurável**: "deve ser rápido", "deve ser seguro". Quantifique ou detalhe.
- **Spec escrita ignorando o projeto**: contradiz arquitetura, convenções ou regras já registradas. Comece pelo passo 0.

---

## 10. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0).
2. Indicação do perfil escolhido (Leve ou Completa) e do destino do arquivo.
3. Arquivo da spec criado ou atualizado, com link relativo (`[003-cobranca-recorrente.md](./docs/specs/003-cobranca-recorrente.md)`).
4. Resumo de poucas linhas do que a spec define, mais premissas e perguntas em aberto.
5. Pedido de revisão com aprovação explícita. Nenhum código de implementação antes dela.
6. Após a aprovação: status atualizado, plano de implementação disponível para tarefas e indicação das skills de apoio que se aplicam.
7. Confirmação final do usuário sobre as alterações propostas, se aplicável.