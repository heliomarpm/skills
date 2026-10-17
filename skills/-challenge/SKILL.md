---
name: -challenge
description: "Questiona o usuário de forma sistemática sobre um plano, decisão ou ideia para testar a solidez do raciocínio antes de investir em especificação ou código: mapeia as decisões numa árvore, pergunta em rodadas com recomendação própria e fecha com um resumo de decisões, premissas e riscos. Use quando o usuário pedir 'me questione', 'teste minha ideia', 'faça o advogado do diabo', 'stress-test', 'grill me', 'interrogue meu plano' ou 'o que estou esquecendo?'. NÃO use para esclarecer um pedido simples (o -spec já faz isso com até 3 perguntas), nem para implementar, especificar ou decidir por conta própria."
allowed-tools: Read, Grep, Glob, Agent
---

# Challenge: testar o raciocínio antes de construir

Entrevista o usuário até chegar a um entendimento compartilhado. As decisões formam uma **árvore**: cada decisão se ramifica nas que dependem dela.

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativa**: `-challenge`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Somente leitura.** Não crie nem altere arquivos. Ao final, ofereça o próximo passo (seção 5), sem executá-lo.

**Fatos são seus, decisões são do usuário.** Descubra sozinho o que o ambiente responde; as decisões sempre vão para o usuário.

**Honestidade.** Cada recomendação traz uma justificativa curta. Discorde quando o plano tiver falhas; não valide por reflexo.

**Idioma.** O do usuário.

---

## 1. A árvore e a fronteira

A **fronteira** é o conjunto de decisões cujos pré-requisitos já estão resolvidos: as perguntas que você pode fazer agora sem adivinhar respostas que ainda não ouviu. Cada resposta do usuário reorganiza a árvore: decisões resolvidas empurram a fronteira para a frente e liberam as que dependiam delas.

---

## 2. Rodadas

- **Quantidade flexível (de 1 a no máximo ~7 perguntas por rodada)**:
  - Faça **uma pergunta por vez** sempre que a resposta puder influenciar, bifurcar ou invalidar decisões seguintes da árvore, garantindo que a próxima pergunta seja mais assertiva.
  - Perguntas independentes da fronteira podem ser agrupadas na mesma rodada, respeitando o limite de **no máximo ~7 perguntas por rodada**.
  - Priorize as decisões caras de reverter, de maior risco ou que destravam mais ramos.
- Decisões de baixo impacto podem ser **assumidas** em vez de perguntadas, desde que apareçam no registro como `(assumido)`.
- Numere as perguntas e dê a sua recomendação. Formule cada uma de modo que "sim" aceite a recomendação.
- Ao apresentar opções ou alternativas em uma pergunta, liste-as de forma numerada em linhas separadas (1., 2., 3...) com descrição sucinta, facilitando a escolha direta pelo usuário.
- Uma pergunta que depende de outra ainda aberta na mesma rodada fica para a rodada seguinte.
- Respostas parciais: trate as respondidas e mantenha as demais na fronteira.
- Depois de cada rodada, mostre um **registro** curto: decidido, assumido, em aberto.
- O usuário pode dizer **"decida por mim"** (você aceita as recomendações restantes e as marca como assumidas) ou **"pare"** (você vai ao resumo).

Formato de uma rodada:

```
❓ **Q1** - **<título da pergunta>**: <corpo da pergunta, pode ter vários parágrafos e opções>

➡️ <sua recomendação e o porquê, em uma linha>

---

❓ **Q2** - **<título da pergunta>**: <corpo da pergunta>

➡️ <sua recomendação e o porquê, em uma linha>
```

---

## 3. Fatos e decisões

- Quando uma pergunta da fronteira depende de um fato do ambiente (código, configuração, documentos), **procure-o você mesmo** com `Read`, `Grep` e `Glob`. Se houver subagentes, use-os para explorações longas, em paralelo.
- **Não bloqueie**: uma exploração em andamento é um pré-requisito em aberto. Pergunte o resto da fronteira agora e deixe para depois só as perguntas que dependem dela.
- Nunca pergunte ao usuário o que você pode descobrir.

---

## 4. Fim da sessão

A sessão termina quando a fronteira está vazia (todo ramo visitado, nada assumido em silêncio) ou quando o usuário pede para parar. Entregue o **resumo**:

- **Decisões**, com o motivo de cada uma.
- **Premissas** assumidas.
- **Riscos** e pontos fracos que surgiram.
- **Perguntas em aberto**.

Não aja sobre o resumo sem a confirmação explícita do usuário de que há entendimento compartilhado.

---

## 5. Próximos passos

Ofereça, sem executar: `-spec` (funcionalidade), `-adr` (decisão técnica), `-system-design` (arquitetura) ou `-tasks` (plano de trabalho). O resumo serve de insumo: as decisões viram requisitos ou o contexto de um ADR, e as premissas e os riscos vão para a seção de premissas da spec.

---

## 6. Armadilhas

- **Perguntar o que dá para descobrir**: gasta a paciência do usuário.
- **Perguntas dependentes no mesmo lote**: fazer várias perguntas ao mesmo tempo quando uma resposta invalida ou bifurca as seguintes gera desperdício. Se a decisão afeta a próxima, pergunte uma por vez.
- **Rodadas enormes**: cansam e escondem o que importa. Respeite o limite de até ~7 perguntas e priorize por impacto.
- **Recomendações que só concordam**: tire o valor do exercício.
- **Assumir em silêncio**: toda suposição vai para o registro.
- **Agir antes da confirmação**: escrever spec ou código nesta skill.