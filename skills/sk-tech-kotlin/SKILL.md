---
name: sk-tech-kotlin
description: "Orienta Kotlin moderno (JVM Spring/Ktor e Android Jetpack Compose): null safety, sealed/data classes, Coroutines/Flow estruturados, Exposed/JPA/Room performático com índices e testes. Use para serviços ou apps em Kotlin. NÃO use para Java (sk-tech-java), modelagem SQL (sk-sql), OpenAPI (sk-api-design) nem segurança (sk-security)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(gradle test *), Bash(gradle check *), Bash(./gradlew test *), Bash(./gradlew check *), Bash(./gradlew ktlintCheck *), Bash(./gradlew detekt *), Bash(mvn test *), Bash(./mvnw test *)
---

# Kotlin: código conciso, concorrência estruturada e segurança de nulos

Orienta aplicações em Kotlin moderno para backend JVM (Spring Boot ou Ktor) e apps Android (Jetpack Compose), mantendo concorrência estruturada, modelagem expressiva e acesso a dados performático.

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-tech-kotlin`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão e plataforma.** Leia `build.gradle.kts` / `build.gradle`, `gradle/libs.versions.toml` ou `pom.xml` para confirmar a versão do Kotlin, da JVM e das bibliotecas (Spring Boot, Ktor, Exposed, Coroutines, Jetpack Compose/Room). Use apenas APIs suportadas pela versão do projeto.

**Siga o projeto.** Respeite o estilo funcional ou orientado a objetos, o framework web/UI e a ferramenta de qualidade (`ktlint`, `detekt`) existentes. Para bases majoritariamente Java em Spring Boot, acione `sk-tech-java`.

**Timebox e Circuit Breaker.** Ao corrigir erros de compilação, Gradle/Maven, tipos, linter (`detekt`/`ktlint`) ou testes, pare após **3 tentativas consecutivas** sobre a mesma falha. Informe o erro exato, o que foi tentado e a causa provável, e peça direção ao usuário.

**Modos.** Escrever, Revisar e Atualizar versão.

**Idioma.** O do usuário; nomes de código seguem as convenções do Kotlin.

---

## 1. Princípios

- **Idioma Kotlin e *null safety***: prefira `val` e coleções imutáveis (`List`, `Set`, `Map`) por padrão; nunca use `!!` em código de produção (estreite ou retorne erro explícito de domínio). Use `data class` para DTOs/valores puros, `value class` para identificadores de domínio e `sealed interface`/`sealed class` com `when` exaustivo para estados e erros. Valores monetários e precisos usam `BigDecimal`.
- **Concorrência estruturada (`Coroutines` e `Flow`)**: nunca lance corrotinas órfãs com `GlobalScope` nem use `runBlocking` dentro de rotas HTTP, funções `suspend` ou thread principal de UI. Injete `CoroutineDispatcher` para testabilidade, isole I/O bloqueante com `Dispatchers.IO` e em blocos `catch (e: Exception)` **relance obrigatoriamente `CancellationException`**.
- **Backend JVM (Spring Boot ou Ktor)**: mantenha serialização explícita (`kotlinx.serialization` ou Jackson com módulo Kotlin), validação na fronteira e erros estruturados em Problem Details (`sk-api-design`). No Spring Data JPA, mantenha `open-in-view: false`, use transações bem delimitadas e **nunca use `data class` em entidades `@Entity` JPA** com relacionamentos `LAZY` (o `equals`/`hashCode`/`toString` gerado pode disparar N+1 ou stack overflow).
- **Android e Jetpack Compose**: concentre estado de tela em um `UiState` imutável exposto via `StateFlow` no `ViewModel`, coletando na UI com `collectAsStateWithLifecycle()`. Mantenha `@Composable` stateless sempre que possível, passe lambdas de evento para cima, evite efeitos colaterais soltos na recomposição (`LaunchedEffect` com chave estável), garanta alvos >= `48×48 dp`, `semantics` e suporte a claro/escuro (`sk-design-system`).
- **Persistência e consultas SQL (Exposed, JPA, jOOQ, Room ou SQLDelight)**: evite `SELECT *`, consultas N+1 e carregamento de grafos desnecessários. Use projeções estritas e paginação explícita. Analise filtros, junções e ordenações e **entregue obrigatoriamente o script/migration de criação dos índices adequados** (Flyway/Liquibase no backend ou `@Index`/migration no Room/SQLDelight) acompanhado de script de rollback (`sk-sql`).
- **Segurança e observabilidade**: nunca serialize segredos ou dados pessoais em logs/traces (`sk-security`, `sk-observability`); trate timeouts em clientes HTTP (Ktor Client / WebClient).
- **Testes**: JUnit 5 ou Kotest com `kotlinx-coroutines-test` (`runTest`), Testcontainers para banco real no backend e testes de UI/Compose com estado determinístico (`sk-testing`).

---

## 2. Exemplos

Consulte implementações de referência em [examples/patterns.md](./examples/patterns.md): caso de uso com `sealed interface`, `coroutineScope`, injeção de `CoroutineDispatcher` preservando `CancellationException`; consulta projetada em Exposed acompanhada de migration Flyway de índice + rollback; e tela Jetpack Compose com `StateFlow` e `collectAsStateWithLifecycle()`.

---

## 3. Integrações

`sk-sql` (modelagem, planos de execução, JPA/Exposed/Room e índices), `sk-api-design` (contratos REST e Problem Details), `sk-security` (autenticação, autorização por recurso e segredos), `sk-observability` (logs estruturados, traces e métricas), `sk-design-system` (tokens, contraste claro/escuro e a11y Android), `sk-testing` (`runTest`, MockK e Testcontainers), `sk-devops` (builds Gradle/Docker JVM), `sk-upgrade` (upgrades Kotlin/Spring/AGP), `sk-code-review` e `sk-tasks`. Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 4. Armadilhas

- **Operador `!!` em produção**: transforma possível nulo previsível em `NullPointerException` sem contexto.
- **`GlobalScope.launch` ou `runBlocking` em rota/UI**: vaza corrotinas ou trava threads do servidor/interface.
- **Engolir `CancellationException` num `catch (e: Exception)` genérico**: quebra o cancelamento estruturado de toda a hierarquia de corrotinas.
- **Usar `data class` em `@Entity` JPA**: `equals`, `hashCode` e `toString` quebram proxies `LAZY` e coleções de sessão Hibernate.
- **Consultas Exposed/JPA/Room sem projeção e sem índices adequados/rollback**: geram N+1, *seq scans* e lentidão em produção.
- **Coletar `StateFlow` com `collectAsState()` simples no Android**: mantém coleta ativa em segundo plano desperdiçando bateria e rede.
- **Passar listas mutáveis instáveis no Compose**: impede otimização de recomposição (prefira listas imutáveis estáveis e `key` explícita em `LazyColumn`).
- **Loop de build/lint (*fix loop*)**: insistir em correções sucessivas após 3 falhas sem acionar o circuit breaker.

---

## 5. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Código Kotlin idiomático com *null safety*, concorrência estruturada e sem `!!`/`GlobalScope`, com links relativos.
3. Se implementar nova query ou tabela (Exposed, JPA, Room, SQLDelight): verificação de performance e **script/migration de criação dos índices adequados com rollback**.
4. Resultado de `gradle`/`mvn`, `detekt`/`ktlint` e testes, o motivo de não ter executado ou o relato do circuit breaker.
5. Somente se restarem pendências relevantes não resolvidas: pergunte se o usuário quer registrar no `TASKS.md` via `sk-tasks` (modo Importar, origem `tech-kotlin`, P1 a P3; fallback em lista no chat).
