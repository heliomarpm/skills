---
name: sk-tech-angular
description: "Orienta aplicações Angular modernas com Signals: signal, computed, effect, linkedSignal, inputs, outputs e models baseados em signals, signal queries, interop com RxJS (toSignal, toObservable), serviços de estado com signals, componentes standalone com OnPush, novo control flow (@if, @for, @defer), roteamento, formulários tipados, desempenho e testes. Use sempre que o usuário pedir 'componente Angular', 'signals', 'estado reativo', 'serviço', 'rota', 'formulário', 'otimize a renderização' ou 'migre para signals', mesmo sem dizer 'Angular'. NÃO use para tokens e acessibilidade em profundidade (isso é sk-design-system), tipagem em geral (isso é sk-tech-typescript) nem para o backend."
allowed-tools: Read, Edit, Write, Grep, Glob, Bash(ng test *), Bash(ng build *), Bash(ng lint *), Bash(npx tsc *), Bash(npx eslint *), Bash(npm test *), Bash(npm run test *), Bash(npm run lint *), Bash(npm run build *), Bash(pnpm test *), Bash(pnpm run test *), Bash(pnpm run lint *), Bash(pnpm run build *)
---

# Angular: Signals, componentes enxutos e renderização eficiente

## 0. Regras de operação

**Assinatura.** A primeira mensagem do fluxo começa com:

> 🧠 **Skill Ativada**: `sk-tech-angular`

As mensagens seguintes do mesmo fluxo não repetem a assinatura.

**Versão.** Leia a versão do `@angular/core` no `package.json` e use só o que ela suporta. Estágio e API de recursos recentes (Resource API, `httpResource`, formulários baseados em signals, zoneless) mudaram entre versões: **confirme na documentação oficial da versão do projeto** antes de usá-los.

**Siga o projeto.** Respeite a estrutura, o gerenciador de estado (NgRx, SignalStore) e o sistema de design existentes. Em projeto legado, migre aos poucos (veja a seção 5). Tipagem: `sk-tech-typescript`.

**Modos.** Escrever, Revisar e Atualizar versão (migração para signals e control flow).

**Idioma.** O do usuário; nomes de código ficam como estão.

---

## 1. Signals: o modelo de reatividade

| API | Uso |
| :--- | :--- |
| `signal()` | Estado gravável (`set`, `update`) |
| `computed()` | Valor derivado, memoizado e somente leitura |
| `linkedSignal()` | Estado derivado que também aceita escrita e se redefine quando a fonte muda |
| `effect()` | Efeito colateral (log, sincronizar com API externa), **nunca** para derivar estado |
| `input()`, `input.required()` | Entradas do componente como signals |
| `output()` | Eventos do componente |
| `model()` | Binding bidirecional (`[(valor)]`) |
| `viewChild()`, `contentChild()` e variantes | Consultas ao template como signals |
| `toSignal()`, `toObservable()` | Interop com RxJS |
| `untracked()` | Ler um signal sem criar dependência |

**Regras**
- Atualize signals de forma **imutável** (`update` retornando novo valor); mutar um objeto dentro do signal não notifica.
- Em templates e código, **chame o signal** (`valor()`); sem os parênteses, você usa a função e não o valor.
- Estado compartilhado: serviço com signals privados e `asReadonly()` expostos. Para casos mais complexos, NgRx SignalStore.
- RxJS continua indicado para fluxos assíncronos e eventos (debounce, cancelamento, combinação); converta na borda com `toSignal`.
- `computed` não tem efeitos colaterais, e `effect` não é para propagar estado entre signals.

---

## 2. Princípios

- **Standalone** (padrão a partir do Angular 19; em versões anteriores declare `standalone: true`) e **`OnPush`**.
- **Control flow**: `@if`, `@for (... ; track item.id)`, `@switch`, `@let`; `@defer` para conteúdo pesado ou fora da dobra.
- **Sem lógica cara no template**: use `computed` em vez de chamar métodos.
- **Injeção** com `inject()`; guards, resolvers e interceptors funcionais; rotas com `loadComponent` (carregamento sob demanda).
- **Dados assíncronos**: `toSignal` com `switchMap` é a base estável. As APIs de recurso (`resource`, `rxResource`, `httpResource`) são mais novas e variam por versão.
- **Formulários reativos tipados.**
- **Segurança**: o Angular sanitiza por padrão; evite `bypassSecurityTrust*` (`sk-security`).
- **Acessibilidade**: elementos semânticos e CDK a11y (`sk-design-system`).
- **Testes**: `TestBed` e harnesses; entradas com `fixture.componentRef.setInput`, e signals com `set` nos testes (`sk-testing`).

---

## 3. Exemplos

### 3.1. Serviço de estado com signals

