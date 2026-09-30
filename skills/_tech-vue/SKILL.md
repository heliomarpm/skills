---
name: _tech-vue
description: Orienta o desenvolvimento de interfaces com Vue 3. Use ao criar componentes de interface, gerenciar estado reativo, construir funções utilitárias reutilizáveis e otimizar renderização.
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(npm test *), Bash(npm run *), Bash(npx *), Bash(pnpm test *)
---

# Tech Skill: Vue 3 Expert (Composition API & Vue 3.4/3.5+)

Diretrizes técnicas especializadas para o desenvolvimento de interfaces reativas, performáticas e escaláveis com Vue 3 moderno e TypeScript.


> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧭 **Skill Ativa**: `_tech-vue``

---

## 1. Processo de Execução de Engenharia Vue 3

Ao desenvolver componentes e lógicas reutilizáveis em Vue 3:

1. **Sintaxe `<script setup lang="ts">`**: Utilize exclusivamente Single-File Components com Composition API tipada.
2. **Bindings Declarativos com `defineModel`**: Elimine boilerplate de props/emits manuais utilizando `defineModel()` para *two-way data binding*.
3. **Desestruturação Reativa de Props (Vue 3.5+)**: Desestruture `defineProps` diretamente com valores padrão preservando a reatividade nativa.
4. **Composables Reutilizáveis**: Extraia lógicas e estados compartilhados em funções `useFeature()` aceitando `MaybeRefOrGetter` e convertendo com `toValue()`.
5. **Estado Global com Pinia**: Estruture stores globais utilizando a sintaxe *Setup Stores* (`defineStore('id', () => { ... })`).

---

## 2. Snippets Canônicos de Referência

### 2.1. Componente Moderno com `defineModel` e Props Destructure (Vue 3.5+)
```vue
<script setup lang="ts">
import { computed } from 'vue';

// Vue 3.5: Desestruturação reativa com valores padrão sem perder reatividade
const { label = 'Contador', max = 100 } = defineProps<{
  label?: string;
  max?: number;
}>();

// Vue 3.4+: Two-way binding direto com o v-model pai
const count = defineModel<number>({ default: 0 });

const isMaxReached = computed(() => count.value >= max);

function increment() {
  if (!isMaxReached.value) {
    count.value++;
  }
}
</script>

<template>
  <div class="counter-box">
    <label>{{ label }}: <strong>{{ count }}</strong></label>
    <button @click="increment" :disabled="isMaxReached">
      {{ isMaxReached ? 'Limite Atingido' : '+1' }}
    </button>
  </div>
</template>
```

### 2.2. Composable Reativo Padronizado (`toValue` & Limpeza)
```typescript
import { ref, watchEffect, toValue, onWatcherCleanup, type MaybeRefOrGetter } from 'vue';

export function useFetchData<T>(urlSource: MaybeRefOrGetter<string>) {
  const data = ref<T | null>(null);
  const error = ref<Error | null>(null);
  const isLoading = ref(false);

  watchEffect(async () => {
    const url = toValue(urlSource); // Extrai valor quer seja ref, getter ou string pura
    isLoading.value = true;
    error.value = null;

    const controller = new AbortController();
    
    // Vue 3.5: Limpa requisição anterior se a URL mudar antes da resposta
    onWatcherCleanup(() => controller.abort());

    try {
      const res = await fetch(url, { signal: controller.signal });
      if (!res.ok) throw new Error(`Falha HTTP: ${res.status}`);
      data.value = await res.json();
    } catch (err: any) {
      if (err.name !== 'AbortError') {
        error.value = err;
      }
    } finally {
      isLoading.value = false;
    }
  });

  return { data, error, isLoading };
}
```

---

## 3. Armadilhas Críticas em Vue 3 (*Gotchas*)

- ⚠️ **Desestruturar Objetos `reactive` Diretamente**: Fazer `const { count } = reactive({ count: 0 })` quebra a reatividade do Vue. Se precisar desestruturar, envolva o objeto em `toRefs()`.
- ⚠️ **Reatividade Profunda em Coleções Gigantescas**: Utilizar `ref()` para listas de dezenas de milhares de itens estáticos (ex: logs de telemetria) cria proxies reativos para cada nó interno e consome muita memória. Utilize `shallowRef()` para grandes coleções estáticas.
- ⚠️ **Mutação Indevida em `computed`**: Propriedades computadas devem ser funções puras de transformação de leitura. Nunca altere outros estados reativos dentro de um getter `computed()`.

---

## 4. Padrão de Entrega do Agente

Ao entregar código em Vue 3:
1. Utilize sempre `<script setup lang="ts">`.
2. Adote `defineModel()` para componentes com input/output de dados.
3. Forneça composables com retorno tipado em formato de objeto plano contendo `ref`s desestruturáveis.
