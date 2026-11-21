# Exemplos de Telemetria e Graceful Shutdown (`sk-observability`)

## 1. Log estruturado em JSON com correlação de trace

```json
{
  "timestamp": "2026-09-27T17:35:00.123Z",
  "severity": "ERROR",
  "service.name": "order-service",
  "trace_id": "4bf92f3577b34da6a3ce929d0e0e4736",
  "span_id": "00f067aa0ba902b7",
  "http.request.method": "POST",
  "http.route": "/v1/pedidos",
  "http.response.status_code": 500,
  "error.type": "DatabaseConnectionTimeout",
  "message": "Falha ao persistir o pedido por timeout na conexão com o banco."
}
```

## 2. Graceful Shutdown com drenagem (Node.js — complementa `sk-tech-nodejs`)

```typescript
import type { Server } from 'node:http';

interface Logger {
  info(msg: string, extra?: object): void;
  error(msg: string, extra?: object): void;
}

export function setupGracefulShutdown(
  server: Server,
  opts: {
    logger: Logger;
    setReady: (ready: boolean) => void;
    cleanup: () => Promise<void>;
    drainMs?: number;
    timeoutMs?: number;
  },
): void {
  const { logger, setReady, cleanup, drainMs = 5000, timeoutMs = 25000 } = opts;
  let shuttingDown = false;

  const shutdown = async (signal: string): Promise<void> => {
    if (shuttingDown) return;
    shuttingDown = true;
    logger.info('shutdown iniciado', { signal });

    // Limite total, menor que o período de graça da plataforma
    setTimeout(() => {
      logger.error('shutdown forçado por timeout');
      process.exit(1);
    }, timeoutMs).unref();

    setReady(false); // a readiness falha: o balanceador para de enviar tráfego
    await new Promise((resolve) => setTimeout(resolve, drainMs));

    server.close(async () => {
      try {
        await cleanup();
        process.exit(0);
      } catch (err) {
        logger.error('erro ao liberar recursos', { error: String(err) });
        process.exit(1);
      }
    });
    server.closeIdleConnections(); // fecha keep-alive ociosas (Node 18.2+)
  };

  process.on('SIGTERM', () => void shutdown('SIGTERM'));
  process.on('SIGINT', () => void shutdown('SIGINT'));
}
```
