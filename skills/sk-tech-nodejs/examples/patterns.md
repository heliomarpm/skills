# Padrões e Exemplos de Node.js (`sk-tech-nodejs`)

## 1. Configuração validada na inicialização

```ts
import { z } from 'zod';

const Env = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().min(1).max(65535).default(3000),
  DATABASE_URL: z.string().url(),
});

export const env = Env.parse(process.env); // falha na inicialização se a configuração estiver errada
```

## 2. Stream com cancelamento e caminho confinado

```ts
import { createReadStream, createWriteStream } from 'node:fs';
import { pipeline } from 'node:stream/promises';
import { createGzip } from 'node:zlib';
import path from 'node:path';

const BASE_DIR = path.resolve(process.env.DATA_DIR ?? './data');

function resolverDentroDaBase(relativo: string): string {
  const alvo = path.resolve(BASE_DIR, relativo);
  if (alvo !== BASE_DIR && !alvo.startsWith(BASE_DIR + path.sep)) {
    throw new Error('Caminho fora do diretório permitido');
  }
  return alvo; // links simbólicos: valide com fs.realpath quando o diretório não for confiável
}

export async function comprimirArquivo(origem: string, destino: string, signal?: AbortSignal): Promise<void> {
  await pipeline(
    createReadStream(resolverDentroDaBase(origem)),
    createGzip(),
    createWriteStream(resolverDentroDaBase(destino)),
    { signal },
  );
}
```

## 3. Servidor com encerramento gracioso

```ts
import Fastify from 'fastify';
import { env } from './env.js';

const app = Fastify({ logger: true });
app.get('/health/live', async () => ({ status: 'ok' }));

for (const sinal of ['SIGTERM', 'SIGINT'] as const) {
  process.once(sinal, async () => {
    app.log.info({ sinal }, 'encerrando');
    try {
      await app.close(); // para de aceitar conexões e aguarda as em curso
      process.exit(0);
    } catch (erro) {
      app.log.error(erro);
      process.exit(1);
    }
  });
}

await app.listen({ port: env.PORT, host: '0.0.0.0' });
// Readiness, drenagem pelo balanceador e timeout total: veja sk-observability.
```
