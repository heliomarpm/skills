---
name: sk-tech-nodejs
description: "Orienta serviços Node.js modernos (TypeScript ou JavaScript puro e rotas Next/Nuxt): ESM, node:, validação de env/entrada, streams, AbortSignal, event loop, SQL performático com índices e graceful shutdown. Use para backend Node.js ou workers. NÃO use para tipagem TS (sk-tech-typescript), OpenAPI (sk-api-design) nem UI (sk-tech-react)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(node --test *), Bash(npx tsc *), Bash(npx vitest *), Bash(npx jest *), Bash(npx eslint *), Bash(npm test *), Bash(npm run test *), Bash(npm run lint *), Bash(npm run typecheck *), Bash(npm run build *), Bash(pnpm test *), Bash(pnpm run test *), Bash(pnpm run lint *), Bash(pnpm run typecheck *), Bash(pnpm run build *)
---

# Node.js: serviços robustos e eficientes

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-tech-nodejs`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão.** Leia a versão de Node em `engines`, `.nvmrc` ou `.tool-versions`, use uma LTS suportada e apenas recursos que ela oferece. APIs recentes ou experimentais: confirme na documentação oficial da versão.

**Siga o projeto.** Respeite gerenciador de pacotes, framework (Fastify, Express, Nest, rotas/actions de servidor Next/Nuxt), logger e estrutura existentes. Em projetos TypeScript, siga `sk-tech-typescript`; em projetos **JavaScript puro**, mantenha ESM, JSDoc tipado quando útil e validação rigorosa de schema na borda.

**Timebox e Circuit Breaker.** Ao corrigir erros de compilação, tipos, build, lint ou testes, pare após **3 tentativas consecutivas** sobre a mesma falha. Informe o erro exato, o que foi tentado e a causa provável, e peça direção ao usuário.

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
- **HTTP**: timeouts de servidor definidos, limites de corpo e `/health` separado de readiness (`sk-observability`).
- **Banco e consultas SQL**: toda nova query (via Prisma, Drizzle, Kysely, TypeORM ou driver nativo) deve ser performática (sem N+1 e com projeção estrita de campos). Analise filtros, junções e ordenações e **entregue obrigatoriamente o script/migration para criação dos índices adequados** que suportem a consulta proposta, com script de rollback (recorra a `sk-sql` para planos de execução).
- **Testes**: `node --test` ou o runner do projeto; I/O externo isolado por fakes.

---

## 2. Exemplos

Consulte implementações de referência em [examples/patterns.md](./examples/patterns.md): configuração de ambiente validada com Zod, stream com `pipeline` + `AbortSignal` e caminho confinado (anti-*path traversal*), e servidor Fastify com encerramento gracioso.

---

## 3. Integrações

Segredos, validação de entrada e dependências no `sk-security`; tipagem estrita no `sk-tech-typescript`; testes no `sk-testing`; consultas no `sk-sql`; contratos no `sk-api-design`; métricas e shutdown no `sk-observability`; contêiner e CI no `sk-devops`; revisão no `sk-code-review`. Para investigar o event loop, meça o atraso (`monitorEventLoopDelay`) e use perfis antes de otimizar.

---

## 4. Armadilhas

- **Nova query SQL ou ORM sem verificar performance e sem entregar script/migration de índices adequados.**
- **Bloquear o event loop** com métodos síncronos ou CPU pesada.
- **Vazamento em `EventEmitter`**: ouvintes sem remoção (`off`, `{ once: true }`) acumulam referências.
- **Promise rejeitada sem tratamento**: derruba o processo ou esconde o erro.
- **Caminho de arquivo vindo do usuário sem confinamento**: *path traversal*.
- **Configuração lida em qualquer lugar de `process.env`**: erros só aparecem em runtime.
- **`process.exit` sem encerrar conexões**: perde requisições em curso.
- **`fetch` sem timeout ou cancelamento.**
- **Loop de build/lint (*fix loop*)**: insistir em correções sucessivas após 3 falhas sem acionar o circuit breaker.

---

## 5. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Código com tipos estritos, validação de entrada e encerramento seguro, com links relativos.
3. Se implementar nova query SQL/ORM: verificação de performance e script/migration de criação dos índices adequados (com rollback).
4. Resultado de testes, tipos e lint, o motivo de não ter executado ou o relato do circuit breaker.
5. Somente se restarem pendências relevantes não resolvidas: pergunte se o usuário quer registrar no `TASKS.md` via `sk-tasks` (modo Importar, origem `tech-nodejs`, P1 a P3; fallback em lista no chat).
