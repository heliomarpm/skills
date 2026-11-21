# Padrões e Exemplos de TypeScript (`sk-tech-typescript`)

## 1. União discriminada com verificação de exaustividade

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

## 2. Fronteira validada e tipo marcado (branded)

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
