# Padrões e Exemplos de Vue 3 (`sk-tech-vue`)

## 1. Componente com `defineModel` e props reativas (Vue 3.5+)

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

## 2. Composable com cancelamento e sem condição de corrida

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
