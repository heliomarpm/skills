---
name: sk-tech-react
description: "Orienta React e TypeScript: componentes tipados, TanStack Query, Actions/hooks do React 19, formulários, efeitos, desempenho medido e testes. Use para componentes, hooks ou estado em React. NÃO use para tokens/WCAG (sk-design-system), tipagem geral (sk-tech-typescript) nem rotas/actions de servidor com banco (sk-tech-nodejs, sk-sql)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(npx tsc *), Bash(npx vitest *), Bash(npx jest *), Bash(npx eslint *), Bash(npm test *), Bash(npm run test *), Bash(npm run lint *), Bash(npm run typecheck *), Bash(npm run build *), Bash(pnpm test *), Bash(pnpm run test *), Bash(pnpm run lint *), Bash(pnpm run typecheck *), Bash(pnpm run build *)
---

# React: interfaces tipadas, previsíveis e rápidas

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-tech-react`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão e framework.** Leia a versão de `react` e o framework (Next, Remix, Vite) no `package.json` e use só o que eles suportam. Recursos do React 19, Server Components e o React Compiler: confirme o suporte e a configuração do projeto na documentação oficial.

**Siga o projeto.** Respeite a estrutura, a biblioteca de estado e de dados e o sistema de design existentes. Tipagem: `sk-tech-typescript`.

**Timebox e Circuit Breaker.** Ao corrigir erros de compilação, tipos, build, lint ou testes, pare após **3 tentativas consecutivas** sobre a mesma falha. Informe o erro exato, o que foi tentado e a causa provável, e peça direção ao usuário.

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

Consulte implementações de referência em [examples/patterns.md](./examples/patterns.md): formulário com `useActionState` + `useOptimistic` (React 19) e queries/mutations com TanStack Query, `AbortSignal` e validação Zod na fronteira.

---

## 3. Integrações

`sk-tech-typescript` (tipos), `sk-design-system` (tokens e acessibilidade), `sk-testing` (testes de componente), `sk-api-design` (contratos), `sk-security` (XSS e tokens), `sk-code-review` e `sk-devops`. Para rotas de API, Server Actions ou loaders com acesso a banco (Next/Remix), acione `sk-tech-nodejs` e `sk-sql`. Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 4. Armadilhas

- **Objeto ou array literal na lista de dependências**: nova referência a cada render, com loops de efeito.
- **`useEffect` para derivar estado**: renderização extra e cintilação. Calcule na renderização.
- **`key={index}`** em lista mutável: perda de foco e estado trocado entre itens.
- **`fetch` sem checar `res.ok`** e sem cancelamento.
- **Otimizar sem medir**: `memo` em todo lugar só adiciona custo.
- **Estado de servidor copiado para `useState`**: duplica a fonte de verdade.
- **Atualização otimista sem fonte de verdade que a confirme.**
- **Loop de build/lint (*fix loop*)**: insistir em correções sucessivas após 3 falhas sem acionar o circuit breaker.

---

## 5. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Componentes tipados com estados de carregamento, vazio e erro, e acessibilidade básica, com links relativos.
3. Resultado de testes, tipos e lint, o motivo de não ter executado ou o relato do circuit breaker.
4. Somente se restarem pendências relevantes não resolvidas: pergunte se o usuário quer registrar no `TASKS.md` via `sk-tasks` (modo Importar, origem `tech-react`, P1 a P3; fallback em lista no chat).
