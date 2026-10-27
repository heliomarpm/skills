---
name: -refactor
description: "Conduz refatoração segura de código existente: reestruturar sem mudar o comportamento externo, com rede de testes de caracterização, micro-passos validados, catálogo de smells e movimentos, e portão de aprovação para mudanças grandes. Use sempre que o usuário pedir 'refatore', 'limpe este código', 'reduza a complexidade', 'extraia', 'simplifique', 'remova a duplicação', 'melhore a estrutura' ou falar de dívida técnica em código legado, mesmo sem a palavra 'refatorar'. NÃO use para mudar comportamento ou adicionar funcionalidade, corrigir bugs (isso é -debug), revisar um diff (isso é -code-review) ou reescrever um sistema do zero."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(git status *), Bash(git diff *), Bash(git log *), Bash(npm test *), Bash(npm run test *), Bash(npm run build *), Bash(npm run lint *), Bash(npm run typecheck *), Bash(pnpm test *), Bash(pnpm run test *), Bash(yarn test *), Bash(npx vitest *), Bash(npx jest *), Bash(npx tsc *), Bash(pytest *), Bash(python -m pytest *), Bash(ruff *), Bash(mypy *), Bash(go test *), Bash(go build *), Bash(go vet *), Bash(dotnet test *), Bash(dotnet build *), Bash(mvn test *), Bash(gradle test *), Bash(./gradlew test *), Bash(composer test *), Bash(vendor/bin/phpunit *), Bash(vendor/bin/pest *), Bash(cargo test *), Bash(cargo check *), Bash(cargo clippy *), Bash(flutter test *), Bash(flutter analyze *)
---

# Refactor: refatoração segura e disciplinada

Reestrutura o código por dentro, em passos pequenos e verificáveis, sem alterar o que ele faz por fora. Princípios e transformações valem para qualquer linguagem; os idiomas concretos vêm do projeto e das skills `-tech-*`.

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativa**: `-refactor`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Regra dos dois chapéus.** Ao refatorar, **só reestruture**: nenhuma regra de negócio muda, nenhuma funcionalidade nasce, o comportamento externo permanece idêntico e os testes continuam verdes. Mudar comportamento é outro trabalho, em outro momento e, de preferência, em outro commit. Se aparecer um bug ou uma oportunidade durante a refatoração, **não corrija na hora**: registre uma tarefa via `-tasks` ou, se o usuário pedir, troque de chapéu explicitamente.

**Escopo.** Defina o alvo e os limites antes de editar e não mexa fora deles (nada de reformatar o arquivo inteiro de carona).

**Siga o projeto.** Leia `AGENTS.md`, `GUIDELINE.md` e `ARCHITECTURE.md` antes de decidir a direção. Use as convenções existentes, não as suas.

**Git.** Nunca use comandos destrutivos. Proponha um commit por transformação atômica (`refactor(escopo): ...`, conforme o `-git`), mas só commite se o usuário pedir.

**Timebox e Circuit Breaker.** A refatoração não deve entrar em ciclos de tentativa e erro. Se um micro-passo quebrar testes, build ou lint e a causa não for sanada em **até duas tentativas**, desfaça o passo de volta ao último estado verde. Se houver **duas reversões consecutivas** ou se a transformação empacar, pare a execução ativa imediatamente e acione o ponto de parada para check-in com o usuário (seção 6.4).

**Idioma.** O do pedido do usuário; nomes de código ficam como estão.

---

## 1. Modos de operação

| Modo | Quando | O que faz |
| :--- | :--- | :--- |
| **Diagnosticar** | "O que há de errado estruturalmente aqui?" | Identifica smells e propõe plano, sem editar |
| **Planejar** | Refatoração grande ou arriscada | Escreve o plano (passos, ordem, riscos) e pede aprovação |
| **Executar** | Alvo e escopo definidos | Aplica os micro-passos com validação contínua |

---

## 2. Workflow

1. **Contexto e escopo**: leia as convenções do projeto, delimite o alvo e identifique o smell específico (seção 4).
2. **Portão de aprovação**: refatorações que passem de ~5 arquivos, mudem a API pública ou sejam estruturais viram plano escrito, e você só executa com aprovação explícita ("aprovado", "pode executar"). Silêncio não vale.
3. **Rede de proteção** (seção 3): sem ela, não comece.
4. **Micro-passos**: uma transformação atômica por vez, escolhida no catálogo (seção 4).
5. **Validação após cada passo** (seção 6): testes, build, tipagem e lint. Em caso de quebras persistentes, acione o circuit breaker (seção 6.4).
6. **Fechamento**: confira o critério de pronto (seção 6.5), resuma as transformações e registre o que sobrou (seção 8).

---

## 3. Rede de proteção

**Sem rede, sem refatoração.** Tentar limpar código sem testes é a causa principal de regressões silenciosas.

