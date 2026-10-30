---
name: sk-tech-typescript
description: "Orienta TypeScript rigoroso em qualquer stack: tsconfig estrito, tipos sem any, uniões discriminadas com verificação de exaustividade, validação de fronteira com schemas, tipos derivados e marcados (branded), erros tipados e lint. Use sempre que o usuário pedir 'tipe isto', 'remova os any', 'tsconfig', 'erro de tipo', 'generics', 'migre para TypeScript' ou 'ative o strict', mesmo sem dizer 'TypeScript'. NÃO use para detalhes de framework (isso é sk-tech-react, sk-tech-vue ou sk-tech-angular) nem de runtime de servidor (isso é sk-tech-nodejs)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(npx tsc *), Bash(npx vitest *), Bash(npx jest *), Bash(npx eslint *), Bash(npm test *), Bash(npm run test *), Bash(npm run lint *), Bash(npm run typecheck *), Bash(pnpm test *), Bash(pnpm run test *), Bash(pnpm run lint *), Bash(pnpm run typecheck *)
---

# TypeScript: tipos que protegem de verdade

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-tech-typescript`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão.** Leia a versão do `typescript` no `package.json` e do runtime alvo, e use só o que ela suporta. Recursos recentes ou experimentais: confirme na documentação oficial da versão do projeto.

**Siga o projeto.** Respeite o `tsconfig`, o linter e as convenções existentes; endurecer o `strict` em um projeto legado é uma migração gradual, não um único commit.

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

---

## 3. Exemplos

### 3.1. União discriminada com exaustividade

```ts
type ErroDominio =
  | { tipo: 'nao_encontrado'; id: string }
  | { tipo: 'invalido'; campos: string[] };

type Resultado<T> = { ok: true; valor: T } | { ok: false; erro: ErroDominio };

function mensagem(erro: ErroDominio): string {
  switch (erro.tipo) {
    case 'nao_encontrado':
      return `Item ${erro.id} não encontrado`;
    case 'invalido':
      return `Campos inválidos: ${erro.campos.join(', ')}`;
    default: {
      const _exaustivo: never = erro; // erro de compilação se surgir um caso novo
      return _exaustivo;
    }
  }
}
```

### 3.2. Fronteira validada e tipo marcado

```ts
import { z } from 'zod';

const PedidoSchema = z.object({
  id: z.string().uuid(),
  totalCentavos: z.number().int().nonnegative(),
});
export type Pedido = z.infer<typeof PedidoSchema>;

export function lerPedido(entrada: unknown): Resultado<Pedido> {
  const r = PedidoSchema.safeParse(entrada);
  return r.success
    ? { ok: true, valor: r.data }
    : { ok: false, erro: { tipo: 'invalido', campos: r.error.issues.map((i) => i.path.join('.')) } };
}

// Identificadores que o compilador não deixa misturar
export type UsuarioId = string & { readonly __marca: 'UsuarioId' };
export type PedidoId = string & { readonly __marca: 'PedidoId' };
```

---

## 4. Integrações

Testes de tipos e de comportamento no `sk-testing`; validação de entrada e segredos no `sk-security`; contratos no `sk-api-design`; stacks em `sk-tech-nodejs`, `sk-tech-react`, `sk-tech-vue` e `sk-tech-angular`. Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 5. Armadilhas

- **`any` espalhado**: desliga a verificação e contamina quem o consome.
- **Asserção `as` ou `!`** para calar o compilador: o erro reaparece em runtime.
- **Confiar nos tipos para dados externos**: sem schema, o tipo é uma promessa vazia.
- **`enum` numérico e `const enum`**: comportamento surpreendente e incompatibilidade com `isolatedModules`.
- **Promise sem `await` ou tratamento** (*floating promise*).
- **Tipos condicionais ou genéricos enormes**: compilação lenta e mensagens de erro ilegíveis.
- **`strict` desligado "por enquanto"**: nunca é religado.

---

## 6. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Código tipado, sem `any` nem asserções injustificadas, e as alterações de `tsconfig` explicadas.
3. Resultado de `tsc`, lint e testes, ou o motivo de não ter executado.
4. Pendências: se houver, pergunte se o usuário quer registrar no `TASKS.md` via `sk-tasks` (modo Importar, origem `tech-typescript`, P1 a P3; fallback em lista no chat).