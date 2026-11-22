# Exemplos de referência: Kotlin moderno (JVM & Android)

Estes padrões complementam [SKILL.md](../SKILL.md). Confirme as versões de Kotlin, Exposed/JPA e Compose no `build.gradle.kts` / `libs.versions.toml` do projeto.

---

## 1. Caso de uso com `sealed interface`, `CoroutineDispatcher` injetado e propagação de cancelamento

```kotlin
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.withContext
import java.math.BigDecimal

@JvmInline
value class CustomerId(val raw: String)

sealed interface CreditCheckOutcome {
    data class Approved(val limit: BigDecimal) : CreditCheckOutcome
    data class Denied(val reasonCode: String) : CreditCheckOutcome
    data object CustomerNotFound : CreditCheckOutcome
}

interface CustomerPort {
    suspend fun exists(id: CustomerId): Boolean
    suspend fun fetchScore(id: CustomerId): Int
    suspend fun fetchExposure(id: CustomerId): BigDecimal
}

class EvaluateCreditUseCase(
    private val customerPort: CustomerPort,
    private val ioDispatcher: CoroutineDispatcher = Dispatchers.IO,
) {
    suspend fun execute(id: CustomerId): CreditCheckOutcome = withContext(ioDispatcher) {
        try {
            if (!customerPort.exists(id)) {
                return@withContext CreditCheckOutcome.CustomerNotFound
            }

            // Concorrência estruturada: se uma chamada falhar ou o escopo cancelar, a outra cancela junto.
            coroutineScope {
                val scoreDeferred = async { customerPort.fetchScore(id) }
                val exposureDeferred = async { customerPort.fetchExposure(id) }
                val score = scoreDeferred.await()
                val exposure = exposureDeferred.await()

                if (score < 600) {
                    CreditCheckOutcome.Denied("LOW_SCORE")
                } else {
                    val baseLimit = BigDecimal("10000.00").subtract(exposure).max(BigDecimal.ZERO)
                    CreditCheckOutcome.Approved(baseLimit)
                }
            }
        } catch (e: CancellationException) {
            throw e // Obrigatório para não quebrar concorrência estruturada
        }
    }
}
```

---

## 2. Consulta projetada (Exposed) + migration Flyway de índice e rollback

```kotlin
import org.jetbrains.exposed.sql.SortOrder
import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.and
import org.jetbrains.exposed.sql.select
import org.jetbrains.exposed.sql.transactions.experimental.newSuspendedTransaction
import java.math.BigDecimal
import java.time.Instant

object InvoicesTable : Table("invoices") {
    val id = varchar("id", 36)
    val tenantId = varchar("tenant_id", 36)
    val status = varchar("status", 24)
    val totalAmount = decimal("total_amount", 12, 2)
    val dueAt = timestamp("due_at")
    override val primaryKey = PrimaryKey(id)
}

data class PendingInvoiceView(
    val id: String,
    val totalAmount: BigDecimal,
    val dueAt: Instant,
)

class InvoiceReadRepository {
    suspend fun listPendingByTenant(tenantId: String, limit: Int = 50): List<PendingInvoiceView> {
        val safeLimit = limit.coerceIn(1, 200)
        return newSuspendedTransaction {
            InvoicesTable
                .slice(InvoicesTable.id, InvoicesTable.totalAmount, InvoicesTable.dueAt)
                .select { (InvoicesTable.tenantId eq tenantId) and (InvoicesTable.status eq "PENDING") }
                .orderBy(InvoicesTable.dueAt to SortOrder.ASC)
                .limit(safeLimit)
                .map { row ->
                    PendingInvoiceView(
                        id = row[InvoicesTable.id],
                        totalAmount = row[InvoicesTable.totalAmount],
                        dueAt = row[InvoicesTable.dueAt],
                    )
                }
        }
    }
}
```

Migration SQL acompanhante (Flyway / Liquibase):

```sql
-- V20260501_01__idx_invoices_tenant_status_due.sql
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_invoices_tenant_status_due
    ON invoices (tenant_id, status, due_at ASC);

-- Rollback:
DROP INDEX CONCURRENTLY IF EXISTS idx_invoices_tenant_status_due;
```

---

## 3. Android Jetpack Compose com `StateFlow` e `collectAsStateWithLifecycle`

```kotlin
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import kotlinx.coroutines.flow.StateFlow

sealed interface OrdersUiState {
    data object Loading : OrdersUiState
    data class Error(val message: String) : OrdersUiState
    data class Content(val items: List<OrderRowUi>) : OrdersUiState
}

data class OrderRowUi(val id: String, val label: String)

@Composable
fun OrdersRoute(
    uiStateFlow: StateFlow<OrdersUiState>,
    onRetry: () -> Unit,
    onSelect: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    val state by uiStateFlow.collectAsStateWithLifecycle()
    OrdersScreen(state = state, onRetry = onRetry, onSelect = onSelect, modifier = modifier)
}

@Composable
fun OrdersScreen(
    state: OrdersUiState,
    onRetry: () -> Unit,
    onSelect: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    when (state) {
        OrdersUiState.Loading -> Box(modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            CircularProgressIndicator()
        }
        is OrdersUiState.Error -> Column(
            modifier = modifier.fillMaxSize().padding(24.dp),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Text(text = state.message)
            Button(onClick = onRetry, modifier = Modifier.padding(top = 12.dp).heightIn(min = 48.dp)) {
                Text("Tentar novamente")
            }
        }
        is OrdersUiState.Content -> if (state.items.isEmpty()) {
            Box(modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                Text("Nenhum pedido disponível.")
            }
        } else {
            LazyColumn(modifier = modifier.fillMaxSize()) {
                items(items = state.items, key = { it.id }) { item ->
                    Button(
                        onClick = { onSelect(item.id) },
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp).heightIn(min = 48.dp),
                    ) {
                        Text(item.label)
                    }
                }
            }
        }
    }
}
```
