---
name: _observability-sre
description: "Orienta a engenharia de observabilidade e confiabilidade (SRE): instrumentação com OpenTelemetry (Traces, Metrics, Logs), contratos SLI/SLO, diagnóstico de memory leaks/CPU profiling, health checks e graceful shutdown."
allowed-tools: Read, Edit, Write, Grep, Glob
disallowed-tools: Bash
---

# Global Skill: Observability, SRE & Production Diagnostics (Language-Agnostic)

Esta skill estabelece diretrizes avançadas de confiabilidade (*Site Reliability Engineering - SRE*) e observabilidade distribuída para aplicações em produção. Ela orienta a instrumentação agnóstica com o padrão **OpenTelemetry**, contratos de SLO/SLI, monitoramento de saúde de contêineres e diagnóstico profundo de gargalos de desempenho e vazamentos de memória.

> [!IMPORTANT]
> ### 🛡️ Assinatura Obrigatória da Conversa (Primeira Ação)
> Toda resposta gerada sob a orientação desta skill **DEVE ser obrigatoriamente iniciada** identificando a skill em uso no topo absoluto da mensagem:
> `> 🧭 **Skill Ativa**: `_observability-sre``

---

## 1. Processo de Execução em Observabilidade & SRE

### 1.1. Os Três Pilares Integrados (OpenTelemetry)

1. **Distributed Tracing (Rastreamento Distribuído)**:
   - Toda requisição recebida na borda deve gerar ou propagar um cabeçalho padrão W3C (`traceparent`).
   - O `traceId` e `spanId` devem fluir através de chamadas HTTP, mensagens de fila (headers Kafka/RabbitMQ) e rotinas assíncronas.
2. **Structured Logging (Logs Estruturados)**:
   - Emita logs exclusivamente no formato **JSON** em `stdout`.
   - Injete automaticamente `trace_id`, `span_id`, `service.name` e `environment` em todas as entradas de log para permitir correlação instantânea em ferramentas como Grafana Loki, Datadog ou CloudWatch.
3. **Metrics (Métricas RED & USE)**:
   - Aplique o padrão **RED** para serviços de requisição: *Rate* (RPS), *Errors* (Taxa de erro 5xx), *Duration* (Latência em percentis P50, P95, P99).
   - Aplique o padrão **USE** para recursos de infraestrutura: *Utilization* (Uso de CPU/RAM), *Saturation* (Tamanho de filas de espera), *Errors* (Falhas de hardware/SO).

### 1.2. Contratos de Confiabilidade (SLI, SLO & Error Budgets)
- **SLI (Service Level Indicator)**: Métrica observável quantitativa (ex: porcentagem de requisições `POST /pagamento` que respondem em < 500ms com status 2xx).
- **SLO (Service Level Objective)**: A meta acordada com o negócio (ex: 99.9% de sucesso ao longo de 30 dias contínuos).
- **Error Budget (Orçamento de Erro)**: 100% - SLO (ex: 0.1% de margem para incidentes e deploys inovadores). Alertas devem ser disparados baseados no ritmo de consumo do orçamento (*Burn Rate Alerting*), e não em anomalias instantâneas que geram ruído.

### 1.3. Resiliência Operacional & Ciclo de Vida do Processo
- **Health Checks (Liveness vs Readiness)**:
  - `/healthz/live` (Liveness): Verifica estritamente se o processo da aplicação está vivo. **Nunca cheque o banco de dados aqui**; se o banco cair, matar a aplicação gera reinicializações em cascata desnecessárias.
  - `/healthz/ready` (Readiness): Verifica se a aplicação está pronta para receber tráfego da rede (conexão com banco e filas estabelecida).
- **Graceful Shutdown**:
  - Ao receber sinais `SIGTERM` ou `SIGINT`, pare de aceitar novas conexões HTTP, aguarde a conclusão das requisições em andamento (com timeout explícito de segurança de 15s a 30s) e feche conexões com o banco de dados antes de encerrar o processo com código 0.

