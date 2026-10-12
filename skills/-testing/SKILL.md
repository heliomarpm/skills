---
name: -testing
description: "Orienta o planejamento, a escrita, a execução e a auditoria de testes automatizados (unitários, integração, contrato e E2E), de forma agnóstica a linguagem: padrão AAA, Test Data Builders, dublês, determinismo, esperas ativas, isolamento de estado e pirâmide de testes. Use sempre que o usuário pedir 'escreva testes', 'testes unitários, de integração ou E2E', 'aumente a cobertura', 'TDD', 'teste instável (flaky)', 'gere os testes a partir dos critérios de aceite' ou 'caracterize este código antes de refatorar', mesmo sem a palavra 'testing'. NÃO use para diagnosticar um bug em produção (isso é -debug), para revisar a qualidade de um diff (isso é -code-review) nem para configurar ferramentas específicas de uma stack (isso é a -tech-* correspondente)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(npm test *), Bash(npm run test *), Bash(pnpm test *), Bash(pnpm run test *), Bash(yarn test *), Bash(npx vitest *), Bash(npx jest *), Bash(pytest *), Bash(python -m pytest *), Bash(go test *), Bash(dotnet test *), Bash(mvn test *), Bash(gradle test *), Bash(./gradlew test *), Bash(composer test *), Bash(vendor/bin/phpunit *), Bash(vendor/bin/pest *), Bash(cargo test *), Bash(flutter test *)
---

# Testing: estratégia e automação de testes

Conceitos, estruturas e heurísticas aplicáveis a qualquer linguagem. As ferramentas concretas vêm do projeto ou da skill `-tech-*` da stack.

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativa**: `-testing`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Siga o projeto.** Use o framework, as bibliotecas de asserção, a estrutura de pastas e as convenções de nome que o projeto já adota. Não introduza framework novo sem perguntar.

**Honestidade.** Nunca enfraqueça uma asserção, remova um caso ou ajuste o teste só para ficar verde. Se o teste revela um defeito no código de produção, reporte o defeito e não altere o código sem pedido.

**Evidência de execução.** Não afirme que testes passaram sem tê-los executado. Registre comando, resultado e contagem. Se não puder executar (sem runner, sem Docker, sem permissão), diga isso explicitamente.

**Ambiente seguro.** Nunca rode testes de integração ou E2E contra produção ou banco compartilhado. Confira as variáveis de conexão antes, avise se o teste for destrutivo e verifique se o Docker está disponível antes de usar Testcontainers.

**Idioma.** Os nomes e comentários dos testes seguem o idioma do projeto; a conversa, o do usuário.

---

## 1. Modos de operação

Identifique o modo pelo pedido e diga qual está usando.

| Modo | Quando | O que faz |
| :--- | :--- | :--- |
| **Planejar** | Definir estratégia para uma feature ou módulo | Mapeia cenários e níveis, sem escrever código |
| **Escrever** | Criar testes para código ou comportamento definido | Escreve, executa e reporta |
| **Auditar** | Avaliar a suíte existente | Aponta lacunas, testes instáveis, asserções fracas e acoplamentos |
| **Gerar da spec** | "Gere os testes dos critérios de aceite" | Um ou mais testes por `CA-NN` (seção 3) |
| **Caracterizar** | Antes de refatorar código legado sem testes | Fixa o comportamento atual (seção 7.2) |

---

## 2. Workflow

1. **Contexto do projeto**: leia `AGENTS.md`, `GUIDELINE.md` e `TESTING.md` (se existirem), a configuração de testes e alguns testes existentes. As convenções do projeto prevalecem sobre as regras genéricas.
2. **Mapeamento de cenários**: caminho feliz, valores de borda (nulos, vazios, limites numéricos) e caminhos de falha. Cada regra de negócio relevante tem pelo menos um caso de erro.
3. **Escolha do nível** (seção 4): teste cada regra no nível mais barato que dê confiança.
4. **Dados de teste**: centralize em builders com valores padrão válidos (seção 5.3).
5. **Escrita** no padrão AAA, com um comportamento por teste (seção 5).
6. **Execução**: rode primeiro o arquivo novo e depois a suíte relevante. Registre o resultado.
7. **Registro de lacunas**: se sobraram cenários não cobertos, siga a seção 8.

Testes com mais de ~20 linhas vão para arquivos do projeto, nunca despejados no chat.

---

## 3. Gerar testes a partir da spec

