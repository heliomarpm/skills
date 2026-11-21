# Referência: Escrita Clara, Tom e Roteiro de Slides (`sk-alignment`)

Use este guia ao redigir documentos de alinhamento, comunicados ao cliente, ADRs, avaliações e apresentações para humanos.

## 1. Escrita clara sem vícios de IA

Escreva para quem lê, não para impressionar. Revise o texto cortando estes vícios antes de entregar:

### Padrões para eliminar
1. **Aberturas de enrolação**: *"Vale ressaltar que..."*, *"No cenário atual..."*, *"Em sua essência..."*, *"A verdade é que..."*, *"É importante destacar que..."*, *"Quando se trata de..."*. Vá direto ao fato.
2. **Advérbios e muletas vazias**: *"realmente"*, *"simplesmente"*, *"fundamentalmente"*, *"crucialmente"*, *"literalmente"*, *"basicamente"*. Corte o advérbio e mantenha o verbo.
3. **Contrastes binários artificiais**: *"não é X, é Y"*, *"não apenas X, mas também Y"*, *"o problema não está em A, mas em B"*. Diga **Y** direto.
4. **Listagens negativas prévias e fragmentação dramática**: *"Não era A. Não era B. Era C."* ou frases soltas de uma palavra para forçar impacto. Use sentenças completas e diretas.
5. **Falsa agência em coisas inanimadas**: decisões não *"emergem"*, dados não *"nos dizem"*, reclamações não *"viram correções"*. Nomeie o ator real (*"o time decidiu"*, *"a auditoria mediu"*, *"o usuário solicitou"*).
6. **Declarativas vagas**: *"os impactos são significativos"*, *"as causas são estruturais"*. Substitua pelo número, prazo ou risco específico.
7. **Extremos preguiçosos**: *"todos"*, *"sempre"*, *"nunca"* sem base comprovada.
8. **Excesso de travessões e listas mecânicas de 3 itens**: prefira vírgulas/pontos e varie o ritmo (1 ou 2 itens claros quando bastam).

### Tabela rápida: Evite → Prefira

| Evite | Prefira |
| :--- | :--- |
| "Não se trata apenas de velocidade, mas de previsibilidade." | "A mudança garante respostas abaixo de 300 ms em pico." |
| "Vale ressaltar que o banco apresentou gargalos significativos." | "A tabela `orders` sofreu varredura sequencial por falta de índice em `created_at`." |
| "A decisão emergiu naturalmente após analisarmos o cenário." | "A equipe optou por filas assíncronas após medir perda de eventos." |
| "Esse recurso é simplesmente um divisor de águas no fluxo." | "O exportador assíncrono evita que telas com 50 mil pedidos travem." |

### Autoavaliação rápida (`/50`)
Antes de enviar um texto ao cliente ou relatório executivo, pontue de `1` a `10`:
- **Direto ao ponto**: afirma fatos logo na primeira frase (sem rodeio)?
- **Ritmo**: alterna frases curtas e médias naturalmente?
- **Confiança no leitor**: evita justificativas óbvias e bajulação?
- **Autenticidade**: soa como uma pessoa da equipe explicando a outra?
- **Densidade**: cada frase carrega informação útil ou decisão?

Se a soma ficar abaixo de `35/50`, corte adjetivos, remova contrastes artificiais e reescreva em voz ativa.

---

## 2. Voz constante × Tom adaptável

- **Voz** é a postura fixa do produto e da equipe: **clara, técnica quando necessário, honesta nos limites e objetiva**. Ela não muda.
- **Tom** varia conforme o momento da conversa:

| Contexto | Tom indicado | Exemplo |
| :--- | :--- | :--- |
| **Alinhamento com cliente** | Didático e preciso | "O sistema enviará o relatório por e-mail quando passar de 5 mil linhas." |
| **Risco ou bloqueio** | Firme, calmo e com saída | "Falta definir a janela de retenção dos logs (7 ou 30 dias) para liberar a tarefa." |
| **Erro ou suporte** | Empático e acionável | "A cobrança não foi concluída porque o cartão recusou; você pode tentar outro meio." |
| **Documentação técnica (`README` / `ADR`)** | Direto e factual | "Executa migrações em duas fases para evitar bloqueio na tabela durante o deploy." |

---

## 3. Roteiro de apresentação de alinhamento (6 a 8 slides)

Somente gere slides ou roteiro se o usuário pedir. Mantenha o arco narrativo focado em decisão e clareza (**Hoje → O que muda → Regras e escolhas → Riscos e confirmação**):

1. **Slide 1 — Contexto e objetivo**: qual problema resolvemos e qual resultado o cliente verá no dia a dia.
2. **Slide 2 — Como é hoje vs como fica (escopo)**: 2 colunas claras (**O que entra** | **O que fica de fora nesta etapa**).
3. **Slide 3 — Jornadas principais**: passo a passo visual do fluxo do usuário (fluxograma simples ou sequência em linguagem comum).
4. **Slide 4 — Regras de negócio e limites**: prazos, perfis de acesso e exceções que afetam a operação.
5. **Slide 5 — Decisões e o porquê**: escolhas relevantes de arquitetura/produto e seu efeito prático para o cliente (custo, tempo, segurança).
6. **Slide 6 — Riscos, premissas e o que precisamos de você**: acessos, aprovações ou definições bloqueantes.
7. **Slide 7 — Critérios de pronto**: como o cliente e o time vão testar na prática que está entregue.
8. **Slide 8 — Perguntas fechadas para confirmação**: máximo de 3 a 5 itens com opções (`A` / `B`) e recomendação para aprovar na reunião.

### Layout e densidade por slide
- **Uma ideia central por slide**, máximo de `3` a `5` pontos curtos (sem parágrafos longos).
- **Comparação / Escopo**: 2 colunas (`Antes / Depois` ou `Dentro / Fora`).
- **Métricas / Critérios de pronto**: grade de `3` a `4` cartões objetivos com número verificável.
- **Progresso ou etapas**: linha do tempo linear de `3` a `5` marcos.
- **Decisões**: tabela de `3` colunas (`Escolha | Motivo | Impacto para o usuário`).
