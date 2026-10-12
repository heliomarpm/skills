---
name: -tech-golang
description: "Orienta Go idiomático: interfaces pequenas definidas por quem consome, context.Context em todo I/O, concorrência estruturada com errgroup, tratamento de erros com %w, servidores net/http com roteamento nativo, JSON e logs estruturados (slog), encerramento gracioso e testes com race detector. Use sempre que o usuário pedir 'serviço em Go', 'goroutine', 'canal', 'errgroup', 'handler HTTP', 'vazamento de goroutine', 'data race' ou 'migre de versão do Go', mesmo sem dizer 'Go'. NÃO use para modelagem e SQL em si (isso é -sql), contratos de API (isso é -api-design) nem para pipelines (isso é -devops)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(go test *), Bash(go build *), Bash(go vet *), Bash(gofmt -l *), Bash(golangci-lint *)
---

# Go: simples, concorrente e sem vazamentos

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativa**: `-tech-golang`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão.** Leia as diretivas `go` e `toolchain` do `go.mod` e use só o que a versão suporta (por exemplo, roteamento com método e parâmetros no `ServeMux` e a variável de laço por iteração são do 1.22). Recursos novos: confirme na documentação oficial.

**Siga o projeto.** Respeite a estrutura de pacotes, o roteador e o logger existentes; `gofmt` e `golangci-lint` são obrigatórios.

**Modos.** Escrever, Revisar e Atualizar versão.

**Idioma.** O do usuário; identificadores seguem as convenções de Go.

---

## 1. Princípios

- **Simplicidade**: funções pequenas, composição de structs, interfaces mínimas (1 ou 2 métodos) **definidas por quem as consome**. Nomes curtos e pacotes coesos.
- **`context.Context`** como primeiro parâmetro de todo I/O ou controle de concorrência; respeite `ctx.Done()` e prazos.
- **Concorrência estruturada**: nunca inicie uma goroutine sem saber como ela termina. `errgroup` (com `SetLimit` para limitar paralelismo) cancela as irmãs na primeira falha. Feche canais no emissor.
- **Erros** são valores: `fmt.Errorf("...: %w", err)`, `errors.Is` e `errors.As`; nada de `panic` em código de biblioteca.
- **HTTP**: `net/http` com `ServeMux`; timeouts do servidor (`ReadHeaderTimeout`, `ReadTimeout`, `WriteTimeout`, `IdleTimeout`); JSON com `encoding/json`, **nunca** montado com `Sprintf`; sempre feche e esvazie o corpo da resposta de clientes.
- **Logs** com `log/slog`, sem segredos e sem PII; correlação com traces (`-observability`).
- **Encerramento gracioso** com `signal.NotifyContext` e `Server.Shutdown`.
- **Testes**: tabelas com `t.Run` e `t.Parallel`; `go test -race ./...` no CI; fakes para I/O; benchmarks e `pprof` antes de otimizar (`-testing`).
- **Estrutura**: `cmd/<servico>/main.go` e `internal/` para a lógica privada. `pkg/` é opcional e não é padrão oficial.
- **Genéricos** só quando há reuso real.

---

## 2. Exemplos

### 2.1. Servidor com roteamento nativo, JSON e encerramento

```go
package main

import (
	"context"
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

type pedidoResposta struct {
	ID     string `json:"pedido_id"`
	Status string `json:"status"`
}

func main() {
	slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stdout, nil)))

	mux := http.NewServeMux()
	mux.HandleFunc("GET /api/v1/pedidos/{id}", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		resp := pedidoResposta{ID: r.PathValue("id"), Status: "processado"}
		if err := json.NewEncoder(w).Encode(resp); err != nil {
			slog.Error("falha ao escrever a resposta", "error", err)
		}
	})

	srv := &http.Server{
		Addr:              ":8080",
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       10 * time.Second,
		WriteTimeout:      15 * time.Second,
		IdleTimeout:       60 * time.Second,
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	go func() {
		if err := srv.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			slog.Error("falha no servidor HTTP", "error", err)
			stop() // dispara o encerramento
		}
	}()

	<-ctx.Done()
	slog.Info("encerrando")

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := srv.Shutdown(shutdownCtx); err != nil {
		slog.Error("falha no encerramento gracioso", "error", err)
		_ = srv.Close()
	}
}
```

### 2.2. Concorrência estruturada com `errgroup`

```go
package servico

import (
	"context"
	"fmt"

	"golang.org/x/sync/errgroup"
)

type ClienteAPI interface {
	BuscarPerfil(ctx context.Context, id string) (string, error)
	BuscarExtrato(ctx context.Context, id string) ([]string, error)
}

type Agregado struct {
	Perfil  string
	Extrato []string
}

type Servico struct{ api ClienteAPI }

func (s *Servico) ObterDados(ctx context.Context, id string) (*Agregado, error) {
	g, ctx := errgroup.WithContext(ctx)
	var ag Agregado // cada goroutine escreve um campo diferente; g.Wait() sincroniza a leitura

	g.Go(func() error {
		p, err := s.api.BuscarPerfil(ctx, id)
		if err != nil {
			return fmt.Errorf("buscar perfil: %w", err)
		}
		ag.Perfil = p
		return nil
	})

	g.Go(func() error {
		e, err := s.api.BuscarExtrato(ctx, id)
		if err != nil {
			return fmt.Errorf("buscar extrato: %w", err)
		}
		ag.Extrato = e
		return nil
	})

	if err := g.Wait(); err != nil {
		return nil, fmt.Errorf("agregar dados do cliente %s: %w", id, err)
	}
	return &ag, nil
}
```

---

## 3. Integrações

`-testing` (tabelas, race), `-sql` (acesso a banco), `-api-design`, `-security`, `-observability` (slog, métricas, pprof), `-devops`, `-code-review`. Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 4. Armadilhas

| Armadilha | Risco | Como evitar |
| :--- | :--- | :--- |
| Vazamento de goroutine | Memória e travamentos | Garanta o término por `ctx.Done()` ou por fechamento do canal |
| *Data race* | Corrupção e comportamento imprevisível | `go test -race`, `sync.Mutex` ou `sync/atomic` |
| Cópia de `sync.Mutex` | Exclusão mútua quebrada | Use ponteiros para structs que o contêm |
| Corpo de resposta HTTP não fechado | Esgota conexões | `defer resp.Body.Close()` e, para reutilizar, `io.Copy(io.Discard, resp.Body)` |
| `panic` em goroutine sem `recover` | Derruba o processo | `recover` nos workers; trate erros como valores |
| JSON por `Sprintf` | Injeção e escape errado | `encoding/json` |
| `time.After` em laços (versões antigas) | Temporizadores acumulados | `time.NewTimer` com `Stop` |
| Variável de laço capturada (antes do 1.22) | Goroutines com o mesmo valor | Copie a variável ou use o 1.22+ |
| Ignorar erros | Falhas silenciosas | Trate ou propague com contexto |

---

## 5. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Código formatado, com `context` propagado, erros tratados e testes em tabela, com links relativos.
3. Resultado de `go vet`, `go test -race` e lint, ou o motivo de não ter executado.
4. Pendências: se houver, pergunte se o usuário quer registrar no `TASKS.md` via `-tasks` (modo Importar, origem `tech-golang`, P1 a P3; fallback em lista no chat).