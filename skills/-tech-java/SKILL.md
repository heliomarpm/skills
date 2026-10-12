---
name: -tech-java
description: "Orienta Java moderno e Spring Boot 3: Virtual Threads para I/O bloqueante, records e tipos selados com pattern matching, Spring Data JPA sem N+1 (LAZY, EntityGraph, projeções, open-in-view desligado), transações, Problem Details, configuração tipada, observabilidade e testes. Use sempre que o usuário pedir 'API Spring Boot', 'Java', 'JPA', 'N+1', 'Virtual Threads', 'record', 'migre de versão do Java ou do Spring' ou 'otimize esta consulta JPA', mesmo sem dizer 'Java'. NÃO use para modelagem e SQL em si (isso é -sql), contratos de API (isso é -api-design) nem para segurança em profundidade (isso é -security)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(mvn test *), Bash(mvn verify *), Bash(./mvnw test *), Bash(./mvnw verify *), Bash(gradle test *), Bash(gradle check *), Bash(./gradlew test *), Bash(./gradlew check *)
---

# Java e Spring Boot: concorrência simples, persistência sem surpresas

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativa**: `-tech-java`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão.** Leia a versão do Java (`release`, toolchain) e do Spring Boot no `pom.xml` ou `build.gradle` e use só o que elas suportam: records (16), tipos selados (17), `switch` com padrões e Virtual Threads (21), propriedade de Virtual Threads do Spring (Boot 3.2). Pinning por `synchronized`, Scoped Values e recursos em preview mudam entre versões do JDK: **confirme na documentação oficial**.

**Siga o projeto.** Respeite a arquitetura em camadas, a ferramenta de build e as convenções existentes.

**Modos.** Escrever, Revisar e Atualizar versão.

**Idioma.** O do usuário; nomes de código ficam como estão.

---

## 1. Princípios

- **Virtual Threads** para I/O bloqueante (JDBC, HTTP). Com Spring Boot 3.2+, a propriedade `spring.threads.virtual.enabled=true` já configura o servidor web e os executores de `@Async`: não crie executor próprio sem necessidade. Não ajudam em trabalho de CPU, e o limite de concorrência real continua sendo o do pool de conexões e dos recursos externos. Em JDKs anteriores ao 24, evite `synchronized` em trechos com I/O (use `ReentrantLock`).
- **Records** para DTOs, eventos e objetos de valor; **tipos selados com `switch` de padrões** para estados, com exaustividade verificada pelo compilador.
- **Um tipo público por arquivo.**
- **JPA sem N+1**:
  - `@ManyToOne` e `@OneToOne` têm `EAGER` por padrão: declare `fetch = FetchType.LAZY`.
  - Carregue o necessário com `@EntityGraph` ou `JOIN FETCH`; em listagens, use projeções (DTO ou interface).
  - Não pagine com `JOIN FETCH` de coleção (o Hibernate pagina em memória); use consulta em duas etapas ou `default_batch_fetch_size`.
  - `spring.jpa.open-in-view=false`.
- **Transações** na camada de serviço, `readOnly = true` nas leituras; cuidado com autoinvocação e métodos não públicos, que ignoram o proxy.
- **Erros** com `ProblemDetail` (`spring.mvc.problemdetails.enabled=true` ou `@RestControllerAdvice`), sem detalhes internos.
- **Configuração** com `@ConfigurationProperties` validado (records servem).
- **Observabilidade**: Actuator e Micrometer Tracing (`-observability`).
- **GraalVM Native Image** só com requisito de inicialização ou memória; exige *hints* de reflexão e testes dedicados.
- **Testes**: JUnit 5, testes de fatia (`@DataJpaTest`, `@WebMvcTest`), `@SpringBootTest` com moderação, Testcontainers (`-testing`).

---

## 2. Exemplos

### 2.1. Configuração

```properties
spring.threads.virtual.enabled=true
spring.jpa.open-in-view=false
spring.mvc.problemdetails.enabled=true
```

### 2.2. DTO e estados com tipo selado (cada tipo público em seu arquivo)

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

### 2.3. Persistência sem N+1

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

---

## 3. Integrações

`-sql` (consultas, índices e migrações), `-api-design` (contratos), `-security` (Spring Security, segredos), `-testing`, `-observability`, `-devops`, `-code-review`. Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 4. Armadilhas

- **`EAGER` padrão em `@ManyToOne` e `@OneToOne`**: uma consulta extra por linha (N+1).
- **`JOIN FETCH` de coleção com paginação**: o Hibernate pagina em memória.
- **Open-in-view ligado**: consultas escondidas na camada web e conexões presas.
- **`synchronized` com I/O em Virtual Threads** (JDKs anteriores ao 24): *pinning* da thread de plataforma.
- **`ThreadLocal` pesado com milhões de Virtual Threads.**
- **`@Transactional` em método privado ou chamado por autoinvocação**: o proxy não age.
- **Entidade JPA exposta direto na API.**
- **Capturar a exceção dentro da transação**: marca *rollback-only* de forma silenciosa ou esconde a falha.

---

## 5. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Código que compila: pacotes e imports completos, um tipo público por arquivo, links relativos.
3. Resultado de `mvn` ou `gradle` (build e testes), ou o motivo de não ter executado.
4. Pendências: se houver, pergunte se o usuário quer registrar no `TASKS.md` via `-tasks` (modo Importar, origem `tech-java`, P1 a P3; fallback em lista no chat).