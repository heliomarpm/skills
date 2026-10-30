---
name: sk-tech-dotnet
description: "Orienta C# e .NET moderno: nullable, records, EF Core eficiente (AsNoTracking, projeção, AsSplitQuery), async com CancellationToken, injeção de dependências e ciclos de vida, BackgroundService, resiliência (Polly v8), Minimal APIs com TypedResults e Problem Details, TimeProvider, logging estruturado e testes. Use sempre que o usuário pedir 'API em .NET', 'C#', 'EF Core', 'serviço em background', 'minimal API', 'otimize esta query do EF' ou 'migre de versão do .NET', mesmo sem dizer '.NET'. NÃO use para modelagem e consultas SQL em si (isso é sk-sql), contratos de API (isso é sk-api-design) nem para segurança em profundidade (isso é sk-security)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(dotnet test *), Bash(dotnet build *), Bash(dotnet format *)
---

# .NET: serviços corporativos eficientes e testáveis

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-tech-dotnet`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão.** Leia `TargetFramework` e `LangVersion` nos `.csproj` ou em `Directory.Build.props` e use só o que eles suportam (por exemplo, o tipo `Lock` e o `HybridCache` pedem versões recentes). Recursos novos ou depreciados (como `WithOpenApi`, em favor do suporte nativo de OpenAPI): confirme na documentação oficial da versão do projeto.

**Siga o projeto.** Respeite a arquitetura, o ORM, os analisadores e as convenções existentes.

**Modos.** Escrever, Revisar e Atualizar versão.

**Idioma.** O do usuário; nomes de código ficam como estão.

---

## 1. Princípios

- **Nullable habilitado** em todos os projetos; `record` para DTOs e objetos de valor; `required` para membros obrigatórios.
- **EF Core**:
  - Leitura com `AsNoTracking()` e projeção direta para DTO (`Select`).
  - Várias coleções com `Include` geram produto cartesiano: avalie `AsSplitQuery()` (divide em consultas **sequenciais**, com o custo de poder ler dados em momentos diferentes).
  - Atualizações em massa com `ExecuteUpdate` e `ExecuteDelete`.
  - O `DbContext` é *scoped*, não é thread-safe; fora de um escopo use `IDbContextFactory`.
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

### 2.1. Endpoint com projeção e `TypedResults`

```csharp
using Microsoft.AspNetCore.Http.HttpResults;

app.MapGet("/api/v1/pedidos/{id:guid}", async Task<Results<Ok<PedidoDetalheDto>, NotFound>> (
    Guid id, AppDbContext db, CancellationToken ct) =>
{
    var pedido = await db.Pedidos
        .AsNoTracking()
        .Where(p => p.Id == id)
        .Select(p => new PedidoDetalheDto(
            p.Id,
            p.Cliente.Nome,
            p.Itens.Select(i => new ItemDto(i.Produto.Nome, i.Quantidade, i.PrecoUnitario)).ToList()))
        .FirstOrDefaultAsync(ct);

    return pedido is null ? TypedResults.NotFound() : TypedResults.Ok(pedido);
})
.WithName("ObterPedido");
```

### 2.2. Streaming com cancelamento, tempo injetado e contador seguro

```csharp
public sealed class ProcessadorPedidos(
    IPedidoRepository repositorio, TimeProvider relogio, ILogger<ProcessadorPedidos> logger)
{
    private long _processados;

    public async IAsyncEnumerable<PedidoDto> ListarPendentesAsync(
        string clienteId, [EnumeratorCancellation] CancellationToken ct = default)
    {
        await foreach (var pedido in repositorio.ObterPendentesAsync(clienteId, ct))
        {
            Interlocked.Increment(ref _processados);
            yield return new PedidoDto(pedido.Id, pedido.Total, pedido.CriadoEm);
        }

        logger.LogInformation("Pendentes listados em {Instante}; total acumulado {Total}",
            relogio.GetUtcNow(), Interlocked.Read(ref _processados));
    }
}

public readonly record struct PedidoDto(Guid Id, decimal Total, DateTimeOffset CriadoEm);
```

### 2.3. `BackgroundService` com escopo por iteração

```csharp
public sealed class ReprocessadorWorker(IServiceScopeFactory escopos, ILogger<ReprocessadorWorker> logger)
    : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        using var timer = new PeriodicTimer(TimeSpan.FromMinutes(1));
        while (await timer.WaitForNextTickAsync(ct))
        {
            try
            {
                using var escopo = escopos.CreateScope();
                var db = escopo.ServiceProvider.GetRequiredService<AppDbContext>();
                // ... trabalho da iteração
            }
            catch (Exception ex) when (ex is not OperationCanceledException)
            {
                logger.LogError(ex, "Falha na iteração; o worker continua");
            }
        }
    }
}
```

---

## 3. Integrações

`sk-sql` (consultas e migrações), `sk-api-design` (contratos), `sk-security` (autorização, segredos), `sk-testing`, `sk-observability`, `sk-devops`, `sk-code-review`. Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 4. Armadilhas

- **Serviço *scoped* injetado em *singleton*** (inclusive `BackgroundService`): exceção de validação de escopo.
- **Vários `Include` de coleções sem avaliar `AsSplitQuery`**: explosão de linhas.
- **`DbContext` compartilhado entre threads.**
- **`.Result` ou `.Wait()`**: esgotamento do pool e deadlocks.
- **`async void`** fora de manipuladores de evento: exceções não observadas.
- **`DateTime.Now` no domínio**: testes frágeis e fuso incorreto.
- **`HttpClient` criado a cada chamada**: esgota sockets; use `HttpClientFactory`.
- **`catch (Exception)` que engole erros** sem registrar nem repropagar.
- **Ignorar o `CancellationToken`.**

---

## 5. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Código com `using` completos, nullable habilitado e `CancellationToken` propagado, com links relativos.
3. Resultado de `dotnet build`, `test` e `format`, ou o motivo de não ter executado.
4. Pendências: se houver, pergunte se o usuário quer registrar no `TASKS.md` via `sk-tasks` (modo Importar, origem `tech-dotnet`, P1 a P3; fallback em lista no chat).