```ts
import { Injectable, computed, signal } from '@angular/core';

export interface ItemCarrinho {
  sku: string;
  nome: string;
  quantidade: number;
  precoCentavos: number;
}

@Injectable({ providedIn: 'root' })
export class CarrinhoStore {
  private readonly _itens = signal<readonly ItemCarrinho[]>([]);

  readonly itens = this._itens.asReadonly();
  readonly vazio = computed(() => this._itens().length === 0);
  readonly totalCentavos = computed(() =>
    this._itens().reduce((soma, i) => soma + i.quantidade * i.precoCentavos, 0),
  );

  adicionar(item: ItemCarrinho): void {
    this._itens.update((lista) => {
      const existente = lista.find((i) => i.sku === item.sku);
      return existente
        ? lista.map((i) => (i.sku === item.sku ? { ...i, quantidade: i.quantidade + item.quantidade } : i))
        : [...lista, item];
    });
  }

  remover(sku: string): void {
    this._itens.update((lista) => lista.filter((i) => i.sku !== sku));
  }
}
```

### 3.2. Componente com inputs, outputs e computed

```ts
import { ChangeDetectionStrategy, Component, computed, inject, input, output } from '@angular/core';
import { CurrencyPipe } from '@angular/common';
import { CarrinhoStore } from './carrinho.store';

@Component({
  selector: 'app-resumo-carrinho',
  imports: [CurrencyPipe],
  changeDetection: ChangeDetectionStrategy.OnPush, // standalone é o padrão no Angular 19+
  template: `
    @if (store.vazio()) {
      <p>Seu carrinho está vazio.</p>
    } @else {
      <ul>
        @for (item of store.itens(); track item.sku) {
          <li>
            {{ item.nome }} × {{ item.quantidade }}
            <button type="button" (click)="remover.emit(item.sku)">Remover</button>
          </li>
        }
      </ul>
      <p>Total: {{ total() | currency: moeda() }}</p>
    }
  `,
})
export class ResumoCarrinhoComponent {
  protected readonly store = inject(CarrinhoStore);

  readonly moeda = input<string>('BRL');
  readonly remover = output<string>();

  protected readonly total = computed(() => this.store.totalCentavos() / 100);
}
```

### 3.3. Busca com `model`, `linkedSignal` e interop com RxJS

```ts
import { ChangeDetectionStrategy, Component, inject, linkedSignal, model } from '@angular/core';
import { toObservable, toSignal } from '@angular/core/rxjs-interop';
import { HttpClient } from '@angular/common/http';
import { catchError, debounceTime, distinctUntilChanged, of, switchMap } from 'rxjs';

interface Resultado {
  id: string;
  titulo: string;
}

@Component({
  selector: 'app-busca',
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <input #campo [value]="termo()" (input)="termo.set(campo.value)" aria-label="Buscar" />
    <p>Página {{ pagina() }}</p>
    <ul>
      @for (r of resultados(); track r.id) {
        <li>{{ r.titulo }}</li>
      }
    </ul>
  `,
})
export class BuscaComponent {
  private readonly http = inject(HttpClient);

  readonly termo = model(''); // uso no pai: [(termo)]="texto"
  readonly pagina = linkedSignal({ source: this.termo, computation: () => 1 }); // volta à página 1 quando o termo muda (Angular 19+)

  readonly resultados = toSignal(
    toObservable(this.termo).pipe(
      debounceTime(300),
      distinctUntilChanged(),
      switchMap((t) =>
        t.length < 2
          ? of<Resultado[]>([])
          : this.http.get<Resultado[]>('/api/busca', { params: { q: t } }).pipe(catchError(() => of<Resultado[]>([]))),
      ),
    ),
    { initialValue: [] as Resultado[] },
  );
}
```

---

## 4. Integrações

`sk-tech-typescript` (tipos), `sk-design-system` (tokens e acessibilidade), `sk-testing` (testes de componente), `sk-api-design` (contratos), `sk-security`, `sk-code-review` e `sk-devops`. Se alguma não existir, siga o padrão desta skill sem a integração.

---

## 5. Migração e versões

Migre por etapas: control flow (`@if`, `@for`) com o schematic oficial; inputs, outputs e queries para a API baseada em signals; serviços para signals; e, por fim, `OnPush` e o que a versão permitir. Cada etapa com testes verdes. Antes de adotar recursos novos, confirme o estágio na documentação da versão do projeto.

---

## 6. Armadilhas

- **Mutar o objeto dentro de um signal**: não notifica e o `OnPush` não atualiza. Atualize de forma imutável.
- **`effect` para derivar estado**: use `computed` ou `linkedSignal`.
- **Esquecer de chamar o signal** (`valor` em vez de `valor()`).
- **`@for` sem `track`**: recria nós do DOM.
- **Método no template**: reexecuta a cada verificação. Use `computed`.
- **`inject()` fora do contexto de injeção**: erro `NG0203`; use `runInInjectionContext` quando necessário.
- **`subscribe` manual sem encerramento**: vazamento. Prefira `toSignal`, `async` pipe ou `takeUntilDestroyed`.
- **`bypassSecurityTrust*`** com conteúdo do usuário: abre XSS.
- **Adotar APIs experimentais sem conferir a versão.**

---

## 7. Padrão de entrega

1. Assinatura na primeira mensagem (seção 0) e o modo usado.
2. Componentes standalone com `OnPush` e Signals, com estados de carregamento, vazio e erro, com links relativos.
3. Resultado de testes, build e lint, ou o motivo de não ter executado.
4. Pendências: se houver, pergunte se o usuário quer registrar no `TASKS.md` via `sk-tasks` (modo Importar, origem `tech-angular`, P1 a P3; fallback em lista no chat).