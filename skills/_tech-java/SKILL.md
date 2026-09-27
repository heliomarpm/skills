---
name: _tech-java
description: "Orienta o desenvolvimento corporativo em Java 21+ LTS e Spring Boot 3.x. Cobre Virtual Threads (Project Loom), Records, Pattern Matching, Sealed Classes, Spring Data JPA sem N+1, GraalVM Native e Micrometer."
---

# Java 21+ & Spring Boot 3.x Specialist Skill

Esta skill fornece diretrizes técnicas especializadas para engenharia de software de alta performance no ecossistema Java moderno. O foco está no **Java 21+ LTS** e **Spring Boot 3.x**, explorando **Virtual Threads**, modelagem imutável com **Records**, consultas performáticas no **Spring Data JPA** e observabilidade nativa com **Micrometer**.

> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧭 **Skill Ativa**: `_tech-java``

---

## 1. Processo de Execução em Java Moderno

Ao desenvolver ou refatorar serviços Java:

1. **Virtual Threads First (Project Loom)**:
   - No Spring Boot 3.2+, habilite Virtual Threads via configuração (`spring.threads.virtual.enabled=true`).
   - Use código imperativo síncrono e limpo para operações bloqueantes de I/O (JDBC, HTTP Client, chamadas REST). Cada requisição roda em sua própria Virtual Thread leve sem sobrecarregar a JVM.
2. **Modelagem de Domínio com Records & Sealed Types**:
   - Utilize **Records** para todos os DTOs, mensagens de eventos e objetos de valor imutáveis.
   - Utilize **Sealed Interfaces** combinadas com **Pattern Matching** em blocos `switch` para modelar hierarquias de estados com garantia de exaustividade em tempo de compilação.
3. **Persistência Eficiente no Spring Data JPA**:
   - Evite o problema clássico de **N+1 queries**:
     - Defina sempre `FetchType.LAZY` para `@ManyToOne` e `@OneToOne` (o padrão do JPA para estas anotações é perigosamente `EAGER`).
     - Use `@EntityGraph` ou consultas JPQL com `JOIN FETCH` para carregar relacionamentos necessários em uma única consulta SQL.
     - Prefira **Spring Data Projections** baseadas em **Records** para carregar apenas as colunas necessárias em listagens.
4. **Resiliência e Observabilidade Integrada**:
   - Adote **Micrometer Tracing** com OpenTelemetry para correlacionar traces e métricas automaticamente via Spring Boot Actuator.
   - Trate erros com `@RestControllerAdvice` retornando a especificação **RFC 7807 (ProblemDetail)** nativa do Spring 6.

---

## 2. Snippets Canônicos de Referência

### 2.1. Habilitação de Virtual Threads & Task Executor (Spring Boot 3)
```properties
# application.properties
spring.threads.virtual.enabled=true
```

```java
package com.empresa.pagamento.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.task.support.TaskExecutorAdapter;
import java.util.concurrent.Executors;
import java.util.concurrent.Executor;

@Configuration
public class AsyncConfig {

    @Bean
    public Executor taskExecutor() {
        // Executor baseado em Virtual Threads para rotinas assíncronas (@Async)
        return new TaskExecutorAdapter(Executors.newVirtualThreadPerTaskExecutor());
    }
}
```

### 2.2. DTO com Record, Validação e Sealed State Pattern
```java
package com.empresa.pagamento.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.UUID;

// 1. DTO imutável e conciso com Record
public record CriarPagamentoRequest(
    @NotNull UUID clienteId,
    @NotNull @DecimalMin(value = "0.01", message = "O valor deve ser maior que zero") BigDecimal valor,
    @NotNull String metodoPagamento
) {}

// 2. Hierarquia selada para estados de transação com Pattern Matching exaustivo
public sealed interface StatusPagamento permits StatusPagamento.Pendente, StatusPagamento.Aprovado, StatusPagamento.Rejeitado {
    record Pendente(String codigoPix) implements StatusPagamento {}
    record Aprovado(String nsuAutorizacao, java.time.Instant dataAprovacao) implements StatusPagamento {}
    record Rejeitado(String motivo) implements StatusPagamento {}
}
```

### 2.3. Spring Data JPA com Projeção em Record e EntityGraph (Anti-N+1)
```java
package com.empresa.pagamento.repository;

import com.empresa.pagamento.domain.Pedido;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.util.Optional;
import java.util.UUID;
import java.math.BigDecimal;

public interface PedidoRepository extends JpaRepository<Pedido, UUID> {

    // Carrega pedido e itens em uma única consulta SQL (Resolve N+1)
    @EntityGraph(attributePaths = {"itens", "cliente"})
    Optional<Pedido> findWithDetailsById(UUID id);

    // Projeção baseada em Record para relatórios de alta performance
    record PedidoResumoDto(UUID id, BigDecimal total, String status) {}

    @Query("SELECT new com.empresa.pagamento.repository.PedidoRepository$PedidoResumoDto(p.id, p.total, p.status) FROM Pedido p WHERE p.cliente.id = :clienteId")
    java.util.List<PedidoResumoDto> listarResumosPorCliente(UUID clienteId);
}
```

---

## 3. Armadilhas Críticas em Java 21 & Spring Boot (*Gotchas*)

- ⚠️ **Pinning de Virtual Threads com `synchronized`**: Usar blocos `synchronized` clássicos dentro de métodos executados por Virtual Threads prende (*pins*) a Virtual Thread à Carrier Thread do sistema operacional, bloqueando o pool de concorrência. Substitua blocos sincronizados por `java.util.concurrent.locks.ReentrantLock`.
- ⚠️ **`FetchType.EAGER` Padrão do JPA**: Esquecer de declarar `fetch = FetchType.LAZY` em anotações `@ManyToOne` ou `@OneToOne`. O Hibernate dispara uma consulta SQL separada para cada linha retornada, gerando lentidão brutal (*N+1 problem*).
- ⚠️ **`ThreadLocal` Excessivo com Virtual Threads**: Armazenar objetos pesados em `ThreadLocal`. Como Virtual Threads podem ser criadas aos milhões, o uso desenfreado de `ThreadLocal` esgota a memória Heap da JVM. Use **Scoped Values** (Java 21 Preview / Java 22+) sempre que possível.

---

## 4. Padrão Rigoroso de Entrega

Ao entregar soluções em Java:
1. **Assinatura Obrigatória**: Iniciar a resposta com `> 🧭 **Skill Ativa**: _tech-java`.
2. **Tipagem e Imutabilidade**: Use Records para DTOs e tipos selados para enums com estado.
3. **Zero N+1**: Toda consulta JPA com relacionamentos deve usar `@EntityGraph` ou projeção explícita.
4. **Tratamento RFC 7807**: Erros de controller devem ser expostos via `ProblemDetail`.
