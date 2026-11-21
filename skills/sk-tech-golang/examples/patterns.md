# Padrões e Exemplos de Go (`sk-tech-golang`)

## 1. Servidor com roteamento nativo, JSON e encerramento gracioso

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

## 2. Concorrência estruturada com `errgroup`

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
