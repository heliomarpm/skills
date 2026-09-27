---
name: _tech-csharp
description: Orienta o desenvolvimento em C# e plataforma .NET. Use ao construir APIs, serviços de backend, acesso a banco de dados, fluxos assíncronos e processamento de alta performance.
---

# Tech Skill: C# & .NET Expert (C# 12/13 & .NET 8/9+)

Diretrizes técnicas especializadas para o desenvolvimento de serviços e APIs corporativas em C# e plataforma .NET.


> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧭 **Skill Ativa**: `_tech-csharp``

---

## 1. Processo de Execução de Engenharia .NET

Ao desenvolver soluções em C# e .NET:

1. **Modelagem de Domínio & DTOs**: Modele entidades e contratos com `record` imutáveis, ativando `#nullable enable` em todos os projetos.
2. **Camada de Dados Otimizada (EF Core)**: Configure consultas de leitura com `.AsNoTracking()` e `.AsSplitQuery()` para múltiplos relacionamentos, projetando diretamente para DTOs.
3. **Concorrência e Fluxo Assíncrono**: Propague `CancellationToken` em operações de I/O e utilize `IAsyncEnumerable<T>` para streaming de grandes volumes de dados.
4. **Resiliência e Injeção de Dependências**: Configure ciclos de vida corretos de DI e use o `ResiliencePipeline` do Polly v8 nativo para retentativas com jitter e circuit breakers.
5. **APIs Minimal & Validação**: Exponha endpoints com `TypedResults` e padronize erros no formato RFC 7807 (Problem Details).

---

## 2. Snippets Canônicos de Referência

### 2.1. C# 13 Lock, Primary Constructors & Streaming de Dados
```csharp
using System.Threading;
using System.Collections.Generic;
using System.Runtime.CompilerServices;

public sealed class OrderProcessingService(IOrderRepository repository, ILogger<OrderProcessingService> logger)
{
    // C# 13: Novo objeto de sincronização leve nativo
    private readonly Lock _syncLock = new();
    private int _processedCount;

    public async IAsyncEnumerable<OrderDto> StreamPendingOrdersAsync(
        string customerId,
        [EnumeratorCancellation] CancellationToken cancellationToken = default)
    {
        // Streaming de dados sem carregar tudo na memória RAM de uma vez
        await foreach (var order in repository.GetPendingOrdersStreamAsync(customerId, cancellationToken))
        {
            lock (_syncLock)
            {
                _processedCount++;
            }
            yield return new OrderDto(order.Id, order.Total, order.CreatedAt);
        }
    }
}

public readonly record struct OrderDto(Guid Id, decimal Total, DateTime CreatedAt);
```

### 2.2. EF Core Otimizado & Minimal API com TypedResults
```csharp
app.MapGet("/api/v1/orders/{id:guid}", async Task<Results<Ok<OrderDetailsDto>, NotFound, ProblemHttpResult>> (
    Guid id,
    AppDbContext db,
    CancellationToken ct) =>
{
    var order = await db.Orders
        .AsNoTracking()
        .Where(o => o.Id == id)
        .Select(o => new OrderDetailsDto(
            o.Id,
            o.Customer.Name,
            o.Items.Select(i => new OrderItemDto(i.Product.Name, i.Quantity, i.UnitPrice)).ToList()
        ))
        .FirstOrDefaultAsync(ct);

    return order is not null
        ? TypedResults.Ok(order)
        : TypedResults.NotFound();
})
.WithName("GetOrderById")
.WithOpenApi();
```

---

## 3. Armadilhas Críticas em .NET (*Gotchas*)

- ⚠️ **Resolução de Scoped em BackgroundService**: Injetar um serviço `Scoped` (ex: `DbContext`) diretamente no construtor de um `BackgroundService` (`Singleton`) causa exceção de *Scope Validation* em runtime. Crie explicitamente um escopo via `IServiceScopeFactory.CreateScope()`.
- ⚠️ **Produto Cartesiano com Múltiplos `.Include()`**: Consultas com mais de um `Include()` de coleções geram explosão de linhas duplicadas no SQL. Use `.AsSplitQuery()` para dividir em consultas paralelas controladas.
- ⚠️ **Bloqueio Síncrono de Threads (`.Result` ou `.Wait()`)**: Chamar `.Result` em tarefas assíncronas bloqueia threads do ThreadPool e causa *Deadlocks* em aplicações ASP.NET Core. Use estritamente `await`.

---

## 4. Padrão de Entrega do Agente

Ao entregar código em C# / .NET:
1. Inclua diretivas `using` completas e namespaces padronizados.
2. Declare tipos explicitamente com suporte a `#nullable enable`.
3. Garanta que métodos assíncronos recebam e propaguem `CancellationToken`.
