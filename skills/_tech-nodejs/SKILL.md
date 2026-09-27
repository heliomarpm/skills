---
name: _tech-nodejs
description: Orienta o desenvolvimento de serviços e pacotes com Node.js e TypeScript. Use ao criar APIs de backend, lidar com fluxos assíncronos, manipular arquivos e estruturar projetos no servidor.
---

# Tech Skill: Node.js & TypeScript Specialist (Node 20+ LTS)

Diretrizes técnicas especializadas para a criação de serviços de backend, microsserviços e bibliotecas em Node.js e TypeScript moderno.


> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧭 **Skill Ativa**: `_tech-nodejs``

---

## 1. Processo de Execução de Engenharia Node.js

Ao desenvolver aplicações em Node.js e TypeScript:

1. **Configuração Estrita e ESM**: Configure o projeto com `"type": "module"` e `"strict": true` no TypeScript, importando módulos nativos via prefixo `node:`.
2. **Validação de Fronteiras com Zod**: Defina schemas de validação para todos os corpos de requisição, parâmetros de URL e variáveis de ambiente no startup (`env.ts`).
3. **Gerenciamento de Streams e Memória**: Manipule grandes arquivos e payloads contínuos via `node:stream/promises` com a função `pipeline`.
4. **Cancelamento de Operações com AbortSignal**: Propague instâncias de `AbortController` para requisições `fetch` e queries de banco para cancelar processamento ocioso.
5. **Encerramento Gracioso (Graceful Shutdown)**: Capture `SIGTERM` e `SIGINT` para drenar requisições em trânsito e fechar pools de conexões com o banco de dados.

---

## 2. Snippets Canônicos de Referência

### 2.1. Streaming com Pipeline e Cancelamento Nativo (Node 20+)
```typescript
import { createReadStream, createWriteStream } from 'node:fs';
import { pipeline } from 'node:stream/promises';
import { createGzip } from 'node:zlib';
import { z } from 'zod';

// Validação estrita de runtime
const FileProcessSchema = z.object({
  sourcePath: z.string().min(1),
  destinationPath: z.string().min(1),
});

export async function compressFile(
  input: z.infer<typeof FileProcessSchema>,
  signal?: AbortSignal
): Promise<void> {
  const { sourcePath, destinationPath } = FileProcessSchema.parse(input);

  // Streaming eficiente com consumo de memória O(1) e suporte a cancelamento
  await pipeline(
    createReadStream(sourcePath, { signal }),
    createGzip(),
    createWriteStream(destinationPath, { signal }),
    { signal }
  );
}
```

### 2.2. Servidor com Graceful Shutdown e Fastify
```typescript
import Fastify from 'fastify';

const server = Fastify({ logger: true });

server.get('/health', async () => ({ status: 'ok', timestamp: new Date().toISOString() }));

const closeGracefully = async (signal: string) => {
  server.log.info(`Recebido sinal ${signal}. Encerrando conexões com segurança...`);
  await server.close();
  // Fechar pools de banco / filas aqui
  process.exit(0);
};

process.on('SIGTERM', () => closeGracefully('SIGTERM'));
process.on('SIGINT', () => closeGracefully('SIGINT'));

await server.listen({ port: 3000, host: '0.0.0.0' });
```

---

## 3. Armadilhas Críticas em Node.js (*Gotchas*)

- ⚠️ **Bloqueio do Event Loop com Métodos Síncronos**: Usar `fs.readFileSync` ou `crypto.pbkdf2Sync` em produção bloqueia o processamento de todas as requisições concorrentes de outros usuários. Utilize as versões assíncronas baseadas em Promises (`node:fs/promises`).
- ⚠️ **Vazamento de Memória em `EventEmitter`**: Registrar ouvintes em instâncias de longa duração sem removê-los com `.off()` ou sem usar `{ once: true }` acumula referências no Heap e causa o aviso `MaxListenersExceededWarning`.
- ⚠️ **Rejeições de Promise Não Tratadas**: Não tratar rejeições em chamadas assíncronas assíncronas isoladas dispara o evento `unhandledRejection` e pode encerrar abruptamente o processo do Node.js.

---

## 4. Padrão de Entrega do Agente

Ao entregar código em Node.js / TypeScript:
1. Proibido o uso de `any`; utilize `unknown` acompanhado de type guards ou schemas Zod.
2. Prefira APIs nativas do Node.js (`node:fs/promises`, `node:crypto`) a dependências externas pesadas.
3. Forneça código com tratamento de encerramento seguro e suporte a TypeScript estrito.
