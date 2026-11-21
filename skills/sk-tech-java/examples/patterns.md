# Padrões e Exemplos de Java e Spring Boot (`sk-tech-java`)

## 1. Configuração recomendada

```properties
spring.threads.virtual.enabled=true
spring.jpa.open-in-view=false
spring.mvc.problemdetails.enabled=true
```

## 2. DTO e estados com tipo selado (cada tipo público em seu arquivo)

```java
// CriarPagamentoRequest.java
package com.empresa.pagamento.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.UUID;

public record CriarPagamentoRequest(
        @NotNull UUID clienteId,
        @NotNull @DecimalMin(value = "0.01", message = "O valor deve ser maior que zero") BigDecimal valor,
        @NotBlank String metodoPagamento) {}
```

```java
// StatusPagamento.java
package com.empresa.pagamento.dto;

import java.time.Instant;

public sealed interface StatusPagamento {
    record Pendente(String codigoPix) implements StatusPagamento {}
    record Aprovado(String nsuAutorizacao, Instant dataAprovacao) implements StatusPagamento {}
    record Rejeitado(String motivo) implements StatusPagamento {}
}
```

```java
// Uso com switch exaustivo (sem default: o compilador acusa um caso novo)
static String descricao(StatusPagamento status) {
    return switch (status) {
        case StatusPagamento.Pendente p -> "Aguardando pagamento: " + p.codigoPix();
        case StatusPagamento.Aprovado a -> "Aprovado, NSU " + a.nsuAutorizacao();
        case StatusPagamento.Rejeitado r -> "Rejeitado: " + r.motivo();
    };
}
```

## 3. Persistência sem N+1

```java
// Pedido.java (trecho)
@Entity
public class Pedido {
    @ManyToOne(fetch = FetchType.LAZY)
    private Cliente cliente;

    @OneToMany(mappedBy = "pedido")
    private List<ItemPedido> itens = new ArrayList<>();
    // ...
}
```

```java
// PedidoResumo.java
package com.empresa.pagamento.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record PedidoResumo(UUID id, BigDecimal total, String status) {}
```

```java
// PedidoRepository.java
public interface PedidoRepository extends JpaRepository<Pedido, UUID> {

    // Pedido, itens e cliente em uma única consulta
    @EntityGraph(attributePaths = {"itens", "cliente"})
    Optional<Pedido> findWithDetailsById(UUID id);

    // Projeção para listagens: só as colunas necessárias
    @Query("""
           select new com.empresa.pagamento.dto.PedidoResumo(p.id, p.total, p.status)
           from Pedido p
           where p.cliente.id = :clienteId
           """)
    List<PedidoResumo> listarResumosPorCliente(@Param("clienteId") UUID clienteId);
}
```