---

## 2. Snippets Canônicos de Referência

### 2.1. Padrão Universal de Graceful Shutdown (Node.js / TypeScript)
```typescript
import http from 'http';

export function setupGracefulShutdown(server: http.Server, cleanupDependencies: () => Promise<void>) {
  let isShuttingDown = false;

  const handleShutdown = (signal: string) => {
    if (isShuttingDown) return;
    isShuttingDown = true;
    console.log(JSON.stringify({ level: "info", message: `Sinal ${signal} recebido. Iniciando graceful shutdown...` }));

    // 1. Para de aceitar novas requisições HTTP
    server.close(async () => {
      console.log(JSON.stringify({ level: "info", message: "Servidor HTTP fechado. Encerrando conexões com banco/filas..." }));
      try {
        await cleanupDependencies();
        console.log(JSON.stringify({ level: "info", message: "Limpeza concluída com sucesso. Processo finalizado." }));
        process.exit(0);
      } catch (err) {
        console.error(JSON.stringify({ level: "error", message: "Erro ao liberar recursos no shutdown", error: String(err) }));
        process.exit(1);
      }
    });

    // 2. Timeout forçado de segurança caso alguma requisição fique travada
    setTimeout(() => {
      console.error(JSON.stringify({ level: "error", message: "Shutdown forçado por timeout de segurança (30s)!" }));
      process.exit(1);
    }, 30000).unref();
  };

  process.on('SIGTERM', () => handleShutdown('SIGTERM'));
  process.on('SIGINT', () => handleShutdown('SIGINT'));
}
```

### 2.2. Log Estruturado Correlacionado com Trace (JSON)
```json
{
  "timestamp": "2026-09-27T17:35:00.123Z",
  "level": "error",
  "service.name": "order-service",
  "trace_id": "4bf92f3577b34da6a3ce929d0e0e4736",
  "span_id": "00f067aa0ba902b7",
  "http.method": "POST",
  "http.route": "/api/v1/orders",
  "http.status_code": 500,
  "error.kind": "DatabaseConnectionTimeout",
  "message": "Falha ao persistir pedido ord-123 devido a timeout na conexão com PostgreSQL."
}
```

---

## 3. Armadilhas Críticas em Produção (*Gotchas*)

- ⚠️ **Explosão de Cardinalidade em Métricas**: Incluir campos dinâmicos únicos (como `user_id`, `email` ou `order_id`) como tags ou labels em métricas Prometheus/Datadog. Isso consome gigabytes de RAM e gera faturas exorbitantes de monitoramento. Use apenas tags com baixa cardinalidade (`status_code`, `route`, `method`).
- ⚠️ **Liveness Probe Acoplado ao Banco de Dados**: Fazer o `/live` falhar se o banco estiver lento ou fora do ar. O Kubernetes reiniciará todos os pods ao mesmo tempo, agravando o gargalo do banco quando os pods voltarem (*Thundering Herd*).
- ⚠️ **Logs com Dados PII (Privacidade)**: Gravar números de cartões de crédito, senhas ou tokens nos logs de aplicação, violando normas de conformidade (LGPD, GDPR, PCI-DSS).

---

## 4. Padrão Rigoroso de Entrega

Ao arquitetar ou revisar observabilidade:
1. **Assinatura Obrigatória**: Iniciar a resposta com `> 🧭 **Skill Ativa**: _observability-sre`.
2. **Formato JSON**: Todos os logs orientados devem ser emitidos estruturados com suporte nativo a `traceId`.
3. **Probes Seguras**: Isole o endpoint de liveness do estado de infraestruturas externas.
4. **Integração com Tarefas**: Ao identificar lacunas de monitoramento ou ausência de graceful shutdown, pergunte ao usuário se deseja registrar essas melhorias em `TASKS.md` via `_task-management`.
