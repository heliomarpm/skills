# Padrões e Exemplos de React (`sk-tech-react`)

## 1. Formulário com Action e atualização otimista (React 19)

```tsx
import { useActionState, useOptimistic } from 'react';

interface Tarefa {
  id: string;
  titulo: string;
  pendente?: boolean;
}
interface EstadoAcao {
  erro: string | null;
}

export function ListaTarefas({
  tarefas,
  salvar,
}: {
  tarefas: Tarefa[];
  salvar: (titulo: string) => Promise<void>; // lança erro se falhar; o pai atualiza `tarefas` ao concluir
}) {
  const [otimistas, adicionarOtimista] = useOptimistic(tarefas, (atual, nova: Tarefa) => [
    ...atual,
    { ...nova, pendente: true },
  ]);

  const [estado, acao, enviando] = useActionState(
    async (_anterior: EstadoAcao, dados: FormData): Promise<EstadoAcao> => {
      const titulo = String(dados.get('titulo') ?? '').trim();
      if (!titulo) return { erro: 'Informe um título.' };

      adicionarOtimista({ id: crypto.randomUUID(), titulo });
      try {
        await salvar(titulo);
        return { erro: null };
      } catch {
        return { erro: 'Falha ao salvar a tarefa.' };
      }
    },
    { erro: null },
  );

  return (
    <div>
      <form action={acao}>
        <label>
          Nova tarefa
          <input name="titulo" required disabled={enviando} />
        </label>
        <button type="submit" disabled={enviando}>
          Adicionar
        </button>
      </form>

      {estado.erro && <p role="alert">{estado.erro}</p>}

      <ul>
        {otimistas.map((t) => (
          <li key={t.id} aria-busy={t.pendente}>
            {t.titulo}
            {t.pendente && ' (salvando...)'}
          </li>
        ))}
      </ul>
    </div>
  );
}
```

A atualização otimista é revertida ao fim da Action: o item definitivo vem de `tarefas`, atualizado pelo pai (estado ou invalidação de cache).

## 2. Dados de servidor com TanStack Query

```tsx
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { z } from 'zod';

const UsuarioSchema = z.object({ id: z.string(), nome: z.string() });
type Usuario = z.infer<typeof UsuarioSchema>;

async function buscarUsuario(id: string, signal: AbortSignal): Promise<Usuario> {
  const res = await fetch(`/api/usuarios/${id}`, { signal });
  if (!res.ok) throw new Error(`Falha HTTP ${res.status}`);
  return UsuarioSchema.parse(await res.json()); // valida a fronteira
}

export function useUsuario(id: string) {
  return useQuery({
    queryKey: ['usuarios', id],
    queryFn: ({ signal }) => buscarUsuario(id, signal),
    staleTime: 5 * 60_000,
  });
}

export function useRenomearUsuario(id: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (nome: string) => {
      const res = await fetch(`/api/usuarios/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ nome }),
      });
      if (!res.ok) throw new Error(`Falha HTTP ${res.status}`);
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['usuarios', id] }),
  });
}
```
