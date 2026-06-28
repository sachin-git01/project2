# D4 Error Handling Framework

## Strategy

The integration treats errors by class:

- Transient errors are retried with bounded backoff and jitter.
- Permanent schema, authorization, and business-rule errors stop retries and route to DLQ or business exception queues.
- Data quality errors are isolated per record so clean records continue processing.
- System errors open circuit breakers and raise operational alerts.

## Retry Policy

| Error Class | Attempts | Backoff | Final Action |
| --- | --- | --- | --- |
| SAP RFC timeout | 3 | Exponential with jitter, cap 60s | Open circuit, alert |
| SAP ODP empty delta anomaly | 1 | Fixed 30s | Alert ODP monitor |
| FinSight HTTP 429 | 5 | Honor `Retry-After` | Pause consumer partition |
| FinSight HTTP 503 | 5 | 60s linear | Open circuit |
| Token expiry | 1 | Immediate refresh | Alert security if still failing |
| Validation failure | 0 | None | DLQ or business exception |

## Circuit Breakers

| Dependency | Open Condition | Half-Open Probe | Recovery |
| --- | --- | --- | --- |
| SAP RFC | 5 failures in 2 minutes | 1 lightweight metadata call | Close after 3 successes |
| SAP OData | P95 latency over 10s and error rate over 10% | 1 paged request with limit 10 | Close after 5 successes |
| FinSight API | 429/503 above threshold for 5 minutes | 1 small batch of 10 records | Close after 3 successful batches |
| Kafka | Broker unavailable | Metadata refresh | Close after ISR restored |

## Error Code Registry

| Code | Category | Source | Description | Default Action |
| --- | --- | --- | --- | --- |
| ERR-EXT-001 | TRANSIENT | SAP RFC | RFC timeout after 30 seconds | Retry max 3 |
| ERR-EXT-002 | TRANSIENT | SAP RFC | RFC connection pool exhausted | Wait 60s, retry, alert |
| ERR-EXT-003 | PERMANENT | SAP ODP | ODP subscription invalidated | Halt domain extraction |
| ERR-EXT-004 | TRANSIENT | SAP ODP | Empty delta despite known changes | Retry once, check ODP monitor |
| ERR-MAP-001 | DATA_QUALITY | Transformation | Mandatory source field is NULL | Default if configured else DLQ |
| ERR-MAP-002 | DATA_QUALITY | Transformation | Invalid date format | Attempt correction else DLQ |
| ERR-MAP-003 | DATA_QUALITY | Transformation | Cost centre not found | Business exception queue |
| ERR-MAP-004 | DATA_QUALITY | Transformation | Invalid currency code | Correct common typo else DLQ |
| ERR-MAP-005 | DATA_QUALITY | Transformation | Exchange rate missing | Nearest rate with stale flag |
| ERR-MAP-006 | PERMANENT | Transformation | Rule execution error | DLQ and engineering alert |
| ERR-LOAD-001 | TRANSIENT | FinSight API | HTTP 429 rate limited | Honor Retry-After |
| ERR-LOAD-002 | TRANSIENT | FinSight API | HTTP 503 unavailable | Linear backoff max 5 |
| ERR-LOAD-003 | PERMANENT | FinSight API | HTTP 422 business violation | Business exception queue |
| ERR-LOAD-004 | PERMANENT | FinSight API | HTTP 409 duplicate | Compare payload hashes |
| ERR-LOAD-005 | PERMANENT | FinSight API | HTTP 401 authentication | Refresh token once then alert |
| ERR-RECON-001 | DATA_QUALITY | Reconciliation | Record count mismatch | Break report |
| ERR-RECON-002 | DATA_QUALITY | Reconciliation | Checksum variance exceeds tolerance | Escalate to data steward |
| ERR-RECON-003 | DATA_QUALITY | Reconciliation | Referential integrity violation | Trigger master data resync |
| ERR-SYS-001 | SYSTEM | Infrastructure | Kafka broker unreachable | Circuit breaker and P1 alert |
| ERR-SYS-002 | SYSTEM | Infrastructure | Disk below 10% | Archive logs and expand disk |

## DLQ Payload

```json
{
  "dlqId": "DLQ-GL-20260628-0001",
  "batchId": "BATCH-GL-20260628-0930",
  "domain": "GL",
  "sourceSystem": "SAP_S4HANA",
  "sourceKey": "1000:5100001234:2026:001",
  "errorCode": "ERR-MAP-003",
  "errorMessage": "Referenced cost centre CC-9001 not found",
  "payloadHash": "sha256:...",
  "firstFailedAt": "2026-06-28T09:31:15+05:30",
  "retryable": false,
  "ownerQueue": "FINANCE_MASTER_DATA"
}
```

