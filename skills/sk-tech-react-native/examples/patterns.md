# Exemplos de referência: React Native & Expo

Estes padrões complementam [SKILL.md](../SKILL.md). Confirme as bibliotecas instaladas (`FlashList` vs `FlatList`, `expo-secure-store`, `expo-sqlite`) no `package.json` do projeto.

---

## 1. Lista virtualizada acessível com estados e *safe areas*

```tsx
import { useCallback } from 'react';
import { ActivityIndicator, FlatList, Pressable, StyleSheet, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useFocusEffect } from '@react-navigation/native';
import { useQuery } from '@tanstack/react-query';

interface InvoiceItem {
  readonly id: string;
  readonly reference: string;
  readonly amountFormatted: string;
}

interface InvoicesScreenProps {
  readonly fetchInvoices: (signal: AbortSignal) => Promise<readonly InvoiceItem[]>;
  readonly onSelectInvoice: (id: string) => void;
}

export function InvoicesScreen({ fetchInvoices, onSelectInvoice }: InvoicesScreenProps) {
  const insets = useSafeAreaInsets();
  const query = useQuery({
    queryKey: ['invoices'],
    queryFn: ({ signal }) => fetchInvoices(signal),
  });

  useFocusEffect(
    useCallback(() => {
      void query.refetch();
    }, [query.refetch]),
  );

  const renderItem = useCallback(
    ({ item }: { item: InvoiceItem }) => (
      <Pressable
        onPress={() => onSelectInvoice(item.id)}
        accessibilityRole="button"
        accessibilityLabel={`Abrir fatura ${item.reference}, valor ${item.amountFormatted}`}
        style={({ pressed }) => [styles.row, pressed && styles.rowPressed]}
      >
        <Text style={styles.title}>{item.reference}</Text>
        <Text style={styles.amount}>{item.amountFormatted}</Text>
      </Pressable>
    ),
    [onSelectInvoice],
  );

  if (query.isPending) {
    return (
      <View style={[styles.center, { paddingTop: insets.top }]}>
        <ActivityIndicator size="large" accessibilityLabel="Carregando faturas" />
      </View>
    );
  }

  if (query.isError) {
    return (
      <View style={[styles.center, { paddingTop: insets.top }]}>
        <Text style={styles.errorText}>Não foi possível carregar as faturas.</Text>
        <Pressable
          onPress={() => void query.refetch()}
          accessibilityRole="button"
          style={styles.retryButton}
        >
          <Text style={styles.retryLabel}>Tentar novamente</Text>
        </Pressable>
      </View>
    );
  }

  return (
    <FlatList
      data={query.data}
      keyExtractor={(item) => item.id}
      renderItem={renderItem}
      contentContainerStyle={{
        paddingTop: insets.top,
        paddingBottom: insets.bottom + 16,
      }}
      ListEmptyComponent={
        <View style={styles.center}>
          <Text>Nenhuma fatura encontrada.</Text>
        </View>
      }
    />
  );
}

const styles = StyleSheet.create({
  center: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 24 },
  row: {
    minHeight: 52, // Garante alvo de toque confortavel acima de 48dp
    paddingHorizontal: 16,
    paddingVertical: 12,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  rowPressed: { opacity: 0.7 },
  title: { fontSize: 16, fontWeight: '600' },
  amount: { fontSize: 16 },
  errorText: { marginBottom: 12, textAlign: 'center' },
  retryButton: { minHeight: 48, paddingHorizontal: 20, justifyContent: 'center' },
  retryLabel: { fontWeight: '600' },
});
```

---

## 2. Repositório isolado de armazenamento seguro (`expo-secure-store`)

```typescript
import * as SecureStore from 'expo-secure-store';

const ACCESS_TOKEN_KEY = 'session.access_token';
const REFRESH_TOKEN_KEY = 'session.refresh_token';

export interface SessionTokens {
  readonly accessToken: string;
  readonly refreshToken: string;
}

export const secureSessionStorage = {
  async save(tokens: SessionTokens): Promise<void> {
    await SecureStore.setItemAsync(ACCESS_TOKEN_KEY, tokens.accessToken, {
      keychainAccessible: SecureStore.AFTER_FIRST_UNLOCK_THIS_DEVICE_ONLY,
    });
    await SecureStore.setItemAsync(REFRESH_TOKEN_KEY, tokens.refreshToken, {
      keychainAccessible: SecureStore.AFTER_FIRST_UNLOCK_THIS_DEVICE_ONLY,
    });
  },

  async read(): Promise<SessionTokens | null> {
    const [accessToken, refreshToken] = await Promise.all([
      SecureStore.getItemAsync(ACCESS_TOKEN_KEY),
      SecureStore.getItemAsync(REFRESH_TOKEN_KEY),
    ]);
    if (!accessToken || !refreshToken) return null;
    return { accessToken, refreshToken };
  },

  async clear(): Promise<void> {
    await Promise.all([
      SecureStore.deleteItemAsync(ACCESS_TOKEN_KEY),
      SecureStore.deleteItemAsync(REFRESH_TOKEN_KEY),
    ]);
  },
};
```

---

## 3. Persistência local `expo-sqlite` parametrizada com migration de índice + rollback

```typescript
import type { SQLiteDatabase } from 'expo-sqlite';

export interface CachedTaskRow {
  readonly id: string;
  readonly title: string;
  readonly dueAt: string;
}

export async function listDueCachedTasks(
  db: SQLiteDatabase,
  workspaceId: string,
  limit = 40,
): Promise<readonly CachedTaskRow[]> {
  const safeLimit = Math.min(Math.max(1, limit), 200);
  return db.getAllAsync<CachedTaskRow>(
    `
    SELECT id, title, due_at AS dueAt
    FROM cached_tasks
    WHERE workspace_id = ? AND completed = 0
    ORDER BY due_at ASC
    LIMIT ?
    `,
    [workspaceId, safeLimit],
  );
}
```

Migration SQLite versionada acompanhante:

```sql
-- Migration UP: suporta filtro por workspace_id + completed e ordenação por due_at sem varredura completa
CREATE INDEX IF NOT EXISTS idx_cached_tasks_workspace_completed_due
  ON cached_tasks (workspace_id, completed, due_at ASC);

-- Rollback DOWN:
DROP INDEX IF EXISTS idx_cached_tasks_workspace_completed_due;
```
