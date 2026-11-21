# Padrões e Exemplos de .NET (`sk-tech-dotnet`)

## 1. Endpoint Minimal API com projeção EF Core e `TypedResults`

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

## 2. Streaming com cancelamento, tempo injetado e contador seguro

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

## 3. `BackgroundService` com escopo por iteração

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
