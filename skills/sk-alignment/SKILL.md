---
name: sk-alignment
description: "Gera um documento de alinhamento em linguagem não técnica, a partir da spec, dos ADRs e dos demais artefatos, para apresentar ao cliente ou demandante e confirmar o entendimento antes de construir: escopo, como vai funcionar, regras, decisões e o porquê, premissas, riscos e perguntas para confirmar, com rastreabilidade para as fontes. Também registra as respostas do cliente e propõe as mudanças nos artefatos. ATIVAÇÃO EXCLUSIVAMENTE EXPLÍCITA: use somente quando o usuário pedir 'gere o documento de alinhamento', 'prepare a apresentação para o cliente', 'resuma a spec para o cliente confirmar' ou 'registre as respostas do cliente'. NÃO use para escrever a spec (isso é sk-spec), questionar o plano com o próprio usuário (isso é sk-challenge) nem para propostas comerciais com preço e prazo."
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Grep, Glob
---

# Alignment: confirmar o entendimento com quem demanda

Traduz os artefatos técnicos (spec, ADRs, PRD) para a linguagem de quem pediu o trabalho, para que a pessoa confirme, corrija ou questione **antes** de se construir. O objetivo é evitar o retrabalho de entregar a coisa certa para o requisito errado.

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-alignment`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Ativação explícita.** O documento é voltado a terceiros: nunca o gere por conta própria.

**Fiel à fonte.** Cada afirmação tem origem num artefato (`RF-01`, `CA-02`, `ADR-005`). O que não está nos artefatos é omitido ou marcado `[A CONFIRMAR]`. Simplificar não é distorcer: se uma tradução perde precisão, mantenha o termo com uma explicação curta. Números e limites das fontes são mantidos.

**Sem compromissos novos.** Não inclua prazo, custo, garantia ou promessa que não estejam nas fontes.

**Linguagem do público.** Frases curtas, sem jargão (ou com a explicação no próprio texto) e com exemplos concretos do dia a dia do cliente. O idioma é o do cliente; sem essa informação, o da spec.

**Conteúdo sensível.** Não exponha vulnerabilidades, segredos, custos internos nem detalhes que só interessam ao time. Segurança aparece em termos de efeito ("o acesso depende do perfil do usuário").

**Não altera os artefatos.** A skill **propõe** mudanças na spec e nos ADRs; só aplica com a aprovação do usuário e por meio do `sk-spec` e do `sk-adr`.

**Escrita.** Somente o documento de alinhamento, em `docs/alignments/` ou na pasta já adotada pelo projeto. Se não existir, pergunte o destino uma vez.

**Data.** A do contexto da conversa; sem ela, omita.

---

## 1. Modos de operação

| Modo | Quando |
| :--- | :--- |
| **Gerar** | Criar o documento a partir dos artefatos |
| **Registrar respostas** | O cliente respondeu: anotar e propor as mudanças (seção 5) |
| **Atualizar** | Resumir o que mudou desde a versão que o cliente confirmou |

---

## 2. Fontes

Leia, nesta ordem de preferência: a **spec** (`docs/specs/`), os **ADRs** relacionados, o `PRD.md` e o `CONTEXT.md`, e o resumo de decisões, premissas e riscos do `sk-challenge`, se estiver na conversa. Sem spec, pare e sugira o `sk-spec`; só prossiga com o resumo do `sk-challenge` se o usuário pedir, marcando que o documento se baseia em conversa e não em uma spec.

---

## 3. Estrutura do documento

| Seção | Conteúdo | Fonte |
| :--- | :--- | :--- |
| 1. Resumo | O que vamos construir e para quê, em 3 a 5 linhas | Objetivo da spec |
| 2. Escopo | O que entra e o que **não** entra | Visão geral da spec |
| 3. Como vai funcionar | Jornadas em linguagem simples | Casos de uso |
| 4. Regras importantes | Regras de negócio e casos especiais | Regras e casos limite |
| 5. Decisões e o porquê | Escolhas relevantes e o efeito para o cliente (sem inventar números) | ADRs |
| 6. O que assumimos | Premissas | Premissas da spec |
| 7. O que precisamos de você | Dados, acessos, aprovações e decisões pendentes | Dependências |
| 8. Riscos e pontos de atenção | Em linguagem simples | Riscos da spec |
| 9. Como saberemos que está pronto | Critérios de aceite traduzidos | Critérios de aceite |
| 10. Perguntas para confirmar | Com opções e uma sugestão | Itens `[A CONFIRMAR]` |
| 11. Confirmação | Item a item: Confirmado, Ajustar ou Dúvida | n/d |
| Apêndice | Rastreabilidade: cada item do documento e sua fonte | n/d |

Mantenha o corpo em até ~150 linhas (2 a 3 páginas). O detalhe técnico fica nas fontes, e o apêndice aponta para elas.

---

## 4. Como traduzir

| Fonte técnica | Para o cliente |
| :--- | :--- |
| `RF-01` (MUST): exportar pedidos em CSV | "O gerente poderá baixar os pedidos em uma planilha (CSV)." |
| `CA-02`: sem pedidos no período, retorna mensagem | "Se o período escolhido não tiver pedidos, o sistema avisa em vez de gerar uma planilha vazia." |
| `RNF-01`: p95 abaixo de 10 s para 50 mil linhas | "Para até 50 mil pedidos, a planilha deve ficar pronta em até 10 segundos." |
| `ADR-012`: fila assíncrona | "Exportações muito grandes serão geradas em segundo plano e enviadas por e-mail, para não travar a tela." |

Perguntas fechadas funcionam melhor que abertas: ofereça **opções** e uma **sugestão** com o motivo.

---

## 5. Ciclo de vida

O documento tem **versão** e **status** no cabeçalho: `Rascunho`, `Enviado`, `Confirmado` ou `Confirmado com ressalvas`.

**Registrar respostas**
1. Anote a resposta do cliente a cada item da seção 11.
2. Liste as **mudanças propostas** nos artefatos: item, mudança e artefato afetado (spec ou ADR).
3. Mudança de escopo ou de comportamento é **mudança material** para a spec (`sk-spec`): sinalize o impacto e aguarde a aprovação do usuário.
4. A spec só passa a `aprovada` depois da confirmação do cliente, e quem decide isso é o usuário.

**Atualizar**: produza a seção "O que mudou desde a versão confirmada" (adicionado, alterado, removido) e uma nova versão do documento.

---

## 6. Formato e entrega

- **Markdown** em `docs/alignments/<id-da-spec>-<tema>.md`.
- **Word, PDF ou apresentação**: converta somente a pedido, se o ambiente tiver ferramentas de documento. Para apresentação, ofereça antes um **roteiro de 5 a 8 slides** (título e pontos de cada um), com a mesma estrutura do documento.

### Modelo

````markdown
# Alinhamento: Exportação de pedidos em CSV

> Versão: v1 | Status: Rascunho | Atualizado em: 2026-10-13 | Spec: 004

## 1. Resumo
Vamos permitir que o gerente baixe os pedidos de um período em uma planilha, para facilitar os relatórios mensais.

## 2. Escopo
- **Entra:** exportação por período e por status; acesso só para o perfil gerente.
- **Não entra:** envio por e-mail e exportação de mais de 50 mil pedidos de uma vez.

## 10. Perguntas para confirmar
| # | Pergunta | Opções | Sugestão |
| :--- | :--- | :--- | :--- |
| P1 | Quem pode exportar? | Só gerente / Gerente e financeiro | Só gerente (mais simples; ampliamos depois) |

## 11. Confirmação
| Item | Confirmado | Ajustar | Dúvida | Comentário |
| :--- | :---: | :---: | :---: | :--- |
| 2. Escopo | | | | |
| P1 | | | | |

## Apêndice: rastreabilidade
| Item do documento | Fonte |
| :--- | :--- |
| Escopo (entra) | spec 004, seção 1 e `RF-01` |
````

---

## 7. Integrações

| Skill | Como se integra |
| :--- | :--- |
| `sk-spec` | Fonte principal; as respostas do cliente voltam como mudanças propostas na spec |
| `sk-adr` | Decisões que o cliente precisa entender; mudanças de decisão viram novo ADR |
| `sk-challenge` | Seu resumo é fonte adicional (decisões, premissas e riscos) |
| `sk-discovery` | `PRD.md` e `CONTEXT.md` como contexto, em sistemas existentes |
| `sk-tasks` | Itens pendentes de confirmação e mudanças aprovadas viram tarefas |

Para pendências, pergunte se o usuário quer registrá-las via `sk-tasks` (modo Importar, origem `alignment`; perguntas que bloqueiam a spec em P1, as demais em P2; fallback em lista no chat).

---

## 8. Armadilhas

- **Jargão** no texto do cliente: ele confirma sem entender.
- **Inventar prazo, custo ou garantia.**
- **Simplificar até distorcer**: perder um limite ou uma exceção que muda o sentido.
- **Esconder decisões ou limitações** que afetam o cliente.
- **Documento longo demais**: ninguém lê e todos confirmam sem ler.
- **Perguntas abertas demais**: ofereça opções e uma sugestão.
- **Tratar silêncio como confirmação.**
- **Expor segurança ou custos internos.**
- **Alterar a spec sem aprovação do usuário.**

---

## 9. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. O documento, com link relativo, versão e status.
3. Lista de itens `[A CONFIRMAR]` e das perguntas ao cliente.
4. No modo Registrar respostas: as mudanças propostas nos artefatos e o que depende da sua aprovação.
5. Pendências e a pergunta sobre o registro em tarefas (seção 7).