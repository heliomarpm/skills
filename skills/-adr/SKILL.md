---
name: -adr
description: "Registra e mantém decisões técnicas e arquiteturais como Architecture Decision Records (ADRs): quando escrever, contexto, alternativas reais, consequências e trade-offs, ciclo de vida (proposto, aceito, substituído) com aprovação explícita, índice e ADRs retroativos a partir de código existente. Use sempre que o usuário pedir 'crie um ADR', 'registre esta decisão', 'documente por que escolhemos X', 'documente os trade-offs', 'substitua a decisão Y', 'quais decisões temos sobre Z' ou comparar alternativas técnicas para decidir, mesmo sem a sigla ADR. NÃO use para desenhar a arquitetura de um sistema ou modelar diagramas C4 (isso é -system-design), especificar uma funcionalidade (isso é -spec) ou analisar um incidente em produção (isso é -observability)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(git log *)
---

# ADR: registro de decisões técnicas

Um ADR guarda **por que** uma decisão foi tomada: o contexto, as alternativas consideradas e o preço que se aceitou pagar. É lido seis meses depois por quem pergunta "por que fizemos assim?".

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativa**: `-adr`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**A decisão é de quem decide.** A skill escreve o ADR com status **Proposto**, com uma recomendação explícita e justificada, e só muda para **Aceito** com aprovação explícita do usuário ("aprovado", "aceito"). Silêncio não vale.

**Imutabilidade.** ADR aceito não se reescreve. Se a decisão mudou, crie um novo ADR que o substitui (seção 5). São permitidas correções de digitação e a atualização de status e de links.

**Evidência.** Números citados (latência, custo, volume) têm fonte (benchmark, documentação, incidente) ou levam a marca `(estimativa)`. Nunca invente métricas, nem o contexto e as alternativas de uma decisão passada.

**Escrita restrita.** A skill escreve apenas na pasta de ADRs e no `DECISIONS.md`. Nunca altera código.

**Sem segredos.** ADRs ficam no repositório: nada de credenciais, tokens ou hosts internos. Em decisões de segurança, evite detalhar vulnerabilidades se o repositório for público.

**Idioma e data.** O do repositório; a data vem do contexto da conversa e, sem ela, é omitida.

---

## 1. Modos de operação

| Modo | Quando |
| :--- | :--- |
| **Criar** | Registrar uma decisão nova |
| **Substituir ou alterar status** | A decisão mudou ou foi rejeitada |
| **Registrar retroativo** | Documentar uma decisão já implementada |
| **Revisar** | Validar ADRs, achar duplicatas e conflitos |
| **Consultar** | Buscar as decisões vigentes antes de propor uma mudança |

---

## 2. Quando escrever um ADR

Escreva quando a decisão é **cara de reverter**, **atravessa módulos ou equipes**, ou alguém vai perguntar o motivo no futuro. Exemplos: linguagem ou framework central, banco de dados, mensageria, padrão de integração, estratégia de autenticação, estrutura de módulos.

Não escreva para escolhas locais, baratas e reversíveis, nem para estilo de código (isso vai no `GUIDELINE.md`).

---

## 3. Localização, nome e índice

- **Pasta**: detecte a existente (`docs/adr`, `adr`, `docs/decisions`, `doc/adr`, `architecture/decisions`). Sem nenhuma, pergunte uma vez:

> *"Onde prefere salvar os ADRs?*  
> *1. Na pasta de documentação (`docs/adr/`)*  
> *2. Na pasta raiz de ADR (`adr/`)*  
> *3. Na pasta de decisões (`docs/decisions/`)*  
> *4. Na pasta de arquitetura (`architecture/decisions/`)*  
> *(ou informe outro caminho de sua preferência)*"*

Em execução não interativa use `docs/adr/`.
- **Arquivo**: `ADR-NNN.md` (ex.: `ADR-001.md`, `ADR-002.md`). O número `NNN` é sequencial com 3 dígitos a partir do maior existente mais um, incluindo os substituídos; nunca reutilize nem renumere.
- **Índice**: mantenha `README.md` na pasta, atualizado a cada criação ou mudança de status:

````markdown
| Nº | Título | Status | Data |
| :--- | :--- | :--- | :--- |
| [ADR-005](./ADR-005.md) | Transactional Outbox para eventos financeiros | Aceito | 2026-09-27 |
| [ADR-003](./ADR-003.md) | Kafka como broker de eventos | Substituído por ADR-009 | 2026-03-02 |
````