**Critério de rede suficiente**: os caminhos que a refatoração toca estão cobertos, incluindo os valores de borda e os erros que existem hoje, inclusive os questionáveis. A escrita dos testes de caracterização segue o `-testing` (modo Caracterizar).

**Dispensa**, somente com declaração explícita ao usuário: transformação puramente mecânica feita por ferramenta (por exemplo, renomear símbolo pela IDE) em código já coberto.

**Pontos de costura (*seams*).** Código que depende de relógio, aleatoriedade, rede ou disco não é testável como está. Permita uma preparação mínima antes dos testes (injetar a dependência, extrair a chamada), com o menor risco possível, e descreva a preparação ao usuário.

---

## 4. Smells e movimentos

Isole o defeito estrutural específico e aplique o movimento correspondente. O `-code-review` aponta os smells; aqui estão as transformações.

| Smell | Movimentos |
| :--- | :--- |
| Long Function | Extract Function, Decompose Conditional |
| Nested Conditionals | Guard Clauses |
| Condicional repetido por tipo | Mapa de funções; polimorfismo apenas se justificar (veja o exemplo) |
| Data Clumps | Introduce Parameter Object |
| Primitive Obsession | Replace Primitive with Object |
| Feature Envy | Move Function |
| Large Class | Extract Class |
| Divergent Change, Shotgun Surgery | Move Function, Inline Class |
| Duplicated Code | Extract Function, Pull Up |
| Mysterious Name | Rename |
| Mutable Data | Encapsulate Variable |
| Middle Man | Remove Middle Man |
| Speculative Generality | Inline Function, Collapse Hierarchy |

**Direção das transformações**: SRP, OCP e DIP orientam as escolhas; não são meta de pureza. Do Clean Code, só o que é verificável: nomes que revelam intenção, funções com uma responsabilidade, fluxo plano e tratamento de erro consistente. O formato de erro (RFC 9457) é do `-api-design` e a observabilidade, do `-observability`.

### 4.1. Condicional repetido por tipo

```text
// ANTES
funcao calcularTaxa(tipo, valor):
    se tipo == "PIX" entao retorne 0
    senao se tipo == "CARTAO" entao retorne valor * 0.03
    senao se tipo == "BOLETO" entao retorne 2.50
    senao lance Erro("Tipo inválido")

// DEPOIS: mapa de funções, mesmo comportamento e mesma mensagem de erro
TAXAS = {
    "PIX":    (valor) -> 0,
    "CARTAO": (valor) -> valor * 0.03,
    "BOLETO": (valor) -> 2.50
}
funcao calcularTaxa(tipo, valor):
    calculo = TAXAS[tipo] ou lance Erro("Tipo inválido")
    retorne calculo(valor)
```

Interface com uma classe por ramo só compensa quando os ramos têm estado ou comportamento próprios, ou variam com frequência. Para ramos triviais, seria *Speculative Generality*.

### 4.2. Parameter Object

```text
// ANTES: parâmetros que sempre trafegam juntos
funcao buscarPedidos(dataInicio, dataFim, status, valorMin, valorMax, pagina, tamanho)

// DEPOIS
estrutura FiltroPedidos { periodo: {inicio, fim}, status?, valor: {min, max}, paginacao: {pagina, tamanho} }
funcao buscarPedidos(filtro: FiltroPedidos)
```

### 4.3. Guard Clauses

```text
// ANTES
funcao processar(pedido):
    se pedido != nulo:
        se pedido.itens.vazio() == falso:
            ...logica principal...

// DEPOIS
funcao processar(pedido):
    se pedido == nulo: retorne
    se pedido.itens.vazio(): retorne
    ...logica principal...
```

---

## 5. Riscos silenciosos

- **Renomear símbolo exposto** (serialização, JSON, ORM, reflexão, nome de rota ou de evento) pode quebrar o que o compilador não vê. Trate a renomeação de nome público como mudança de API e confira os usos dinâmicos com `Grep`.
- **Esquema de banco não é refatoração de código**: migre com expand and contract, via `-sql`.
- **Remover código morto exige evidência**: busque referências no repositório inteiro e considere reflexão, registro por convenção em injeção de dependência, rotas e chaves em string, feature flags e configuração. API pública de biblioteca não é código morto, mesmo sem uso interno. Na dúvida, não remova: registre como tarefa.
- **Mudar comportamento sem perceber**: mensagens de erro, ordem de efeitos, arredondamento, tratamento de nulos. Preserve todos.

---

## 6. Validação, reversão e pronto

### 6.1. A cada micro-passo

Rode os testes da área e, conforme o projeto, build, verificação de tipos e lint. Compare a superfície pública antes e depois. Se a refatoração tocar caminho quente, verifique de forma básica que o desempenho não degradou. Não invente métricas: use ferramentas do projeto, se existirem.

### 6.2. Testes de caracterização são imutáveis

Não os altere durante a refatoração, exceto renomeações mecânicas. Se um deles precisar mudar, o comportamento mudou, e isso deve ser dito ao usuário.

