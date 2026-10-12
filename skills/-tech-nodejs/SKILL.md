---
name: -tech-nodejs
description: "Orienta serviços e pacotes em Node.js moderno: ESM, módulos nativos com prefixo node:, validação de ambiente e de entrada, streams com cancelamento, I/O assíncrono, tratamento de erros, encerramento gracioso e desempenho do event loop. Use sempre que o usuário pedir 'API em Node', 'worker', 'processar arquivo ou stream', 'variáveis de ambiente', 'bloqueou o event loop' ou 'estruture o projeto Node', mesmo sem dizer 'Node.js'. NÃO use para tipagem em geral (isso é -tech-typescript), contratos de API (isso é -api-design) nem para interfaces (isso é -tech-react, -tech-vue ou -tech-angular)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(node --test *), Bash(npx tsc *), Bash(npx vitest *), Bash(npx jest *), Bash(npx eslint *), Bash(npm test *), Bash(npm run test *), Bash(npm run lint *), Bash(npm run typecheck *), Bash(npm run build *), Bash(pnpm test *), Bash(pnpm run test *), Bash(pnpm run lint *), Bash(pnpm run typecheck *)
---

# Node.js: serviços robustos e eficientes

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativa**: `-tech-nodejs`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão.** Leia a versão de Node em `engines`, `.nvmrc` ou `.tool-versions`, use uma LTS suportada e apenas recursos que ela oferece. APIs recentes ou experimentais: confirme na documentação oficial da versão.

**Siga o projeto.** Respeite gerenciador de pacotes, framework (Fastify, Express, Nest), logger e estrutura existentes. Regras de tipagem estão em `-tech-typescript`.

**Modos.** Escrever, Revisar e Atualizar versão.

**Idioma.** O do usuário; nomes de código ficam como estão.

---

## 1. Princípios

- **ESM e `node:`**: `"type": "module"` (ou o padrão do projeto) e importações nativas com prefixo `node:`.
- **Configuração validada na inicialização**: variáveis de ambiente passam por um schema e a aplicação falha rápido se algo faltar.
- **Entrada validada na borda** (schema) e **caminhos de arquivo confinados** a um diretório base.
- **I/O assíncrono**: `node:fs/promises`; nada de `readFileSync` ou `pbkdf2Sync` em caminhos de requisição. Trabalho pesado de CPU vai para `worker_threads` ou um processo separado.
- **Streams**: `pipeline` de `node:stream/promises`, com `AbortSignal`; a memória fica limitada ao tamanho dos blocos, não ao arquivo.
- **Cancelamento e prazo**: `AbortSignal` e `AbortSignal.timeout()` em `fetch` e em consultas.
- **Erros**: tratados onde se pode decidir; `unhandledRejection` e `uncaughtException` registram e encerram o processo, não o mantêm "vivo".
- **Logs** estruturados em JSON (por exemplo, `pino`), sem segredos e sem PII.
- **HTTP**: timeouts de servidor definidos, limites de corpo e `/health` separado de readiness (`-observability`).
- **Testes**: `node --test` ou o runner do projeto; I/O externo isolado por fakes.

---

## 2. Exemplos

### 2.1. Configuração validada

```ts
import { z } from 'zod';

const Env = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().min(1).max(65535).default(3000),
  DATABASE_URL: z.string().url(),
});

export const env = Env.parse(process.env); // falha na inicialização se a configuração estiver errada
```

### 2.2. Stream com cancelamento e caminho confinado

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

### 2.3. Servidor com encerramento

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
// Readiness, drenagem pelo balanceador e timeout total: veja -observability.
```

---

## 3. Segurança, testes e desempenho

Segredos, validação de entrada e dependências no `-security`; testes no `-testing`; consultas no `-sql`; métricas e shutdown no `-observability`; contêiner e CI no `-devops`. Para investigar o event loop, meça o atraso (`monitorEventLoopDelay`) e use perfis antes de otimizar.

---

## 4. Armadilhas

- **Bloquear o event loop** com métodos síncronos ou CPU pesada.
- **Vazamento em `EventEmitter`**: ouvintes sem remoção (`off`, `{ once: true }`) acumulam referências.
- **Promise rejeitada sem tratamento**: derruba o processo ou esconde o erro.
- **Caminho de arquivo vindo do usuário sem confinamento**: *path traversal*.
- **Configuração lida em qualquer lugar de `process.env`**: erros só aparecem em runtime.
- **`process.exit` sem encerrar conexões**: perde requisições em curso.
- **`fetch` sem timeout ou cancelamento.**

---

## 5. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Código com tipos estritos, validação de entrada e encerramento seguro, com links relativos.
3. Resultado de testes, tipos e lint, ou o motivo de não ter executado.
4. Pendências: se houver, pergunte se o usuário quer registrar no `TASKS.md` via `-tasks` (modo Importar, origem `tech-nodejs`, P1 a P3; fallback em lista no chat).