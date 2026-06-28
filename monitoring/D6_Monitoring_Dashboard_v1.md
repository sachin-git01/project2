# D6 Monitoring Dashboard Specification

## Observability Model

The integration emits metrics, structured logs, and traces. Every event includes `correlationId`, `batchId`, `domain`, `companyCode`, `sourceSystem`, and `component`.

## Dashboard Panels

| Panel ID | Title | Metric Query | Refresh | Alert |
| --- | --- | --- | --- | --- |
| MON-001 | Pipeline Health Overview | Status aggregation by domain | 30s | RED triggers P1 |
| MON-002 | Throughput Records/Sec | `rate(records_processed_total[5m]) by (domain,operation)` | 15s | Under 50% baseline |
| MON-003 | Latency Distribution | `histogram_quantile(0.95, rate(api_duration_seconds_bucket[5m]))` | 15s | P95 over 5s |
| MON-004 | Error Rate | `rate(errors_total[5m]) / rate(requests_total[5m]) * 100` | 15s | Over 5% P1 |
| MON-005 | DLQ Depth | `kafka_consumer_group_lag{topic="dlq"}` | 30s | Over 500 P1 |
| MON-006 | Reconciliation Status | Last result per domain | 5m | BREAK triggers P2 |
| MON-007 | SAP System Health | `sap_rfc_pool_utilisation`, `sap_response_time_ms` | 30s | Pool over 90% |
| MON-008 | FinSight API Health | `finsight_api_response_ms`, `finsight_rate_limit_remaining` | 30s | Headroom under 10% |
| MON-009 | Data Freshness | `now() - max(last_successful_load_timestamp)` | 60s | Exceeds SLA |
| MON-010 | Resource Utilisation | CPU, memory, disk, network | 15s | Any over 90% |
| MON-011 | Kafka Consumer Lag | `kafka_consumer_group_lag by (topic,partition)` | 15s | Over 50K messages |
| MON-012 | Circuit Breaker Status | `circuit_breaker_state{service}` | 5s | Any open triggers P2 |

## Alert Routing

| Severity | Trigger | Owner | Response |
| --- | --- | --- | --- |
| P1 | Data loss risk, full pipeline down, reconciliation systemic break | On-call integration lead | 15 minutes |
| P2 | Domain outage, circuit breaker open, large DLQ | L2 integration team | 1 hour |
| P3 | Freshness breach, warning threshold | Operations | 4 hours |
| P4 | Informational anomaly | Backlog review | Next business day |

## Structured Log Example

```json
{
  "timestamp": "2026-06-28T09:31:15+05:30",
  "level": "WARN",
  "component": "validation-service",
  "domain": "AP",
  "batchId": "BATCH-AP-20260628-0930",
  "correlationId": "corr-20260628-0930-001",
  "sourceKey": "1000:1900001234:2026:001",
  "errorCode": "ERR-MAP-003",
  "message": "Vendor master reference missing"
}
```

