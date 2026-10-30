---
name: sk-tech-react
description: "Orienta interfaces com React e TypeScript: componentes e props tipados, estado local, de servidor (TanStack Query ou o data layer do framework) e global, Actions e hooks do React 19, formulários, uso correto de efeitos, desempenho com medição, tratamento de erros e acessibilidade. Use sempre que o usuário pedir 'componente React', 'hook', 'formulário', 'estado', 'busca de dados', 'otimize renderização' ou 'migre para React 19', mesmo sem dizer 'React'. NÃO use para tokens e acessibilidade em profundidade (isso é sk-design-system), tipagem em geral (isso é sk-tech-typescript) nem para o backend."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(npx tsc *), Bash(npx vitest *), Bash(npx jest *), Bash(npx eslint *), Bash(npm test *), Bash(npm run test *), Bash(npm run lint *), Bash(npm run typecheck *), Bash(npm run build *), Bash(pnpm test *), Bash(pnpm run test *), Bash(pnpm run lint *), Bash(pnpm run typecheck *)
---

# React: interfaces tipadas, previsíveis e rápidas

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-tech-react`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão e framework.** Leia a versão de `react` e o framework (Next, Remix, Vite) no `package.json` e use só o que eles suportam. Recursos do React 19, Server Components e o React Compiler: confirme o suporte e a configuração do projeto na documentação oficial.

**Siga o projeto.** Respeite a estrutura, a biblioteca de estado e de dados e o sistema de design existentes. Tipagem: `sk-tech-typescript`.

**Modos.** Escrever, Revisar e Atualizar versão.

**Idioma.** O do usuário; nomes de código ficam como estão.

---

## 1. Princípios

- **Componentes funcionais** com props tipadas, pequenos e compostos; chaves estáveis em listas (nunca o índice em listas mutáveis).
- **Estado no lugar certo**: local primeiro; **estado de servidor** com TanStack Query ou com o data layer do framework (loaders, Server Components); estado global de UI (Zustand ou Context) só quando necessário.
- **React 19**: `use`, `useActionState`, `useOptimistic`, `useFormStatus`, `ref` como prop e Actions em formulários.
- **Efeitos só para sincronizar com sistemas externos**, com limpeza. Valores derivados são calculados na renderização, não em `useEffect`.
- **Formulários**: Actions do React 19 ou `react-hook-form` com `zodResolver`; a validação do servidor continua obrigatória.
- **Desempenho com medição**: `memo`, `useMemo` e `useCallback` só com evidência. Se o projeto usa o React Compiler, não os adicione à mão. Divida o código com `lazy` e `Suspense` e virtualize listas longas.
- **Erros**: *error boundaries* em fronteiras de tela, e estados de carregamento, vazio e erro em todo componente que carrega dados.
- **Segurança**: sem `dangerouslySetInnerHTML` com conteúdo não sanitizado; tokens fora de `localStorage` (`sk-security`).
- **Acessibilidade**: elementos semânticos, rótulos e foco (`sk-design-system`).
- **Testes**: Testing Library consultando por papel e texto, com MSW para a rede.

---

## 2. Exemplos

### 2.1. Formulário com Action e atualização otimista

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

### 2.2. Dados de servidor com TanStack Query

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

---

## 3. Integrações

`sk-tech-typescript` (tipos), `sk-design-system` (tokens e acessibilidade), `sk-testing` (testes de componente), `sk-api-design` (contratos), `sk-security` (XSS e tokens), `sk-code-review` e `sk-devops`. Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 4. Armadilhas

- **Objeto ou array literal na lista de dependências**: nova referência a cada render, com loops de efeito.
- **`useEffect` para derivar estado**: renderização extra e cintilação. Calcule na renderização.
- **`key={index}`** em lista mutável: perda de foco e estado trocado entre itens.
- **`fetch` sem checar `res.ok`** e sem cancelamento.
- **Otimizar sem medir**: `memo` em todo lugar só adiciona custo.
- **Estado de servidor copiado para `useState`**: duplica a fonte de verdade.
- **Atualização otimista sem fonte de verdade que a confirme.**

---

## 5. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Componentes tipados com estados de carregamento, vazio e erro, e acessibilidade básica, com links relativos.
3. Resultado de testes, tipos e lint, ou o motivo de não ter executado.
4. Pendências: se houver, pergunte se o usuário quer registrar no `TASKS.md` via `sk-tasks` (modo Importar, origem `tech-react`, P1 a P3; fallback em lista no chat).