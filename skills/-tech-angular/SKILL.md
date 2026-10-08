---
name: -tech-angular
description: Orienta o desenvolvimento de aplicações com Angular. Use ao criar componentes, gerenciar estado reativo, configurar rotas, serviços e otimizar a renderização da interface.
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(ng test *), Bash(npm test *), Bash(npm run *), Bash(npx *)
---

# Tech Skill: Enterprise Angular Specialist (Modern Angular 18/19+)

Diretrizes técnicas especializadas para o desenvolvimento de aplicações escaláveis, reativas e com alta performance utilizando Angular moderno.


> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧭 **Skill Ativa**: `-tech-angular``

---

## 1. Processo de Execução de Engenharia Angular

Ao implementar componentes, diretivas e serviços em Angular:

1. **Standalone por Padrão**: Crie todos os componentes com `standalone: true` e `changeDetection: ChangeDetectionStrategy.OnPush`.
2. **Novo Control Flow & Defer**: Utilize `@if`, `@for (item of items; track item.id)` e adote `@defer (on viewport)` para componentes pesados abaixo da dobra.
3. **Reatividade com Signals**: Utilize Signal Inputs (`input()`), Outputs (`output()`), Models (`model()`) e derivadas com `computed()`.
4. **Carregamento Assíncrono com Resource API (Angular 19+)**: Utilize `resource()` ou `rxResource()` para carregar dados de APIs diretamente em Signals reativos.
5. **Injeção de Dependências & Prevenção de Leaks**: Utilize `inject()` no nível de campo e garanta o cancelamento de subscrições RxJS com `takeUntilDestroyed()`.

---

## 2. Snippets Canônicos de Referência

### 2.1. Componente Moderno com Signals e Resource API (Angular 19+)
```typescript
import {
  Component,
  ChangeDetectionStrategy,
  input,
  output,
  computed,
  resource,
  inject,
} from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { rxResource } from '@angular/core/rxjs-interop';

interface UserProfile {
  id: string;
  name: string;
  role: string;
}

@Component({
  selector: 'app-user-card',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @if (userResource.isLoading()) {
      <div class="skeleton-loader" role="status">Carregando dados...</div>
    } @else if (userResource.value(); as user) {
      <article class="user-card">
        <h3>{{ user.name }}</h3>
        <p>Perfil: {{ userRoleDisplay() }}</p>
        <button (click)="promote.emit(user.id)">Promover Usuário</button>
      </article>
    } @else if (userResource.error()) {
      <p class="error-msg" role="alert">Erro ao carregar dados do usuário.</p>
    }
  `,
})
export class UserCardComponent {
  private readonly http = inject(HttpClient);

  // Signal Inputs e Outputs modernos
  readonly userId = input.required<string>();
  readonly promote = output<string>();

  // Resource API assíncrona reativa
  readonly userResource = rxResource({
    request: () => this.userId(),
    loader: ({ request: id }) => this.http.get<UserProfile>(`/api/users/${id}`),
  });

  // Signal derivado com computação automática
  readonly userRoleDisplay = computed(() => {
    const user = this.userResource.value();
    return user ? user.role.toUpperCase() : 'N/A';
  });
}
```

### 2.2. Vistas Adferíveis com `@defer` para Otimização de LCP
```html
@defer (on viewport; prefetch on idle) {
  <app-heavy-analytics-chart [data]="chartData()" />
} @placeholder {
  <div class="chart-placeholder">Gráfico será carregado ao rolar a página...</div>
} @loading (minimum 200ms) {
  <div class="chart-spinner">Carregando visualização...</div>
} @error {
  <p>Falha ao carregar gráfico interativo.</p>
}
```

---

## 3. Armadilhas Críticas em Angular (*Gotchas*)

- ⚠️ **Executar `inject()` Fora do Contexto de Injeção**: Chamar a função `inject()` dentro de métodos assíncronos ou fora da fase de construção do componente dispara o erro `NG0203: inject() must be called from an injection context`. Se necessário, envolva com `runInInjectionContext(this.injector, () => { ... })`.
- ⚠️ **Omitir `track` no `@for`**: Iterar coleções com `@for` sem uma chave de rastreamento única (ex: `track item.id`) força o Angular a recriar todos os nós do DOM a cada alteração na lista.
- ⚠️ **Subscrições Manuais sem `takeUntilDestroyed`**: Inscrever-se manualmente em `Observable`s no TypeScript sem operador de encerramento mantém a referência em memória após a destruição do componente, gerando *Memory Leaks*.

---

## 4. Padrão de Entrega do Agente

Ao entregar código em Angular:
1. Declare componentes como `standalone: true` e `OnPush`.
2. Utilize o novo control flow (`@if`, `@for`) em vez de diretivas legadas (`*ngIf`, `*ngFor`).
3. Forneça código com tipagem estrita de Signals e injeção via `inject()`.
