---
name: -tech-react
description: Orienta o desenvolvimento de interfaces com React e TypeScript. Use ao criar componentes reutilizáveis, gerenciar dados e estado da tela, validar formulários e otimizar a experiência do usuário.
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(npm test *), Bash(npm run *), Bash(npx *), Bash(pnpm test *)
---

# Tech Skill: React Architect (Modern React 19+ & TypeScript)

Diretrizes técnicas especializadas para o desenvolvimento de aplicações front-end escaláveis, type-safe e performáticas com React 19 e TypeScript.


> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧭 **Skill Ativa**: `-tech-react``

---

## 1. Processo de Execução de Engenharia React

Ao implementar componentes e fluxos em React:

1. **Modelagem de Componentes & Props**: Defina interfaces TypeScript explícitas para as propriedades de cada componente.
2. **Separação de Estado de Servidor vs Cliente**:
   - Utilize **TanStack Query** para carregar, cachear e sincronizar dados de APIs externas.
   - Utilize **Zustand** para estados compartilhados de interface (UI state).
3. **Adoção de Primitivos do React 19**: Utilize `useActionState` para formulários assíncronos, `useOptimistic` para feedbacks instantâneos e `use()` para consumo de promises/contextos.
4. **Formulários Type-Safe com Validação**: Integre `react-hook-form` com `zodResolver` para validação na digitação com o mínimo de re-renderizações.
5. **Uso Consciente de Efeitos**: Isole `useEffect` estritamente para conexões com sistemas externos, eliminando efeitos que sincronizam estados locais a partir de props.

---

## 2. Snippets Canônicos de Referência

### 2.1. React 19 Formulário com `useActionState` e Atualização Otimista
```tsx
import { useActionState, useOptimistic } from 'react';

interface Todo {
  id: string;
  title: string;
  pending?: boolean;
}

interface ActionState {
  error: string | null;
}

export function TodoList({ initialTodos }: { initialTodos: Todo[] }) {
  // Atualização otimista imediata na interface
  const [optimisticTodos, addOptimisticTodo] = useOptimistic(
    initialTodos,
    (state, newTodo: Todo) => [...state, { ...newTodo, pending: true }]
  );

  // React 19: useActionState para gerenciar submissão assíncrona
  const [state, formAction, isPending] = useActionState(
    async (prevState: ActionState, formData: FormData) => {
      const title = formData.get('title') as string;
      addOptimisticTodo({ id: crypto.randomUUID(), title });

      try {
        await fetch('/api/todos', { method: 'POST', body: JSON.stringify({ title }) });
        return { error: null };
      } catch (err) {
        return { error: 'Falha ao salvar tarefa no servidor.' };
      }
    },
    { error: null }
  );

  return (
    <div>
      <form action={formAction}>
        <input name="title" placeholder="Nova tarefa..." required disabled={isPending} />
        <button type="submit" disabled={isPending}>Adicionar</button>
      </form>

      {state.error && <p role="alert" className="error">{state.error}</p>}

      <ul>
        {optimisticTodos.map((todo) => (
          <li key={todo.id} style={{ opacity: todo.pending ? 0.6 : 1 }}>
            {todo.title} {todo.pending && '⏳'}
          </li>
        ))}
      </ul>
    </div>
  );
}
```

### 2.2. Busca e Cache de Dados com TanStack Query
```tsx
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

export function useUserProfile(userId: string) {
  const queryClient = useQueryClient();

  const query = useQuery({
    queryKey: ['users', userId],
    queryFn: async ({ signal }) => {
      const res = await fetch(`/api/users/${userId}`, { signal });
      if (!res.ok) throw new Error('Falha ao buscar perfil.');
      return res.json();
    },
    staleTime: 1000 * 60 * 5, // 5 minutos de cache fresco
  });

  const mutation = useMutation({
    mutationFn: async (newName: string) => {
      await fetch(`/api/users/${userId}`, {
        method: 'PATCH',
        body: JSON.stringify({ name: newName }),
      });
    },
    onSuccess: () => {
      // Invalidação granular do cache
      queryClient.invalidateQueries({ queryKey: ['users', userId] });
    },
  });

  return { ...query, updateName: mutation.mutate };
}
```

---

## 3. Armadilhas Críticas em React (*Gotchas*)

- ⚠️ **Objetos Literais em Arrays de Dependência**: Passar `[ { id: 1 } ]` no array de dependências do `useEffect` ou `useMemo` cria uma nova referência de memória a cada render, disparando loops infinitos de execução.
- ⚠️ **`useEffect` para Derivar Estado**: Atualizar um `useState` dentro de um `useEffect` que escuta uma `prop` força uma segunda renderização desnecessária e causa *flickers* visuais. Calcule o valor diretamente no corpo do componente ou via `useMemo`.
- ⚠️ **Chaves Instáveis (`key={index}`) em Listas**: Usar o índice do array como `key` em listas mutáveis causa bugs visuais e perda de foco em inputs quando itens são filtrados ou reordenados.

---

## 4. Padrão de Entrega do Agente

Ao entregar código em React / TypeScript:
1. Componentes 100% funcionais e tipados com interfaces explícitas.
2. Não utilize `useEffect` para busca de dados se houver suporte a TanStack Query/Server Components.
3. Garanta acessibilidade semântica (ARIA, labels e foco).
