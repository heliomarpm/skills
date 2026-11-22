# Exemplos de referência: Rust idiomático (`axum`, `tokio`, `sqlx`)

Estes padrões complementam [SKILL.md](../SKILL.md). Confirme as crates e features declaradas no `Cargo.toml` do projeto.

---

## 1. Erro de domínio com `thiserror`, handler `axum` (Problem Details) e *graceful shutdown*

```rust
use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::{IntoResponse, Response},
    routing::get,
    Json, Router,
};
use serde::Serialize;
use std::sync::Arc;
use thiserror::Error;
use tokio::net::TcpListener;

#[derive(Debug, Error)]
pub enum AccountError {
    #[error("account '{0}' not found")]
    NotFound(String),
    #[error("storage unavailable")]
    Storage(#[from] sqlx::Error),
}

#[derive(Serialize)]
struct ProblemDetails<'a> {
    #[serde(rename = "type")]
    kind: &'a str,
    title: &'a str,
    status: u16,
    detail: String,
}

impl IntoResponse for AccountError {
    fn into_response(self) -> Response {
        match self {
            AccountError::NotFound(id) => (
                StatusCode::NOT_FOUND,
                Json(ProblemDetails {
                    kind: "about:blank",
                    title: "Resource not found",
                    status: 404,
                    detail: format!("Account {id} does not exist"),
                }),
            )
                .into_response(),
            AccountError::Storage(_) => (
                StatusCode::SERVICE_UNAVAILABLE,
                Json(ProblemDetails {
                    kind: "about:blank",
                    title: "Service unavailable",
                    status: 503,
                    detail: "Temporary persistence error".to_owned(),
                }),
            )
                .into_response(),
        }
    }
}

pub async fn run_server(router: Router, listener: TcpListener) -> std::io::Result<()> {
    axum::serve(listener, router)
        .with_graceful_shutdown(shutdown_signal())
        .await
}

async fn shutdown_signal() {
    let _ = tokio::signal::ctrl_c().await;
}
```

---

## 2. Repositório `sqlx` parametrizado com projeção estrita e migration `up.sql`/`down.sql`

```rust
use sqlx::{FromRow, PgPool};
use time::OffsetDateTime;

#[derive(Debug, FromRow, Serialize)]
pub struct AuditEventSummary {
    pub id: i64,
    pub action: String,
    pub created_at: OffsetDateTime,
}

pub async fn list_recent_tenant_events(
    pool: &PgPool,
    tenant_id: &str,
    limit: i64,
) -> Result<Vec<AuditEventSummary>, sqlx::Error> {
    let safe_limit = limit.clamp(1, 100);
    sqlx::query_as::<_, AuditEventSummary>(
        r#"
        SELECT id, action, created_at
        FROM audit_events
        WHERE tenant_id = $1
        ORDER BY created_at DESC
        LIMIT $2
        "#,
    )
    .bind(tenant_id)
    .bind(safe_limit)
    .fetch_all(pool)
    .await
}
```

Arquivos de migration (`sqlx migrate` / PostgreSQL sem bloqueio de escrita em produção):

```sql
-- migrations/20260501120000_idx_audit_events_tenant_created.up.sql
-- sqlx: no-transaction (CREATE INDEX CONCURRENTLY exige execução fora de transação no PostgreSQL)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_audit_events_tenant_created_at
    ON audit_events (tenant_id, created_at DESC);
```

```sql
-- migrations/20260501120000_idx_audit_events_tenant_created.down.sql
-- sqlx: no-transaction
DROP INDEX CONCURRENTLY IF EXISTS idx_audit_events_tenant_created_at;
```
