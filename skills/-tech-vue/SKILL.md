---
name: -tech-vue
description: "Orienta interfaces com Vue 3 e TypeScript: script setup, Composition API tipada, defineModel e props reativas, composables reutilizáveis com cancelamento, Pinia, reatividade correta (shallowRef, toRefs), desempenho e testes. Use sempre que o usuário pedir 'componente Vue', 'composable', 'Pinia', 'v-model', 'reatividade' ou 'migre para Vue 3', mesmo sem dizer 'Vue'. NÃO use para tokens e acessibilidade em profundidade (isso é -design-system), tipagem em geral (isso é -tech-typescript) nem para o backend."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(npx vue-tsc *), Bash(npx tsc *), Bash(npx vitest *), Bash(npx eslint *), Bash(npm test *), Bash(npm run test *), Bash(npm run lint *), Bash(npm run typecheck *), Bash(npm run build *), Bash(pnpm test *), Bash(pnpm run test *), Bash(pnpm run lint *), Bash(pnpm run typecheck *)
---

# Vue 3: reatividade previsível e componentes enxutos

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativa**: `-tech-vue`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão e framework.** Leia a versão de `vue` e o framework (Vite, Nuxt) no `package.json` e use só o que eles suportam. A desestruturação reativa de props e `onWatcherCleanup` são do Vue 3.5; `defineModel`, do 3.4. Confirme na documentação oficial da versão do projeto.

**Siga o projeto.** Respeite a estrutura, o gerenciador de estado e o sistema de design existentes. Tipagem: `-tech-typescript`.

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
- **Listas** com `key` estável; `v-html` só com conteúdo sanitizado (`-security`).
- **Acessibilidade** com elementos semânticos e rótulos (`-design-system`).
- **Testes**: Vitest com Vue Test Utils ou Testing Library; verificação de tipos com `vue-tsc`.

---

## 2. Exemplos

### 2.1. Componente com `defineModel` e props reativas (Vue 3.5+)

```vue
<script setup lang="ts">
import { computed } from 'vue';

const { rotulo = 'Contador', max = 100 } = defineProps<{
  rotulo?: string;
  max?: number;
}>();

const contagem = defineModel<number>({ default: 0 });
const atingiuMax = computed(() => contagem.value >= max);

function incrementar(): void {
  if (!atingiuMax.value) contagem.value++;
}
</script>

<template>
  <div>
    <span>{{ rotulo }}: <strong>{{ contagem }}</strong></span>
    <button type="button" :disabled="atingiuMax" @click="incrementar">
      {{ atingiuMax ? 'Limite atingido' : '+1' }}
    </button>
  </div>
</template>
```

### 2.2. Composable com cancelamento e sem corrida

```ts
import { ref, shallowRef, toValue, watchEffect, onWatcherCleanup, type MaybeRefOrGetter } from 'vue';

export function useFetch<T>(origem: MaybeRefOrGetter<string>) {
  const dados = shallowRef<T | null>(null);
  const erro = ref<Error | null>(null);
  const carregando = ref(false);

  watchEffect(async () => {
    const url = toValue(origem);
    const controle = new AbortController();
    onWatcherCleanup(() => controle.abort()); // chame de forma síncrona, antes do primeiro await

    carregando.value = true;
    erro.value = null;
    try {
      const res = await fetch(url, { signal: controle.signal });
      if (!res.ok) throw new Error(`Falha HTTP ${res.status}`);
      dados.value = (await res.json()) as T; // valide com um schema se vier de fonte não confiável
    } catch (e: unknown) {
      if (e instanceof DOMException && e.name === 'AbortError') return; // requisição substituída
      erro.value = e instanceof Error ? e : new Error(String(e));
    } finally {
      if (!controle.signal.aborted) carregando.value = false;
    }
  });

  return { dados, erro, carregando };
}
```

A requisição cancelada não altera o estado: só a mais recente atualiza `carregando`, evitando que uma resposta antiga desligue o indicador de uma nova.

---

## 3. Integrações

`-tech-typescript` (tipos), `-design-system` (tokens e acessibilidade), `-testing` (testes), `-api-design` (contratos), `-security` (XSS), `-code-review` e `-devops`. Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 4. Armadilhas

- **Desestruturar `reactive` ou `props` sem os recursos corretos**: perde a reatividade (use `toRefs`, ou a desestruturação reativa do 3.5+).
- **`ref` em coleções enormes e estáticas**: proxies profundos consomem memória; use `shallowRef`.
- **Efeitos colaterais em `computed`.**
- **Requisição sem cancelamento**: respostas antigas sobrescrevem as novas.
- **`v-for` sem `key` ou com índice em lista mutável.**
- **`v-html` com conteúdo não sanitizado.**
- **`catch (e: any)`**: use `unknown` e estreite.

---

## 5. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Componentes e composables tipados, com estados de carregamento, vazio e erro, com links relativos.
3. Resultado de testes, `vue-tsc` e lint, ou o motivo de não ter executado.
4. Pendências: se houver, pergunte se o usuário quer registrar no `TASKS.md` via `-tasks` (modo Importar, origem `tech-vue`, P1 a P3; fallback em lista no chat).