- **`DECISIONS.md`** (do `-discovery`): se a pasta de ADRs existe, ele vira apenas um índice que aponta para os ADRs, sem duplicar conteúdo. Sem a pasta, usa entradas curtas neste mesmo formato.

---

## 4. Workflow

1. **Contexto**: procure ADRs existentes (duplicatas e conflitos) e leia `ARCHITECTURE.md`, `DECISIONS.md` e a spec relacionada.
2. **Escolha o formato**: o **curto** para decisões simples (contexto, decisão, consequências); o **completo** quando há várias alternativas ou impacto amplo. Limite de ~100 linhas por ADR.
3. **Redija com neutralidade**: inclua o status quo entre as alternativas, apresente cada opção não escolhida no seu melhor argumento e liste consequências negativas reais.
4. **Recomende** uma opção, com a justificativa, e deixe o ADR como **Proposto**.
5. **Aprovação**: ao receber a aprovação explícita, mude para **Aceito** e atualize o índice.
6. **Vínculos**: linke a spec, as tarefas e os ADRs relacionados; peça ao usuário para referenciar os ADRs críticos no `AGENTS.md` e no `GUIDELINE.md`.

---

## 5. Ciclo de vida

| Status | Significado |
| :--- | :--- |
| Proposto | Em discussão, ainda sem decisão |
| Aceito | Vigente |
| Rejeitado | Avaliado e descartado (mantenha o registro) |
| Obsoleto | Já não se aplica, sem substituto |
| Substituído por ADR-NNN | Trocado por outro ADR |

**Substituir**: crie o ADR novo com a linha `Substitui: ADR-NNN` e, no antigo, altere apenas o status (`Substituído por ADR-NNN`) e os links. O texto original permanece.

---

## 6. ADR retroativo

Para uma decisão já implementada, parta do código, do histórico (`git log`) e de documentos existentes. Marque o que vem do código como `(inferido)` e o que só a memória do time sabe como `[A CONFIRMAR]`. O status é **Aceito (retroativo)**. Nunca fabrique contexto ou alternativas que não estejam documentados.

---

## 7. Modelos

### 7.1. Formato curto

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

### 7.2. Formato completo

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

---

## 8. Registro via `-tasks` e integrações

Se o ADR tem etapas de implementação, pergunte ao final:

> *"Deseja que eu registre as etapas de implementação desta decisão no `TASKS.md` do projeto?"*

Com a confirmação, acione a skill `-tasks` (modo Importar), com origem `adr ADR-NNN`, links relativos e a prioridade: P1 para etapas que desbloqueiam as demais, P2 para as outras e P3 para a revisão futura da decisão. **Fallback**: lista no chat.

| Skill | Como se integra |
| :--- | :--- |
| `-system-design` | Como projetar e modelar C4; o ADR registra a escolha |
| `-spec` | Decisões da spec viram ADR; o ADR é referenciado na spec |
| `-discovery` | Índice em `DECISIONS.md` e ADRs retroativos |
| `-code-review` | Lê os ADRs aceitos como fonte de padrões do Eixo 2 |
| `-refactor` | Decisões estruturais relevantes geram ADR |
| `-observability` | Post-mortem que muda a arquitetura gera ADR |
| `-security` | Decisões de segurança passam pelas regras da seção 0 |

Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 9. Armadilhas

- **Editar a decisão de um ADR aceito**: apaga o histórico. Substitua por outro ADR.
- **ADR sem alternativa real**: se só havia uma opção, não era uma decisão.
- **Decisão apresentada como já tomada**: o status inicial é Proposto.
- **Só prós**: toda escolha tem custo, e o ADR deve listar as consequências negativas.
- **Retrospectiva tardia**: escrever meses depois perde o contexto real. Se for retroativo, declare e marque o que é inferido.
- **Métrica inventada**: cite fonte ou marque `(estimativa)`.
- **Número duplicado ou índice desatualizado**: dificulta a busca.
- **ADR para decisão trivial**: burocracia sem valor.
- **Decisão escolhida pela skill**: quem decide é o usuário.

---

## 10. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado (seção 1).
2. Arquivo do ADR criado ou alterado e o índice atualizado, com links relativos.
3. Resumo da decisão, da recomendação e das principais consequências negativas.
4. Status atual e o que falta para a aprovação.
5. Pendências e a pergunta sobre o registro em tarefas (seção 8).