- Cada critério de aceite `CA-NN` da spec (skill `-spec`) vira um ou mais testes. O Given/When/Then do critério mapeia direto para Arrange/Act/Assert.
- O nome do teste ou um comentário cita o ID (`CA-01`), e o critério referencia o requisito que cobre (`RF-01`).
- Cubra, para cada requisito relevante, o caminho feliz e ao menos um caso de erro.
- Ao concluir, informe quais critérios ficaram cobertos e quais não, e sugira ao usuário atualizar a coluna "Teste" da tabela de rastreabilidade da spec (a edição é da skill `-spec`).

---

## 4. Níveis de teste e pirâmide

| Nível | Escopo | Isolamento e infraestrutura |
| :--- | :--- | :--- |
| **Unitário** | Regras de negócio, domínio, algoritmos e cálculos | 100% isolado; I/O substituído por dublês; executa em milissegundos |
| **Integração** | Repositórios, filas, cache e clientes de APIs externas | Banco e filas efêmeros reais (Testcontainers ou equivalente); APIs simuladas em fronteira (WireMock, MSW); brokers de mensageria, com testes de consumidor idempotente e de reentrega de mensagens |
| **Contrato** | Compatibilidade de APIs entre consumidor e provedor | Testes baseados em schema contra o OpenAPI (veja `-api-design`) ou consumer-driven |
| **E2E** | Jornadas críticas pela UI ou pela API completa | Ambiente o mais próximo possível de produção |

**Estratégia da pirâmide**: muitos testes unitários, uma camada menor de integração e contrato, e poucos E2E. Uma regra de negócio é testada no nível mais baixo que a exercite; a integração verifica a cola (consultas, mapeamento, transações), não repete a regra.

**E2E**: apenas jornadas críticas; seletores estáveis (papéis de acessibilidade ou `data-testid`); dados preparados por API, não pela UI; artefatos de falha (trace, screenshot) habilitados.

---

## 5. Padrões de escrita

### 5.1. Estrutura AAA

```text
// Test Data Builder reutilizável
Classe UsuarioBuilder:
    usuario = { id: "usr-1", nome: "Ana Silva", email: "ana@exemplo.com", ativo: verdadeiro }
    comEmail(novoEmail) -> altera email e retorna self
    comoInativo()       -> altera ativo para falso e retorna self
    build()             -> retorna cópia imutável do usuario

// Caso de teste com AAA
Teste "envia email de boas-vindas quando o usuário está ativo (CA-01)":
    // Arrange
    servicoEmail = novo FakeServicoEmail()
    servico = novo ServicoNotificacao(servicoEmail)
    usuario = novo UsuarioBuilder().build()

    // Act
    resultado = servico.enviarBoasVindas(usuario)

    // Assert
    verifique(resultado.sucesso == verdadeiro)
    verifique(servicoEmail.enviados == [{ para: usuario.email, modelo: "boas-vindas" }])
```

### 5.2. Convenções

- Um comportamento por teste, sem `if` nem laços no corpo. Para valores de borda, use testes parametrizados.
- Nome descreve comportamento e condição ("rejeita pedido sem itens"), não o método testado.
- Teste a API pública observável, não métodos privados nem detalhes de implementação.
- Asserções específicas: valide status, dados e efeitos exatos, não apenas "não nulo".
- Snapshot só para saídas estáveis, e revise o diff do snapshot.

### 5.3. Dados de teste

Builders, object mothers ou factories com valores padrão válidos. Sem fixtures mutáveis compartilhadas entre testes. Para banco, escolha o isolamento conforme o paralelismo: rollback por transação, limpeza por teste ou contêiner por suíte.

### 5.4. Dublês

| Tipo | Uso |
| :--- | :--- |
| Stub | Retorna respostas prontas |
| Fake | Implementação simples funcional (repositório em memória) |
| Spy | Registra chamadas para verificação posterior |
| Mock | Verifica interações esperadas |

Prefira fakes ou dependências reais em memória para código do próprio projeto. Use mocks apenas nas fronteiras (rede, relógio, sistema de arquivos). Não teste o mock, e não mocke o que não controla sem uma camada de adaptação.

### 5.5. Determinismo e esperas ativas

Teste instável (*flaky*) não se resolve com retry: corrija a causa ou isole e registre uma tarefa.

- **Tempo**: relógio injetável ou fake timers. Nunca dependa do relógio do sistema.
- **Aleatoriedade**: semente fixa. **Fuso e locale**: fixos no teste.
- **Ordem e paralelismo**: nenhum teste depende da execução de outro.
- **Esperas**: substitua `sleep` por espera ativa com timeout.

