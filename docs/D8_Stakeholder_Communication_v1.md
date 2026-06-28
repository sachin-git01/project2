# D8 Stakeholder Communication

## CFO Executive Summary

Meridian Manufacturing currently depends on delayed SAP extracts for financial analytics, which slows decisions around cash, payables, receivables, inventory, and budget control. The proposed SAP-to-FinSight integration creates an automated, monitored, and reconciled data flow so finance users can trust fresher dashboards without manually moving files.

### Value

| Benefit | Impact |
| --- | --- |
| Data freshness | Improves from about 24 hours to a 4-hour standard SLA |
| Manual effort | Reduces repeated export, cleansing, and reconciliation work |
| Audit confidence | Every FinSight figure links back to SAP source documents |
| Risk reduction | Failures are isolated through DLQ, alerts, and automated reconciliation |

### Top Risks

| Risk | Business Impact | Mitigation |
| --- | --- | --- |
| SAP extraction slows production | Finance and operations disruption | Controlled extraction windows and SAP Basis approval |
| Data mismatch after transformation | Loss of trust in dashboards | Batch reconciliation and variance reports |
| Master data quality issues | Incorrect cost centre or vendor reporting | Business exception queue and master data remediation |

### CFO Ask

Approve the 15-day design and prototype phase, nominate finance data owners for reconciliation sign-off, and confirm the target freshness SLA by domain.

## Client IT Handoff

### SAP Changes

- ODP subscriptions for GL, AP, AR, inventory, material ledger, and budget domains.
- OData/CDS exposure for master data and document flows.
- RFC destination for controlled metadata and health checks.
- IDoc partner profile for bank statement events where applicable.

### Network

| Flow | Protocol | Direction |
| --- | --- | --- |
| Integration runtime to SAP Gateway | HTTPS 443 | Inbound to SAP network |
| Integration runtime to SAP RFC | RFC/SNC approved port | Inbound to SAP network |
| Integration runtime to FinSight | HTTPS 443 | Outbound/private endpoint |
| Monitoring export | HTTPS 443 | Outbound to monitoring |

### Security

- Service account restricted to approved CDS views, OData services, and RFC function groups.
- No direct database reads.
- Secrets stored in managed vault.
- TLS 1.2+ required.
- All financial data processed in India-region infrastructure.

### Support Model

| Level | Owner | Scope |
| --- | --- | --- |
| L1 | Operations | Dashboard alerts, restart runbooks, known retry actions |
| L2 | Integration Team | Mapping errors, DLQ review, batch replay |
| L3 | SAP/Platform Engineering | ODP provider changes, API contract changes, infrastructure incidents |

## Platform Engineering Design Review

### API Contract

FinSight receives canonical batch upsert payloads with idempotency keys, batch metadata, and source lineage. Error responses follow a common envelope with `errorCode`, `message`, `correlationId`, and structured details.

### Authentication Flow

1. Loader requests OAuth token using client credentials.
2. FinSight identity endpoint returns scoped access token.
3. Loader sends batch request with bearer token and idempotency key.
4. Loader refreshes token before expiry or after one 401 response.

### Throughput Expectations

| Domain | Average | Peak |
| --- | --- | --- |
| GL | 10,000 records/hour | 500,000 records/batch |
| AP/AR | 3,000 records/hour | 75,000 records/batch |
| Inventory | 8,000 records/hour | 150,000 records/batch |
| Master data | 500 records/hour | 25,000 records/full refresh |

### Engineering Support Requests

- Confirm maximum accepted batch size per endpoint.
- Confirm idempotency retention window.
- Confirm rate-limit quota for month-end close.
- Confirm webhook support for asynchronous ingestion status.

