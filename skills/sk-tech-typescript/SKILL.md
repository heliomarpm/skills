---
name: sk-tech-typescript
description: "Orienta TypeScript rigoroso em qualquer stack: tsconfig strict, zero any, uniões discriminadas com never, validação de fronteira com schemas, branded types, erros tipados e lint. Use para tipagem, generics ou migrar para strict. NÃO use para detalhes de UI (sk-tech-react/vue/angular) nem runtime Node (sk-tech-nodejs)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(npx tsc *), Bash(npx vitest *), Bash(npx jest *), Bash(npx eslint *), Bash(npm test *), Bash(npm run test *), Bash(npm run lint *), Bash(npm run typecheck *), Bash(npm run build *), Bash(pnpm test *), Bash(pnpm run test *), Bash(pnpm run lint *), Bash(pnpm run typecheck *), Bash(pnpm run build *)
---

# TypeScript: tipos que protegem de verdade

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-tech-typescript`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão.** Leia a versão do `typescript` no `package.json` e do runtime alvo, e use só o que ela suporta. Recursos recentes ou experimentais: confirme na documentação oficial da versão do projeto.

**Siga o projeto.** Respeite o `tsconfig`, o linter e as convenções existentes; endurecer o `strict` em um projeto legado é uma migração gradual, não um único commit.

**Timebox e Circuit Breaker.** Ao corrigir erros de compilação, tipos, build, lint ou testes, pare após **3 tentativas consecutivas** sobre a mesma falha. Informe o erro exato, o que foi tentado e a causa provável, e peça direção ao usuário.

**Modos.** Escrever, Revisar e Migrar (ativar flags de rigor por etapas).

**Idioma.** O do usuário; nomes de código ficam como estão.

---

## 1. Configuração

- `strict: true` sempre. Avalie, uma por vez, `noUncheckedIndexedAccess`, `noImplicitOverride` e `exactOptionalPropertyTypes` (esta pode ser disruptiva em bases existentes).
- `verbatimModuleSyntax` e `import type` para tipos; `isolatedModules` com bundlers e transpiladores.
- `module` e `moduleResolution` coerentes com o runtime (`NodeNext` em Node ESM, `Bundler` com bundlers).
- Linter: `typescript-eslint` com regras que usam informação de tipos, incluindo `no-floating-promises` e `no-explicit-any`.
- Em bases grandes: `incremental` e project references.

---

## 2. Princípios

- **Sem `any`**: use `unknown` e estreite com guardas ou schemas. Exceção rara, com comentário que explique o motivo. Evite asserções (`as`) e o operador `!`.
- **Valide a fronteira em runtime**: o TypeScript não valida dados externos. Entradas de rede, arquivos e variáveis de ambiente passam por um schema (Zod ou equivalente), e o tipo é inferido dele.
- **Uniões discriminadas** para estados e resultados, com verificação de exaustividade usando `never`.
- **Tipos marcados (branded)** para identificadores que não podem ser trocados entre si.
- **`satisfies`** para checar um valor sem alargar o tipo; `as const` para literais.
- **Prefira união de literais ou objeto `as const` a `enum`** (os `enum` numéricos e `const enum` dão problemas com `isolatedModules`).
- **Tipos derivados** (`Pick`, `Omit`, `Partial`, `ReturnType`, tipos mapeados) em vez de repetir definições.
- **Genéricos com restrição** (`extends`) e só quando há reuso real; tipos condicionais complexos custam compilação e legibilidade.
- **Erros**: `catch (e: unknown)`; erros de domínio como valores tipados quando o chamador precisa decidir.
- **`null` e `undefined`**: `??` e `?.` em vez de `||` e verificações frouxas.
- **Consultas e persistência**: ao escrever consultas SQL ou usar query builders/ORMs tipados (Drizzle, Prisma, Kysely), garanta que toda nova query seja performática (evitando *table scan*, N+1 e `SELECT *`). Analise filtros e ordenações e **entregue obrigatoriamente o script/migration para criação dos índices adequados** que sustentem a query proposta, com script de rollback.

---

## 3. Exemplos

Consulte implementações de referência em [examples/patterns.md](./examples/patterns.md): união discriminada com verificação de exaustividade (`never`) e validação de fronteira com Zod + tipos marcados (*branded types*).

---

## 4. Integrações

Testes de tipos e de comportamento no `sk-testing`; validação de entrada e segredos no `sk-security`; contratos no `sk-api-design`; consultas e índices no `sk-sql`; stacks em `sk-tech-nodejs`, `sk-tech-react`, `sk-tech-vue` e `sk-tech-angular`; revisão no `sk-code-review`. Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 5. Armadilhas

- **Nova query SQL/ORM sem verificar performance e sem entregar script de criação de índices adequados.**
- **`any` espalhado**: desliga a verificação e contamina quem o consome.
- **Asserção `as` ou `!`** para calar o compilador: o erro reaparece em runtime.
- **Confiar nos tipos para dados externos**: sem schema, o tipo é uma promessa vazia.
- **`enum` numérico e `const enum`**: comportamento surpreendente e incompatibilidade com `isolatedModules`.
- **Promise sem `await` ou tratamento** (*floating promise*).
- **Tipos condicionais ou genéricos enormes**: compilação lenta e mensagens de erro ilegíveis.
- **`strict` desligado "por enquanto"**: nunca é religado.
- **Loop de build/lint (*fix loop*)**: insistir em correções sucessivas após 3 falhas sem acionar o circuit breaker.

---

## 6. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Código tipado, sem `any` nem asserções injustificadas, e as alterações de `tsconfig` explicadas.
3. Se implementar nova query SQL/ORM: verificação de performance e o script/migration de criação de índices adequados (com rollback).
4. Resultado de `tsc`, lint e testes, o motivo de não ter executado ou o relato do circuit breaker.
5. Somente se restarem pendências relevantes não resolvidas: pergunte se o usuário quer registrar no `TASKS.md` via `sk-tasks` (modo Importar, origem `tech-typescript`, P1 a P3; fallback em lista no chat).
