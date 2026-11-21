# Padrões e Exemplos de Angular (`sk-tech-angular`)

## 1. Serviço de estado com signals

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

## 2. Componente com inputs, outputs e computed

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

## 3. Busca com `model`, `linkedSignal`, erro exposto e interop com RxJS

```ts
import { ChangeDetectionStrategy, Component, inject, linkedSignal, model, signal } from '@angular/core';
import { toObservable, toSignal } from '@angular/core/rxjs-interop';
import { HttpClient } from '@angular/common/http';
import { catchError, debounceTime, distinctUntilChanged, of, switchMap, tap } from 'rxjs';

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
    @if (erro()) {
      <p role="alert">{{ erro() }}</p>
    }
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
  readonly erro = signal<string | null>(null);

  readonly resultados = toSignal(
    toObservable(this.termo).pipe(
      debounceTime(300),
      distinctUntilChanged(),
      switchMap((t) => {
        if (t.length < 2) {
          this.erro.set(null);
          return of<Resultado[]>([]);
        }
        return this.http.get<Resultado[]>('/api/busca', { params: { q: t } }).pipe(
          tap(() => this.erro.set(null)),
          catchError(() => {
            this.erro.set('Não foi possível carregar os resultados.');
            return of<Resultado[]>([]);
          }),
        );
      }),
    ),
    { initialValue: [] as Resultado[] },
  );
}
```
