# Exemplos de referência: Ionic 7/8 + Capacitor

Estes padrões complementam [SKILL.md](../SKILL.md). Adapte imports e ciclo de vida ao framework hospedeiro do projeto (`@ionic/angular/standalone`, `@ionic/react` ou `@ionic/vue`).

---

## 1. Página standalone Ionic + Angular com ciclo `ionView*` e `addIcons`

```typescript
import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import {
  IonBackButton,
  IonButtons,
  IonContent,
  IonHeader,
  IonIcon,
  IonItem,
  IonLabel,
  IonList,
  IonRefresher,
  IonRefresherContent,
  IonSpinner,
  IonTitle,
  IonToolbar,
  ViewDidLeave,
  ViewWillEnter,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { refreshOutline } from 'ionicons/icons';

interface OrderSummary {
  readonly id: string;
  readonly code: string;
  readonly status: string;
}

@Component({
  selector: 'app-orders-page',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    IonHeader,
    IonToolbar,
    IonButtons,
    IonBackButton,
    IonTitle,
    IonContent,
    IonRefresher,
    IonRefresherContent,
    IonList,
    IonItem,
    IonLabel,
    IonIcon,
    IonSpinner,
  ],
  template: `
    <ion-header>
      <ion-toolbar>
        <ion-buttons slot="start">
          <ion-back-button defaultHref="/home" />
        </ion-buttons>
        <ion-title>Pedidos</ion-title>
      </ion-toolbar>
    </ion-header>

    <ion-content class="ion-padding">
      <ion-refresher slot="fixed" (ionRefresh)="onRefresh($event)">
        <ion-refresher-content />
      </ion-refresher>

      @if (loading()) {
        <div class="state-center" role="status" aria-live="polite">
          <ion-spinner name="crescent" />
        </div>
      } @else if (errorMessage()) {
        <p role="alert">{{ errorMessage() }}</p>
      } @else {
        <ion-list>
          @for (order of orders(); track order.id) {
            <ion-item button detail="true">
              <ion-icon name="refresh-outline" slot="start" aria-hidden="true" />
              <ion-label>
                <h2>{{ order.code }}</h2>
                <p>{{ order.status }}</p>
              </ion-label>
            </ion-item>
          } @empty {
            <p>Nenhum pedido encontrado.</p>
          }
        </ion-list>
      }
    </ion-content>
  `,
  styles: `
    ion-toolbar {
      --background: var(--app-surface-elevated);
      --color: var(--app-text-primary);
    }
    .state-center {
      display: grid;
      place-items: center;
      min-height: 8rem;
    }
  `,
})
export class OrdersPage implements ViewWillEnter, ViewDidLeave {
  private readonly ordersService = inject(OrdersService);
  private abortController: AbortController | null = null;

  readonly loading = signal(false);
  readonly errorMessage = signal<string | null>(null);
  readonly orders = signal<readonly OrderSummary[]>([]);

  constructor() {
    // Registro explícito garante renderização mesmo com tree-shaking em produção.
    addIcons({ refreshOutline });
  }

  ionViewWillEnter(): void {
    void this.loadOrders();
  }

  ionViewDidLeave(): void {
    // Cancela requisição em voo quando a tela sai do topo sem destruir o componente em cache.
    this.abortController?.abort();
    this.abortController = null;
  }

  async onRefresh(event: CustomEvent<{ complete: () => void }>): Promise<void> {
    try {
      await this.loadOrders();
    } finally {
      event.detail.complete();
    }
  }

  private async loadOrders(): Promise<void> {
    this.abortController?.abort();
    const controller = new AbortController();
    this.abortController = controller;

    this.loading.set(true);
    this.errorMessage.set(null);

    try {
      const items = await this.ordersService.listRecent(controller.signal);
      this.orders.set(items);
    } catch (err: unknown) {
      if (controller.signal.aborted) return;
      this.errorMessage.set('Não foi possível atualizar os pedidos.');
    } finally {
      if (!controller.signal.aborted) {
        this.loading.set(false);
      }
    }
  }
}
```

---

## 2. Adaptador Capacitor seguro (plataforma, permissão e fallback web)

```typescript
import { Capacitor } from '@capacitor/core';
import { Camera, CameraResultType, CameraSource } from '@capacitor/camera';

export type PhotoCaptureResult =
  | { readonly ok: true; readonly dataUrl: string }
  | { readonly ok: false; readonly reason: 'unsupported' | 'denied' | 'cancelled' };

export async function captureDocumentPhoto(): Promise<PhotoCaptureResult> {
  if (!Capacitor.isPluginAvailable('Camera')) {
    return { ok: false, reason: 'unsupported' };
  }

  if (Capacitor.isNativePlatform()) {
    const perms = await Camera.checkPermissions();
    if (perms.camera !== 'granted') {
      const requested = await Camera.requestPermissions({ permissions: ['camera'] });
      if (requested.camera !== 'granted') {
        return { ok: false, reason: 'denied' };
      }
    }
  }

  try {
    const photo = await Camera.getPhoto({
      resultType: CameraResultType.DataUrl,
      source: CameraSource.Camera,
      quality: 80,
      allowEditing: false,
    });
    if (!photo.dataUrl) {
      return { ok: false, reason: 'cancelled' };
    }
    return { ok: true, dataUrl: photo.dataUrl };
  } catch {
    return { ok: false, reason: 'cancelled' };
  }
}
```

---

## 3. Persistência offline SQLite com parâmetros vinculados e migration de índice + rollback

Consultas frequentes em fila offline ou listagens filtradas precisam de projeção estrita e índice composto cobrindo o filtro e a ordenação:

```typescript
import type { SQLiteDBConnection } from '@capacitor-community/sqlite';

export interface OfflineSyncItem {
  readonly id: string;
  readonly entityType: string;
  readonly updatedAt: string;
}

export async function listPendingSyncBatch(
  db: SQLiteDBConnection,
  tenantId: string,
  limit = 50,
): Promise<readonly OfflineSyncItem[]> {
  const safeLimit = Math.min(Math.max(1, limit), 200);
  const sql = `
    SELECT id, entity_type AS entityType, updated_at AS updatedAt
    FROM sync_outbox
    WHERE tenant_id = ? AND sync_status = ?
    ORDER BY updated_at ASC
    LIMIT ?
  `;
  const result = await db.query(sql, [tenantId, 'pending', safeLimit]);
  return (result.values ?? []) as OfflineSyncItem[];
}
```

Script de migration acompanhante (aplicado na inicialização versionada do SQLite local):

```sql
-- Migration UP: suporta filtro por tenant_id + sync_status e ordenação por updated_at sem full table scan
CREATE INDEX IF NOT EXISTS idx_sync_outbox_tenant_status_updated
  ON sync_outbox (tenant_id, sync_status, updated_at ASC);

-- Rollback DOWN:
DROP INDEX IF EXISTS idx_sync_outbox_tenant_status_updated;
```