```text
funcao esperarAte(condicao, timeoutMs = 2000, intervaloMs = 20):
    limite = agora() + timeoutMs
    enquanto agora() < limite:
        se condicao(): retornar
        dormir(intervaloMs)
    falhar("condição não atendida em " + timeoutMs + " ms")
```

### 5.6. Isolamento e limpeza

Mocks, banco de teste e variáveis de ambiente são redefinidos após cada teste (`tearDown`, `afterEach`). O teste deixa o ambiente como o encontrou.

---

## 6. Cobertura

Cobertura não é meta. Use cobertura de ramos nos módulos críticos, respeite os limites já configurados no projeto e interprete o relatório por risco, não por percentual. Teste de mutação é opcional e tem prioridade baixa.

---

## 7. Casos especiais

### 7.1. Teste de regressão de bug

Escreva o teste que reproduz o bug, confirme que ele **falha pelo motivo certo** e só então conserte. O conserto é implementação; o diagnóstico de causa raiz é da skill `-debug`.

### 7.2. Testes de caracterização (antes de refatorar)

Fixam o comportamento atual, inclusive o questionável, para que a refatoração (`-refactor`) não o altere sem querer. Parta de entradas reais ou representativas, registre as saídas observadas e sinalize comportamentos suspeitos sem corrigi-los.

---

## 8. Integração com outras skills e registro de lacunas

Se sobraram cenários, testes de integração ou lacunas da pirâmide, pergunte ao final:

> *"Identifiquei cenários e lacunas de teste que ainda precisam ser cobertos. Deseja que eu os registre no `TASKS.md` do projeto?"*

Com a confirmação, acione a skill `-tasks` (modo Importar). Cada tarefa leva origem `testing` e link relativo para o arquivo de teste ou o componente. Mapeamento de prioridade:

| Lacuna | Prioridade |
| :--- | :--- |
| Regra financeira ou regressão crítica | P0 |
| Integração e contrato | P1 |
| E2E | P2 |
| Carga, mutação e refatoração de fixtures | P3 |

**Fallback**: se `-tasks` não estiver disponível, apresente a lista no chat com prioridade, local e critério.

| Skill | Como se integra |
| :--- | :--- |
| `-spec` | Fonte dos critérios de aceite e da rastreabilidade |
| `-tasks` | Registro de lacunas; consome o resultado dos testes como evidência de conclusão |
| `-code-review` | Avalia qualidade, determinismo e cobertura dos testes de um diff |
| `-refactor` | Usa os testes de caracterização |
| `-api-design` | Define o contrato verificado nos testes de contrato |
| `-security` | Casos negativos de autorização (por exemplo, acesso a recurso de outro usuário) |
| `-sql` | Estratégia de teste de consultas e migrations |
| `-system-design` | Testes de idempotência, de falha e de reentrega com broker real ou emulado |
| `-debug` | O teste de regressão do bug é escrito aqui; a causa raiz é investigada lá |
| `-tech-*` | Framework, runner e utilitários da stack; sem a skill, use os padrões desta |

---

## 9. Armadilhas

- **Afirmar sucesso sem executar**: sempre registre comando e resultado.
- **Enfraquecer o teste para passar**: reduzir asserção ou remover caso esconde o defeito.
- **Vazamento de estado**: mocks não restaurados ou dados residuais causam falhas dependentes da ordem.
- **Testar detalhes internos**: acopla o teste à implementação e quebra em refatorações válidas.
- **Asserções fracas**: "não nulo" deixa passar respostas erradas.
- **Excesso de mocks**: o teste verifica o mock, não o comportamento.
- **Reimplementar a lógica de produção no teste**: o teste repete o bug junto com o código.
- **`sleep` e relógio real**: lentidão e instabilidade. Use espera ativa e relógio injetado.
- **Banco compartilhado ou de produção**: resultados imprevisíveis e risco real.
- **Cobertura como meta**: testes sem asserção inflam o número.
- **Vários comportamentos por teste**: a falha não diz o que quebrou.

---

## 10. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado (seção 1).
2. Arquivos de teste criados ou alterados, com links relativos.
3. Resultado da execução (comando, passou ou falhou, contagem) ou o motivo de não ter executado.
4. Cobertura dos critérios de aceite, quando houver spec: quais `CA-NN` estão cobertos.
5. Lacunas restantes e a pergunta sobre o registro em tarefas (seção 8).