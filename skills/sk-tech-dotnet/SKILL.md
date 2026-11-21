---
name: sk-tech-dotnet
description: "Orienta C# e .NET moderno: nullable, records, EF Core eficiente (AsNoTracking, projeção, AsSplitQuery), queries performáticas com índices, async com CancellationToken, DI, BackgroundService, Polly v8 e Minimal APIs. Use para APIs ou acesso a dados .NET. NÃO use para SQL avançado (sk-sql), OpenAPI (sk-api-design) nem Auth (sk-security)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(dotnet test *), Bash(dotnet build *), Bash(dotnet format *)
---

# .NET: serviços corporativos eficientes e testáveis

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-tech-dotnet`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão.** Leia `TargetFramework` e `LangVersion` nos `.csproj` ou em `Directory.Build.props` e use só o que eles suportam (por exemplo, o tipo `Lock` e o `HybridCache` pedem versões recentes). Recursos novos ou depreciados (como `WithOpenApi`, em favor do suporte nativo de OpenAPI): confirme na documentação oficial da versão do projeto.

**Siga o projeto.** Respeite a arquitetura, o ORM, os analisadores e as convenções existentes.

**Timebox e Circuit Breaker.** Ao corrigir erros de compilação, tipos, build, lint ou testes, pare após **3 tentativas consecutivas** sobre a mesma falha. Informe o erro exato, o que foi tentado e a causa provável, e peça direção ao usuário.

**Modos.** Escrever, Revisar e Atualizar versão.

**Idioma.** O do usuário; nomes de código ficam como estão.

---

## 1. Princípios

- **Nullable habilitado** em todos os projetos; `record` para DTOs e objetos de valor; `required` para membros obrigatórios.
- **EF Core e consultas**:
  - Leitura com `AsNoTracking()` e projeção direta para DTO (`Select`).
  - Várias coleções com `Include` geram produto cartesiano: avalie `AsSplitQuery()` (divide em consultas **sequenciais**, com o custo de poder ler dados em momentos diferentes).
  - Atualizações em massa com `ExecuteUpdate` e `ExecuteDelete`.
  - O `DbContext` é *scoped*, não é thread-safe; fora de um escopo use `IDbContextFactory`.
  - **Queries performáticas e índices**: toda nova consulta (LINQ/EF Core, Dapper ou SQL nativo) deve ser performática (evitar Seq Scan, N+1 e ordenações sem índice). Inspecione predicados (`Where`), junções e ordenações (`OrderBy`) e **entregue obrigatoriamente o script/migration (EF Core Migration ou DDL) para criação dos índices adequados** à query proposta, com o respectivo rollback (`DropIndex`).
- **Async**: propague `CancellationToken` em todo I/O; nada de `.Result` ou `.Wait()` (esgota o pool de threads e pode causar deadlock); `IAsyncEnumerable<T>` para streaming; `ConfigureAwait(false)` em bibliotecas.
- **Injeção de dependências**: ciclos de vida corretos; serviço *scoped* dentro de `BackgroundService` só via `IServiceScopeFactory`; configuração com o padrão Options e `ValidateOnStart()`.
- **Tempo**: `TimeProvider` injetado, não `DateTime.Now`, para tornar o código testável.
- **Resiliência**: `HttpClientFactory` com timeout e `Microsoft.Extensions.Http.Resilience` ou `ResiliencePipeline` do Polly v8 (retry com backoff e jitter, circuit breaker).
- **APIs Minimal**: `TypedResults`, validação na borda e erros em Problem Details (`AddProblemDetails()`).
- **Concorrência**: `Interlocked` para contadores; `Lock` (versões recentes) ou `lock` para seções críticas com vários campos.
- **Logs** estruturados com templates (`{Campo}`), sem concatenação, e sem PII; traces e métricas com OpenTelemetry (`sk-observability`).
- **Testes**: xUnit, `WebApplicationFactory` e Testcontainers para integração (`sk-testing`); `dotnet format` e analisadores no CI.

---

## 2. Exemplos

Consulte implementações de referência em [examples/patterns.md](./examples/patterns.md): endpoint Minimal API com projeção `AsNoTracking` + `TypedResults`, streaming `IAsyncEnumerable` com `TimeProvider` e `Interlocked`, e `BackgroundService` com escopo via `IServiceScopeFactory`.

---

## 3. Integrações

`sk-sql` (consultas e migrações), `sk-api-design` (contratos), `sk-security` (autorização, segredos), `sk-testing`, `sk-observability`, `sk-devops`, `sk-code-review`. Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 4. Armadilhas

- **Nova query SQL ou EF Core sem verificar performance e sem entregar script/migration de índices adequados.**
- **Serviço *scoped* injetado em *singleton*** (inclusive `BackgroundService`): exceção de validação de escopo.
- **Vários `Include` de coleções sem avaliar `AsSplitQuery`**: explosão de linhas.
- **`DbContext` compartilhado entre threads.**
- **`.Result` ou `.Wait()`**: esgotamento do pool e deadlocks.
- **`async void`** fora de manipuladores de evento: exceções não observadas.
- **`DateTime.Now` no domínio**: testes frágeis e fuso incorreto.
- **`HttpClient` criado a cada chamada**: esgota sockets; use `HttpClientFactory`.
- **`catch (Exception)` que engole erros** sem registrar nem repropagar.
- **Ignorar o `CancellationToken`.**
- **Loop de build/lint (*fix loop*)**: insistir em correções sucessivas após 3 falhas sem acionar o circuit breaker.

---

## 5. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Código com `using` completos, nullable habilitado e `CancellationToken` propagado, com links relativos.
3. Se implementar nova consulta SQL ou EF Core: verificação de performance e script/migration de criação dos índices adequados (com rollback).
4. Resultado de `dotnet build`, `test` e `format`, o motivo de não ter executado ou o relato do circuit breaker.
5. Somente se restarem pendências relevantes não resolvidas: pergunte se o usuário quer registrar no `TASKS.md` via `sk-tasks` (modo Importar, origem `tech-dotnet`, P1 a P3; fallback em lista no chat).
