---
name: sk-tech-vue
description: "Orienta Vue 3 e TypeScript: script setup, Composition API tipada, defineModel, composables com cancelamento, Pinia, shallowRef/toRefs e testes. Use para componentes, composables ou estado em Vue 3. NÃO use para tokens/WCAG (sk-design-system), tipagem geral (sk-tech-typescript) nem rotas/actions de servidor com banco (sk-tech-nodejs, sk-sql)."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(npx vue-tsc *), Bash(npx tsc *), Bash(npx vitest *), Bash(npx eslint *), Bash(npm test *), Bash(npm run test *), Bash(npm run lint *), Bash(npm run typecheck *), Bash(npm run build *), Bash(pnpm test *), Bash(pnpm run test *), Bash(pnpm run lint *), Bash(pnpm run typecheck *), Bash(pnpm run build *)
---

# Vue 3: reatividade previsível e componentes enxutos

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-tech-vue`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão e framework.** Leia a versão de `vue` e o framework (Vite, Nuxt) no `package.json` e use só o que eles suportam. A desestruturação reativa de props e `onWatcherCleanup` são do Vue 3.5; `defineModel`, do 3.4. Confirme na documentação oficial da versão do projeto.

**Siga o projeto.** Respeite a estrutura, o gerenciador de estado e o sistema de design existentes. Tipagem: `sk-tech-typescript`.

**Timebox e Circuit Breaker.** Ao corrigir erros de compilação, tipos, build, lint ou testes, pare após **3 tentativas consecutivas** sobre a mesma falha. Informe o erro exato, o que foi tentado e a causa provável, e peça direção ao usuário.

**Modos.** Escrever, Revisar e Atualizar versão.

**Idioma.** O do usuário; nomes de código ficam como estão.

---

## 1. Princípios

- **`<script setup lang="ts">`** com Composition API tipada.
- **Props e eventos tipados**; `defineModel()` para bindings bidirecionais; desestruturação reativa de props (3.5+) com valores padrão.
- **Composables** (`useAlgo()`) para lógica reutilizável, aceitando `MaybeRefOrGetter` e usando `toValue()`; retornam um objeto plano de `ref`s.
- **Reatividade correta**: não desestruture `reactive` direto (use `toRefs`); `shallowRef` para coleções grandes e estáticas; `computed` é função pura, sem efeitos colaterais.
- **Efeitos e limpeza**: `watch` quando a fonte é explícita, `watchEffect` quando é implícita; cancele requisições com `onWatcherCleanup` ou `onScopeDispose`.
- **Estado global** com Pinia em *setup stores*; estado de servidor com uma biblioteca de dados (por exemplo, TanStack Query para Vue) ou o data layer do framework.
- **Listas** com `key` estável; `v-html` só com conteúdo sanitizado (`sk-security`).
- **Acessibilidade** com elementos semânticos e rótulos (`sk-design-system`).
- **Testes**: Vitest com Vue Test Utils ou Testing Library; verificação de tipos com `vue-tsc`.

---

## 2. Exemplos

Consulte implementações de referência em [examples/patterns.md](./examples/patterns.md): componente `<script setup>` com `defineModel` e props reativas (Vue 3.5+), e composable `useFetch` com `AbortController` via `onWatcherCleanup` evitando condições de corrida.

---

## 3. Integrações

`sk-tech-typescript` (tipos), `sk-design-system` (tokens e acessibilidade), `sk-testing` (testes), `sk-api-design` (contratos), `sk-security` (XSS), `sk-code-review` e `sk-devops`. Para rotas/server handlers com banco (Nuxt), acione `sk-tech-nodejs` e `sk-sql`. Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 4. Armadilhas

- **Desestruturar `reactive` ou `props` sem os recursos corretos**: perde a reatividade (use `toRefs`, ou a desestruturação reativa do 3.5+).
- **`ref` em coleções enormes e estáticas**: proxies profundos consomem memória; use `shallowRef`.
- **Efeitos colaterais em `computed`.**
- **Requisição sem cancelamento**: respostas antigas sobrescrevem as novas.
- **`v-for` sem `key` ou com índice em lista mutável.**
- **`v-html` com conteúdo não sanitizado.**
- **`catch (e: any)`**: use `unknown` e estreite.
- **Loop de build/lint (*fix loop*)**: insistir em correções sucessivas após 3 falhas sem acionar o circuit breaker.

---

## 5. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Componentes e composables tipados, com estados de carregamento, vazio e erro, com links relativos.
3. Resultado de testes, `vue-tsc` e lint, o motivo de não ter executado ou o relato do circuit breaker.
4. Somente se restarem pendências relevantes não resolvidas: pergunte se o usuário quer registrar no `TASKS.md` via `sk-tasks` (modo Importar, origem `tech-vue`, P1 a P3; fallback em lista no chat).
