---
name: -testing
description: Fornece diretrizes agnósticas de planejamento e automação de testes (Unitários, Integração, Contrato e E2E), padrão AAA, Test Data Builders, esperas ativas determinísticas e isolamento de mocks.
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(npm test *), Bash(pnpm test *), Bash(yarn test *), Bash(pytest *), Bash(go test *), Bash(dotnet test *), Bash(mvn test *), Bash(gradle test *), Bash(composer test *)
---

# Global Skill: Enterprise Test Automation Strategy (Language-Agnostic)

> **Escopo Global**: Esta skill é **estritamente agnóstica a linguagem e framework**. Seus conceitos, estruturas (AAA) e heurísticas aplicam-se a qualquer ecossistema (C#, Java, Python, TypeScript, PHP, Go, Rust, Dart, etc.).


> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧭 **Skill Ativa**: `-testing``

---

## 1. Processo Universal de Execução de Testes

1. **Mapeamento de Cenários & Limites**: Identifique o caminho feliz (*happy path*), casos de borda (*boundary values*: nulos, limites numéricos, vazios) e cenários de falha (*unhappy path*).
2. **Criação de Test Data Builders & Fixtures**: Centralize a instanciação de dados de domínio em geradores reutilizáveis com valores padrão válidos.
3. **Estruturação no Padrão AAA**: Separe visualmente cada teste nos blocos *Arrange* (Preparar), *Act* (Agir) e *Assert* (Verificar).
4. **Isolamento e Limpeza de Estado**: Mocks, bancos de teste e variáveis de ambiente devem ser limpos ou revertidos após cada execução (`tearDown` / `afterEach`).
5. **Determinismo Absoluto**: Elimine pausas com tempo fixo (`sleep`) e isole o teste do relógio do sistema usando *Clock Mocks / Fake Timers*.

---

## 2. Padrão Estrutural AAA e Test Data Builder (Universal)

*(O exemplo conceitual abaixo ilustra a estrutura que deve ser adaptada para a biblioteca de teste do projeto ativo: xUnit, pytest, Pest, Vitest, JUnit, etc.).*

```
// 1. Test Data Builder reutilizável
Classe UsuarioBuilder:
    usuario = { id: "usr-1", nome: "Ana Silva", email: "ana@exemplo.com", ativo: verdadeiro }
    comEmail(novoEmail) -> altera email e retorna self
    comoInativo() -> altera ativo para falso e retorna self
    build() -> retorna cópia imutável do usuario

// 2. Caso de Teste com Padrão AAA
Teste "deve enviar email de boas-vindas quando usuario for ativo":
    // Arrange: Preparar dados e dublês de teste
    servicoEmailMock = novo MockServicoEmail(sucesso = verdadeiro)
    servicoNotificacao = novo ServicoNotificacao(servicoEmailMock)
    usuario = novo UsuarioBuilder().build()

    // Act: Executar estritamente a unidade sob teste
    resultado = servicoNotificacao.enviarBoasVindas(usuario)

    // Assert: Validações ricas e específicas
    verifique(resultado.sucesso == verdadeiro)
    verifique(servicoEmailMock.chamadasEnvio == 1)
    verifique(servicoEmailMock.destinatario == usuario.email)
```

---

## 3. Matriz Universal de Níveis de Teste

| Nível | Escopo | Isolamento / Infraestrutura | Mapeamento Poliglota de Ferramentas |
| :--- | :--- | :--- | :--- |
| **Unitário** | Lógica de negócios, domínio, algoritmos e cálculos. | 100% isolado. I/O substituído por dublês (Stubs/Mocks). | xUnit, pytest, Vitest, Jest, Pest, JUnit, flutter_test |
| **Integração** | Repositórios com banco de dados, filas e APIs externas. | Bancos e filas efêmeros reais (Testcontainers); APIs simuladas (WireMock, MSW). | Testcontainers (Java, .NET, Python, Node, Go), WebApplicationFactory |
| **Ponta a Ponta (E2E)** | Jornadas críticas e fluxos completos do usuário pela UI. | Ambiente integrado o mais próximo possível de produção. | Playwright, Cypress, Patrol (mobile), Maestro |

---

## 4. Armadilhas Críticas em Testes (*Gotchas*)

- ⚠️ **Test Leakage (Vazamento de Estado)**: Mocks não redefinidos ou dados residuais em bancos compartilhados causam falhas aleatórias dependendo da ordem dos testes.
- ⚠️ **Testar Detalhes Internos em Vez de Comportamento**: Acoplar asserções a métodos privados quebra os testes durante refatorações válidas. Teste apenas a API pública observável.
- ⚠️ **Asserções Fracas/Falsos Positivos**: Checagens genéricas de não-nulo deixam passar respostas com erros de servidor não tratados. Valide status e dados exatos.

---

## 5. Padrão de Entrega do Agente

Ao entregar testes automatizados:
1. Siga a estrutura AAA com convenções descritivas de nomenclatura.
2. Utilize o framework e bibliotecas de asserção oficiais da linguagem do projeto.
3. Garanta que testes unitários executem em milissegundos sem depender de rede ou disco real.

---

## 6. 📝 Acompanhamento de Cobertura com `-task-management` (Sempre ao Final)

Sempre ao término do planejamento, escrita ou auditoria da estratégia de testes, se houver cenários críticos, testes de integração ou gaps da pirâmide de testes não implementados na sessão, **pergunte obrigatoriamente ao usuário ao final da resposta**:

> *"Identifiquei cenários e lacunas de teste que ainda precisam ser cobertos. Deseja que eu registre essas tarefas de teste no arquivo `TASKS.md` do projeto?"*

Ao receber a confirmação do usuário (ou se instruído a registrar automaticamente):
1. **Ativação da Skill**: Acione a skill **`-task-management`** para atualizar o backlog de testes.
2. **Localização em Cascata**: A skill `-task-management` buscará por `./TASKS.md` ➔ `./agents/TASKS.md` ➔ `./.agents/TASKS.md` (com tolerância a `TASK.md` / `task.md`).
3. **Mapeamento de Prioridades de Teste**:
   - `🚨 1. Bloqueadores / Alta Prioridade`: Testes unitários para regras financeiras e testes de regressão para bugs críticos descobertos em produção.
   - `⚠️ 2. Média Prioridade`: Testes de integração com banco de dados/filas efêmeras e validação de contratos de API.
   - `💡 3. Baixa Prioridade / Otimização`: Testes de carga, testes de mutação e refatoração de fixtures antigas.
   - `✅ 4. Concluído recentemente`: Suítes de teste criadas, executadas e validadas com sucesso na sessão com `- [x]`.
4. **Navegabilidade**: Toda tarefa deve indicar o arquivo de teste correspondente ou o componente a ser testado com links `[arquivo.ext](file:///...)`.
