---
name: _tech-golang
description: "Orienta o desenvolvimento idiomático em Go 1.22+. Cobre concorrência com Goroutines e Channels, sync.ErrGroup, context.Context, structured logging com log/slog, roteamento nativo em net/http e testes com race detector."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(go test *), Bash(go build *), Bash(go vet *), Bash(golangci-lint *)
---

# Go 1.22+ Specialist Skill

Esta skill fornece diretrizes técnicas especializadas para engenharia de software idiomática, performática e segura no ecossistema **Go (Golang) 1.22+**. O foco é concorrência estruturada, propagação de contexto, logging estruturado (`log/slog`), roteamento HTTP nativo sem dependências infladas e prevenção de *goroutine leaks* e *data races*.

> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧭 **Skill Ativa**: `_tech-golang``

---

## 1. Processo de Execução em Go Moderno

Ao construir ou refatorar serviços em Go:

1. **Simplicidade e Idiomaticidade First**:
   - Mantenha funções pequenas e com responsabilidade única.
   - Favoreça interfaces minúsculas (1 ou 2 métodos, como `io.Reader`, `io.Closer`) definidas pelo consumidor, não pelo produtor.
   - Evite abstrações e hierarquias desnecessárias; prefira composição de structs.
2. **Propagação Rigorosa de `context.Context`**:
   - O primeiro parâmetro de qualquer função que faça I/O (rede, banco, disco) ou controle de concorrência deve ser `ctx context.Context`.
   - Respeite sempre cancelamentos e timeouts ouvindo `ctx.Done()`.
3. **Concorrência Estruturada e Sem Leaks**:
   - Nunca inicie uma goroutine com `go func()` sem saber exatamente como e quando ela irá terminar.
   - Utilize `golang.org/x/sync/errgroup` para orquestrar tarefas concorrentes com cancelamento imediato na primeira falha.
   - Feche canais no emissor (`sender`), nunca no receptor (`receiver`).
4. **Tratamento de Erros Explícito**:
   - Erros são valores (`err != nil`). Nunca silencie ou apenas imprima sem decidir o fluxo de retorno.
   - Use `%w` com `fmt.Errorf("falha ao processar pagamento: %w", err)` para empilhar contexto preservando a árvore de causas.
   - Avalie erros com `errors.Is(err, ErrNotFound)` ou `errors.As(err, &targetErr)`.
5. **Roteamento Nativo e Logging Estruturado**:
   - No Go 1.22+, utilize os recursos nativos do `http.NewServeMux()` (`GET /pedidos/{id}`) em vez de bibliotecas pesadas de roteamento a menos que haja necessidade comprovada.
   - Adote o pacote padrão `log/slog` para logs estruturados em JSON ou texto com campos contextualizados.

---

## 2. Snippets Canônicos de Referência

### 2.1. Servidor HTTP com Roteamento Nativo (Go 1.22+) & Graceful Shutdown
```go
package main

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelInfo,
	}))
	slog.SetDefault(logger)

	mux := http.NewServeMux()

	// Roteamento nativo Go 1.22+ com método e path parameter
	mux.HandleFunc("GET /api/v1/pedidos/{id}", func(w http.ResponseWriter, r *http.Request) {
		pedidoID := r.PathValue("id")
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprintf(w, `{"pedido_id":"%s","status":"processado"}`, pedidoID)
	})

	server := &http.Server{
		Addr:         ":8080",
		Handler:      mux,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// Canal para captura de sinais do SO
	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)

	go func() {
		slog.Info("servidor iniciado", "porta", 8080)
		if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
			slog.Error("falha crítica no servidor HTTP", "error", err)
			os.Exit(1)
		}
	}()

	<-stop
	slog.Info("sinal de encerramento recebido, finalizando conexões ativas...")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := server.Shutdown(ctx); err != nil {
		slog.Error("erro ao finalizar servidor graciosamente", "error", err)
		_ = server.Close()
	}

	slog.Info("servidor finalizado com sucesso")
}
```

### 2.2. Concorrência Estruturada com `sync/errgroup`
```go
package servico

import (
	"context"
	"fmt"
	"golang.org/x/sync/errgroup"
)

type DadosAgregados struct {
	Perfil   string
	Extrato  []string
	Score    int
}

type AggregatorService struct {
	clientAPI ClientAPI
}

func (s *AggregatorService) ObterDadosCliente(ctx context.Context, clienteID string) (*DadosAgregados, error) {
	g, ctx := errgroup.WithContext(ctx)

	var perfil string
	var extrato []string
	var score int

	// Tarefa 1: Perfil
	g.Go(func() error {
		p, err := s.clientAPI.BuscarPerfil(ctx, clienteID)
		if err != nil {
			return fmt.Errorf("buscar perfil: %w", err)
		}
		perfil = p
		return nil
	})

	// Tarefa 2: Extrato
	g.Go(func() error {
		e, err := s.clientAPI.BuscarExtrato(ctx, clienteID)
		if err != nil {
			return fmt.Errorf("buscar extrato: %w", err)
		}
		extrato = e
		return nil
	})

	// Tarefa 3: Score
	g.Go(func() error {
		sc, err := s.clientAPI.BuscarScore(ctx, clienteID)
		if err != nil {
			return fmt.Errorf("buscar score: %w", err)
		}
		score = sc
		return nil
	})

	// Aguarda todas as tarefas ou encerra no primeiro erro
	if err := g.Wait(); err != nil {
		return nil, fmt.Errorf("falha na agregação de dados do cliente %s: %w", clienteID, err)
	}

	return &DadosAgregados{
		Perfil:  perfil,
		Extrato: extrato,
		Score:   score,
	}, nil
}
```

---

## 3. Armadilhas Comuns e Como Evitá-las (Anti-patterns)

| Armadilha | Risco | Como Evitar |
| :--- | :--- | :--- |
| **Goroutine Leak** | Consumo infinito de memória e travamento do processo | Sempre garanta canal de cancelamento via `ctx.Done()` ou encerramento garantido de loops concorrentes. |
| **Data Races** | Comportamento não-determinístico e corrupção de memória | Execute sempre `go test -race ./...` no CI/CD e use tipos atômicos (`sync/atomic`) ou `sync.Mutex`. |
| **Cópia de Mutex** | Deadlocks silenciosos | Nunca passe structs que contêm `sync.Mutex` por valor. Use sempre ponteiros (`*MinhaStruct`). |
| **Vazamento de `http.Response`** | Esgotamento do pool de sockets TCP | Sempre feche o body e drene os bytes: `defer resp.Body.Close()`; execute `io.Copy(io.Discard, resp.Body)` antes de fechar se pretender reutilizar a conexão. |
| **Panic em Goroutine sem Recover** | Toda a aplicação encerra bruscamente | Em workers ou rotinas assíncronas isoladas, capture panics com `defer func() { if r := recover(); r != nil { ... } }()`. |

---

## 4. Padrão Rigoroso de Entrega

Todo código entregue sob esta skill deve satisfazer:
1. **Estrutura de Pacotes Limpa**:
   - `cmd/<servico>/main.go` para entrypoint.
   - `internal/` para lógica de negócio e repositórios não expostos externamente.
   - `pkg/` apenas para utilitários públicos reutilizáveis.
2. **Qualidade e Testes**:
   - Testes unitários utilizando tabelas orientadas a dados (*table-driven tests*).
   - Validação contínua com `go vet ./...` e execução de testes com `-race`.
3. **Assinatura Obrigatória**: Iniciar a resposta com `> 🧭 **Skill Ativa**: _tech-golang`.