### 6.3. Reversão de micro-passo

Se os testes ficarem vermelhos, a compilação quebrar ou o linter falhar após um micro-passo e a causa não for evidente ou sanada em **até duas tentativas**, desfaça o último passo editando de volta (`git checkout` ou revertendo o diff) para retornar ao último estado verde com testes passando.

### 6.4. Ponto de parada: circuit breaker e check-in

Se ocorrerem **duas reversões consecutivas** de micro-passos ou se a refatoração do alvo empacar sem progresso seguro:

1. Assegure que a árvore de trabalho esteja limpa no último estado verde com testes passando.
2. Interrompa a execução ativa imediatamente — não tente novos movimentos do catálogo sem alinhamento prévio.
3. Apresente ao usuário o que foi tentado, o smell que resistiu e a evidência da falha (ex.: acoplamento oculto, dependência externa, asserções de teste que amarram detalhes internos).
4. Faça o check-in de continuidade:

> *"Atingi o limite do circuit breaker (2 tentativas/reversões consecutivas) ao refatorar `[smell]` em `[arquivo]`. O código foi restaurado com segurança para o último estado estável com todos os testes verdes. Como deseja proceder?*  
> 1. **Mudar de estratégia**: tentar um movimento alternativo do catálogo (ex.: técnica X em vez de Y)  
> 2. **Reforçar a rede de proteção**: escrever testes de caracterização adicionais antes de tentar novas transformações  
> 3. **Pausar e registrar pendência**: manter a estrutura atual e registrar o débito técnico no `TASKS.md` (via `-tasks`)*"

Aguarde a decisão do usuário antes de realizar novas edições no código.

### 6.5. Critério de pronto

Pronto significa: comportamento preservado (testes, build, tipos e API pública verdes), smell alvo eliminado, nada fora do escopo alterado e um resumo das transformações aplicadas.

---

## 7. Refatorações grandes

Prefira mudança incremental a reescrever do zero, que descarta as correções de borda acumuladas ao longo dos anos. Estratégias: **Parallel Change** (expand and contract), **Branch by Abstraction** e **Strangler Fig**. Faça um plano em fases entregáveis, com a decomposição registrada no `-tasks`, e registre decisões estruturais relevantes em um ADR via `-adr`.

---

## 8. Integração e registro via `-tasks`

Se restaram etapas, testes de caracterização pendentes ou novos débitos, pergunte ao final:

> *"Identifiquei etapas e débitos decorrentes da refatoração. Deseja que eu os registre no `TASKS.md` do projeto?"*

Com a confirmação, acione a skill `-tasks` (modo Importar), com origem `refactor`, links relativos para os arquivos e a prioridade:

| Item | Prioridade |
| :--- | :--- |
| Testes de caracterização de fluxo crítico ou financeiro | P0 |
| Quebra de acoplamento e duplicação estrutural | P1 |
| Extrações e movimentos | P2 |
| Renomeações e limpeza cosmética | P3 |

**Fallback**: se `-tasks` não estiver disponível, apresente a lista no chat com prioridade, local e critério.

| Skill | Como se integra |
| :--- | :--- |
| `-testing` | Escreve os testes de caracterização |
| `-code-review` | Seus apontamentos viram candidatos a refatoração |
| `-git` | Commits atômicos e mensagens |
| `-adr` | Registro de decisões estruturais |
| `-sql` | Mudanças de esquema e migrations |
| `-debug` | Bugs encontrados no caminho são tratados lá, não aqui |
| `-tech-*` | Idiomas e ferramentas da stack |

---

## 9. Armadilhas

- **Refatorar sem rede**: regressão silenciosa em produção.
- **Misturar refatoração com bug ou funcionalidade**: o diff fica ilegível e a reversão, impossível.
- **Escopo indefinido**: refatorar "o que aparecer" gera alterações demais.
- **Abstração especulativa**: transformar três ramos triviais em hierarquia de classes.
- **Renomeação pública sem checar usos dinâmicos**: quebra serialização, reflexão e rotas.
- **Remover código morto sem evidência**: apagar o que é usado por convenção ou por terceiros.
- **Alterar os testes de caracterização no meio do caminho**: esconde a mudança de comportamento.
- **Insistência em micro-passo quebrado**: tentar sucessivos "remendos" quando o teste fica vermelho em vez de reverter e acionar o circuit breaker.
- **Bloco gigante sem commits atômicos**: impede a revisão humana.
- **Reescrever do zero**: perde as correções de borda acumuladas.

---

## 10. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado (seção 1).
2. Escopo declarado e, se houve, o plano aprovado.
3. Resumo das transformações aplicadas, com links relativos para os arquivos.
4. Resultado da validação (testes, build, tipos, lint) ou, se interrompido pelo circuit breaker, o relato e check-in da seção 6.4.
5. Pendências e a pergunta sobre o registro em tarefas (seção 8).
6. Links para commits atômicos e mensagens claras, se houver integração com `-git`.