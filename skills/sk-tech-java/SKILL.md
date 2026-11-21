---
name: sk-tech-java
description: "Orienta Java moderno e Spring Boot 3: Virtual Threads, records, tipos selados, Spring Data JPA sem N+1 (LAZY, EntityGraph, projeções, queries com índices), transações, Problem Details e testes. Use para APIs Spring Boot ou JPA. NÃO use para SQL avançado (sk-sql), OpenAPI (sk-api-design) nem segurança em profundidade (sk-security)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(mvn test *), Bash(mvn verify *), Bash(./mvnw test *), Bash(./mvnw verify *), Bash(gradle test *), Bash(gradle check *), Bash(./gradlew test *), Bash(./gradlew check *)
---

# Java e Spring Boot: concorrência simples, persistência sem surpresas

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-tech-java`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão.** Leia a versão do Java (`release`, toolchain) e do Spring Boot no `pom.xml` ou `build.gradle` e use só o que elas suportam: records (16), tipos selados (17), `switch` com padrões e Virtual Threads (21), propriedade de Virtual Threads do Spring (Boot 3.2). Pinning por `synchronized`, Scoped Values e recursos em preview mudam entre versões do JDK: **confirme na documentação oficial**.

**Siga o projeto.** Respeite a arquitetura em camadas, a ferramenta de build e as convenções existentes.

**Timebox e Circuit Breaker.** Ao corrigir erros de compilação, tipos, build, lint ou testes, pare após **3 tentativas consecutivas** sobre a mesma falha. Informe o erro exato, o que foi tentado e a causa provável, e peça direção ao usuário.

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
  - **Queries performáticas e índices**: toda nova consulta (JPQL, `@Query`, Criteria ou SQL nativo) deve ser performática (evitar Seq Scan, N+1 e ordenações sem suporte de índice). Inspecione filtros (`WHERE`), junções e ordenações e **entregue obrigatoriamente o script DDL/migration (Flyway, Liquibase ou equivalente) para criação dos índices adequados** à query proposta, com script de rollback.
- **Transações** na camada de serviço, `readOnly = true` nas leituras; cuidado com autoinvocação e métodos não públicos, que ignoram o proxy.
- **Erros** com `ProblemDetail` (`spring.mvc.problemdetails.enabled=true` ou `@RestControllerAdvice`), sem detalhes internos.
- **Configuração** com `@ConfigurationProperties` validado (records servem).
- **Observabilidade**: Actuator e Micrometer Tracing (`sk-observability`).
- **GraalVM Native Image** só com requisito de inicialização ou memória; exige *hints* de reflexão e testes dedicados.
- **Testes**: JUnit 5, testes de fatia (`@DataJpaTest`, `@WebMvcTest`), `@SpringBootTest` com moderação, Testcontainers (`sk-testing`).

---

## 2. Exemplos

Consulte implementações de referência em [examples/patterns.md](./examples/patterns.md): configuração recomendada (`application.properties`), DTO em `record` + estado em interface selada com `switch` exaustivo, e repositório JPA sem N+1 com `@EntityGraph` e projeção em record.

---

## 3. Integrações

`sk-sql` (consultas, índices e migrações), `sk-api-design` (contratos), `sk-security` (Spring Security, segredos), `sk-testing`, `sk-observability`, `sk-devops`, `sk-code-review`. Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 4. Armadilhas

- **Nova consulta JPA ou SQL sem verificação de performance e sem script/migration de índices adequados.**
- **`EAGER` padrão em `@ManyToOne` e `@OneToOne`**: uma consulta extra por linha (N+1).
- **`JOIN FETCH` de coleção com paginação**: o Hibernate pagina em memória.
- **Open-in-view ligado**: consultas escondidas na camada web e conexões presas.
- **`synchronized` com I/O em Virtual Threads** (JDKs anteriores ao 24): *pinning* da thread de plataforma.
- **`ThreadLocal` pesado com milhões de Virtual Threads.**
- **`@Transactional` em método privado ou chamado por autoinvocação**: o proxy não age.
- **Entidade JPA exposta direto na API.**
- **Capturar a exceção dentro da transação**: marca *rollback-only* de forma silenciosa ou esconde a falha.
- **Loop de build/lint (*fix loop*)**: insistir em correções sucessivas após 3 falhas sem acionar o circuit breaker.

---

## 5. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Código que compila: pacotes e imports completos, um tipo público por arquivo, links relativos.
3. Se implementar nova consulta SQL/JPA: verificação de performance e script/migration de criação dos índices adequados (com rollback).
4. Resultado de `mvn` ou `gradle` (build e testes), o motivo de não ter executado ou o relato do circuit breaker.
5. Somente se restarem pendências relevantes não resolvidas: pergunte se o usuário quer registrar no `TASKS.md` via `sk-tasks` (modo Importar, origem `tech-java`, P1 a P3; fallback em lista no chat).
