---
name: sk-tech-rust
description: "Orienta Rust idiomático: ownership/borrowing, erros com thiserror/anyhow sem unwrap em produção, tokio assíncrono estruturado, axum/actix, sqlx/Diesel performático com índices, clippy e cargo audit. Use para serviços ou CLIs em Rust. NÃO use para modelagem SQL (sk-sql), OpenAPI (sk-api-design) nem segurança geral (sk-security)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(cargo test *), Bash(cargo check *), Bash(cargo build *), Bash(cargo clippy *), Bash(cargo fmt --check *), Bash(cargo audit)
---

# Rust: segurança de memória, previsibilidade e desempenho

Orienta serviços HTTP, workers, bibliotecas e CLIs em Rust moderno com tratamento explícito de erros, concorrência segura e acesso SQL verificado.

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-tech-rust`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão e manifesto.** Leia `Cargo.toml` (`edition`, `rust-version`/MSRV, *workspace members*, features) e `Cargo.lock` antes de propor APIs ou crates. Use apenas recursos compatíveis com a edition e a MSRV do projeto.

**Siga o projeto.** Respeite o runtime assíncrono (`tokio`), framework HTTP (`axum`, `actix-web`), camada de dados (`sqlx`, `diesel`, `sea-orm`) e estrutura de módulos existentes. Nunca adicione crates novas sem pedir antes.

**Timebox e Circuit Breaker.** Ao corrigir erros do *borrow checker*, tipos, `clippy` ou testes, pare após **3 tentativas consecutivas** sobre a mesma falha. Informe o erro exato do compilador, as assinaturas tentadas e a causa provável, e peça direção ao usuário.

**Modos.** Escrever, Revisar e Atualizar versão.

**Idioma.** O do usuário; identificadores seguem as convenções do Rust (`rustfmt`).

---

## 1. Princípios

- **Ownership e borrowing antes de clonar**: aceite slices (`&str`, `&[T]`) e referências nas funções; devolva tipos próprios quando necessário e só use `.clone()` ou `Arc<T>` quando o modelo de posse exigir, não para contornar o *borrow checker*.
- **Tipos de domínio e exaustividade**: use *newtypes* (`struct UserId(Uuid);`) e `enum`s fechados com `match` exaustivo em vez de cadeias de strings soltas ou booleanos.
- **Erros explícitos sem `unwrap` em produção**: proibido usar `.unwrap()` ou `.expect()` em caminhos de requisição, I/O ou CLI (permitidos apenas em testes unitários). Use `thiserror` para erros tipados de domínio/bibliotecas e `anyhow` na borda de binários; propague contexto com `?`.
- **Assíncrono estruturado (`tokio`)**: nunca bloqueie threads do executor com I/O síncrono (`std::fs`) ou CPU intensiva — delegue para `tokio::task::spawn_blocking`. Nunca segure um lock síncrono (`std::sync::Mutex`) através de um `.await` (prefira `tokio::sync::Mutex` apenas quando preciso, ou mantenha o escopo do lock síncrono mínimo sem pontos de suspensão).
- **Serviços web e ciclo de vida**: estruture rotas (`axum`/`actix-web`) com estado imutável compartilhado, validação explícita na borda, limites de tamanho/timeout via `tower`, logs estruturados com `tracing` sem PII/segredos e *graceful shutdown* reagindo a `tokio::signal` (`sk-observability`).
- **Banco e consultas SQL (`sqlx`, `diesel`, `sea-orm`)**: queries sempre parametrizadas, sem `SELECT *`, sem concatenação dinâmica de SQL e sem N+1; configure limites e timeouts do pool. Analise filtros, junções e ordenações e **entregue obrigatoriamente o script/migration de criação dos índices adequados** com script de rollback (`up.sql`/`down.sql` ou equivalente) (`sk-sql`).
- **`unsafe` restrito e documentado**: evite `unsafe` fora de FFI estritamente necessário. Se existir, documente exatamente por que os invariantes de memória se mantêm com comentário `// SAFETY: ...`.
- **Qualidade contínua**: mantenha `cargo fmt --check`, `cargo clippy --all-targets -- -D warnings`, `cargo test` e `cargo audit` limpos (`sk-testing`, `sk-security`).

---

## 2. Exemplos

Consulte implementações de referência em [examples/patterns.md](./examples/patterns.md): erro de domínio com `thiserror` mapeado em handler `axum` para Problem Details (`RFC 9457`) + *graceful shutdown* no `tokio`, e repositório `sqlx` com projeção estrita acompanhado de migration `up.sql`/`down.sql` de índice composto.

---

## 3. Integrações

`sk-sql` (modelagem, índices obrigatórios e migrações), `sk-api-design` (contratos REST e Problem Details), `sk-security` (`cargo audit`, validação de fronteira e segredos), `sk-observability` (`tracing`, métricas e shutdown), `sk-testing` (unitários, integração e mocks/Testcontainers), `sk-devops` (builds multiestágio `cargo-chef`/musl e CI), `sk-upgrade` (edition upgrades, MSRV e bump de crates), `sk-code-review` e `sk-tasks`. Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 4. Armadilhas

- **`.unwrap()` ou `.expect()` em código de produção**: qualquer entrada inesperada derruba o processo com `panic!`.
- **Manter `std::sync::MutexGuard` vivo através de `.await`**: trava workers do `tokio` ou causa deadlock.
- **Executar leitura pesada síncrona ou compressão dentro de `async fn`**: bloqueia todas as tarefas do executor.
- **Usar `.clone()` indiscriminado para acalmar o *borrow checker***: esconde design de posse confuso e multiplica alocações em caminhos quentes.
- **Queries `sqlx`/Diesel sem índices adequados e sem rollback**: degradam com crescimento da tabela e travam migrações.
- **Concatenar SQL dinâmico com `format!`**: abre SQL injection mesmo em linguagem tipada.
- **`unsafe` sem prova escrita de invariantes**: introduz *undefined behavior* silencioso.
- **Loop de compilador/clippy (*fix loop*)**: insistir em correções sucessivas após 3 falhas sem acionar o circuit breaker.

---

## 5. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Código Rust seguro (zero `.unwrap()`/`.expect()` em produção, erros tipados e concorrência não bloqueante), com links relativos.
3. Se implementar nova query ou tabela (`sqlx`/Diesel/SeaORM): verificação de performance e **script/migration de criação dos índices adequados com rollback**.
4. Resultado de `cargo test`, `cargo clippy`, `cargo fmt --check` (e `cargo audit` quando aplicável), o motivo de não ter executado ou o relato do circuit breaker.
5. Somente se restarem pendências relevantes não resolvidas: pergunte se o usuário quer registrar no `TASKS.md` via `sk-tasks` (modo Importar, origem `tech-rust`, P1 a P3; fallback em lista no chat).
