---
name: sk-tech-golang
description: "Orienta Go idiomático: interfaces mínimas, context.Context em I/O, errgroup, erros com %w, net/http nativo, slog, graceful shutdown, queries SQL performáticas com índices e testes com -race. Use para serviços ou concorrência em Go. NÃO use para SQL avançado (sk-sql), OpenAPI (sk-api-design) nem pipelines (sk-devops)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(go test *), Bash(go build *), Bash(go vet *), Bash(gofmt -l *), Bash(golangci-lint *)
---

# Go: simples, concorrente e sem vazamentos

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-tech-golang`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão.** Leia as diretivas `go` e `toolchain` do `go.mod` e use só o que a versão suporta (por exemplo, roteamento com método e parâmetros no `ServeMux` e a variável de laço por iteração são do 1.22). Recursos novos: confirme na documentação oficial.

**Siga o projeto.** Respeite a estrutura de pacotes, o roteador e o logger existentes; `gofmt` e `golangci-lint` são obrigatórios.

**Timebox e Circuit Breaker.** Ao corrigir erros de compilação, tipos, build, lint ou testes, pare após **3 tentativas consecutivas** sobre a mesma falha. Informe o erro exato, o que foi tentado e a causa provável, e peça direção ao usuário.

**Modos.** Escrever, Revisar e Atualizar versão.

**Idioma.** O do usuário; identificadores seguem as convenções de Go.

---

## 1. Princípios

- **Simplicidade**: funções pequenas, composição de structs, interfaces mínimas (1 ou 2 métodos) **definidas por quem as consome**. Nomes curtos e pacotes coesos.
- **`context.Context`** como primeiro parâmetro de todo I/O ou controle de concorrência; respeite `ctx.Done()` e prazos.
- **Concorrência estruturada**: nunca inicie uma goroutine sem saber como ela termina. `errgroup` (com `SetLimit` para limitar paralelismo) cancela as irmãs na primeira falha. Feche canais no emissor.
- **Erros** são valores: `fmt.Errorf("...: %w", err)`, `errors.Is` e `errors.As`; nada de `panic` em código de biblioteca.
- **HTTP**: `net/http` com `ServeMux`; timeouts do servidor (`ReadHeaderTimeout`, `ReadTimeout`, `WriteTimeout`, `IdleTimeout`); JSON com `encoding/json`, **nunca** montado com `Sprintf`; sempre feche e esvazie o corpo da resposta de clientes.
- **Logs** com `log/slog`, sem segredos e sem PII; correlação com traces (`sk-observability`).
- **Encerramento gracioso** com `signal.NotifyContext` e `Server.Shutdown`.
- **Testes**: tabelas com `t.Run` e `t.Parallel`; `go test -race ./...` no CI; fakes para I/O; benchmarks e `pprof` antes de otimizar (`sk-testing`).
- **Banco e consultas SQL**: toda nova query (via `database/sql`, `pgx`, `gorm` etc.) deve ser performática por concepção, parametrizada e sem varreduras sequenciais em tabelas grandes. Analise filtros (`WHERE`), junções e ordenação e **entregue obrigatoriamente o script de migração/DDL para criação dos índices adequados** à query proposta (com `CREATE INDEX [CONCURRENTLY]` e script de rollback; use `sk-sql` para planos de execução).
- **Estrutura**: `cmd/<servico>/main.go` e `internal/` para a lógica privada. `pkg/` é opcional e não é padrão oficial.
- **Genéricos** só quando há reuso real.

---

## 2. Exemplos

Consulte implementações de referência em [examples/patterns.md](./examples/patterns.md): servidor HTTP com `ServeMux` nativo (Go 1.22+), `slog` em JSON e graceful shutdown com timeouts; e concorrência estruturada com `errgroup`.

---

## 3. Integrações

`sk-testing` (tabelas, race), `sk-sql` (acesso a banco), `sk-api-design`, `sk-security`, `sk-observability` (slog, métricas, pprof), `sk-devops`, `sk-code-review`. Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 4. Armadilhas

- **Nova query SQL sem índice adequado**: gera lentidão e Seq Scan em produção; analise filtros/ordenação e entregue a migration de índices com rollback.
- **Vazamento de goroutine**: consome memória e trava o processo; garanta término por `ctx.Done()` ou fechamento do canal.
- ***Data race***: causa corrupção e comportamento imprevisível; rode `go test -race` e proteja estado compartilhado com `sync.Mutex` ou `sync/atomic`.
- **Cópia de `sync.Mutex`**: quebra a exclusão mútua; use ponteiros para structs que o contêm.
- **Corpo de resposta HTTP não fechado**: esgota conexões; faça `defer resp.Body.Close()` e, para reutilizar, `io.Copy(io.Discard, resp.Body)`.
- **`panic` em goroutine sem `recover`**: derruba o processo inteiro; use `recover` nos workers e trate erros como valores.
- **JSON montado por `Sprintf`**: abre injeção e escape errado; use `encoding/json`.
- **`time.After` em laços** (versões antigas): acumula temporizadores; prefira `time.NewTimer` com `Stop`.
- **Variável de laço capturada** (antes do Go 1.22): goroutines enxergam o mesmo valor; copie a variável ou use Go 1.22+.
- **Ignorar erros**: mascara falhas silenciosamente; trate ou propague com contexto (`%w`).
- **Loop de build/lint (*fix loop*)**: insistir em correções sucessivas após 3 falhas sem acionar o circuit breaker.

---

## 5. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Código formatado, com `context` propagado, erros tratados e testes em tabela, com links relativos.
3. Se implementar nova query SQL: verificação de performance e script/migration de criação dos índices adequados (com rollback).
4. Resultado de `go vet`, `go test -race` e lint, o motivo de não ter executado ou o relato do circuit breaker.
5. Somente se restarem pendências relevantes não resolvidas: pergunte se o usuário quer registrar no `TASKS.md` via `sk-tasks` (modo Importar, origem `tech-golang`, P1 a P3; fallback em lista no chat).
