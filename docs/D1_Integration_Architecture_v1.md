# D1 Integration Architecture

## Executive Architecture

The solution follows an event-driven integration pattern. SAP remains the system of record. The integration layer extracts data using delta-safe methods, normalizes messages through Kafka topics, applies domain-specific transformation and validation, loads FinSight using idempotent APIs, and reconciles each batch.

## C4 Level 1: System Context

See `diagrams/DGM_C4_SystemContext.mmd`.

Actors and systems:

- Finance users consume FinSight dashboards.
- SAP S/4HANA provides financial and operational data.
- Integration services move, transform, validate, and reconcile data.
- FinSight stores analytical records and exposes dashboards.
- Identity provider issues OAuth tokens for FinSight and controls admin access.
- Monitoring stack reports health and alerts operations.

## C4 Level 2: Containers

| Container | Responsibility |
| --- | --- |
| Scheduler | Triggers full loads, deltas, retries, and reconciliation jobs |
| SAP Connector | Reads ODP/CDS/OData/RFC/IDoc sources and manages delta tokens |
| Kafka | Buffers domain events, supports replay, and isolates SAP from FinSight outages |
| Transformation Engine | Converts SAP records to FinSight canonical schemas |
| Validation Service | Applies quality rules, referential checks, and compliance checks |
| FinSight Loader | Sends idempotent batch loads with retry and rate-limit handling |
| Reconciliation Service | Compares source and target counts, totals, checksums, and keys |
| DLQ Service | Stores failed records for review and controlled reprocessing |
| Monitoring Stack | Publishes metrics, logs, traces, alerts, and audit lineage |

## C4 Level 3: Component View

| Component | Key Functions |
| --- | --- |
| Delta Token Manager | Stores last successful ODP token per domain and company code |
| Extraction Adapter Registry | Selects CDS, OData, RFC, or IDoc adapter per domain |
| Schema Registry | Maintains source and canonical schema versions |
| Mapping Rule Engine | Executes versioned transformation rules |
| Reference Data Cache | Holds company code, currency, vendor, customer, cost centre, and profit centre lookups |
| Idempotency Key Builder | Builds deterministic keys such as `tenant:domain:sourceDoc:lineItem:fiscalYear` |
| Retry Coordinator | Applies exponential backoff, jitter, and retry budgets |
| Circuit Breaker | Opens on repeated SAP or FinSight failures |
| Audit Writer | Writes immutable lineage events for every batch and record outcome |

## Data Flow

1. Scheduler requests a delta extraction for a domain and company code.
2. SAP Connector reads data from CDS/ODP using the last committed delta token.
3. Extracted messages are written to domain Kafka topics.
4. Transformation Engine converts source records to canonical FinSight payloads.
5. Validation Service enriches and validates data.
6. Valid records are loaded to FinSight with idempotency keys.
7. Invalid records are routed to DLQ with error code, source payload, and remediation hint.
8. Reconciliation Service compares SAP source metrics with FinSight load metrics.
9. Monitoring Stack emits status, alerts, and audit lineage.
10. Delta token is committed only after successful durable publish and batch registration.

## Technology Stack

| Layer | Selected | Rationale | Alternative Considered |
| --- | --- | --- | --- |
| Source extraction | SAP ODP/CDS/OData/RFC/IDoc | Native SAP patterns and delta support | Direct DB access rejected due to support and security risk |
| Messaging | Apache Kafka | Replay, buffering, partitioning, consumer groups | Point-to-point APIs rejected due to outage coupling |
| Transformation | Python/Java service with rule engine | Easy rule versioning and scale-out | ETL-only tool rejected for lower code control |
| API gateway | Managed gateway | Rate limiting, auth, logging | Direct service exposure rejected |
| Monitoring | Prometheus, Grafana, OpenTelemetry, Loki/ELK | Standard observability stack | Only application logs rejected |
| Storage | India-region object storage and relational metadata DB | Audit evidence and batch state | Local disk rejected |

## Network Architecture

SAP is assumed to run on-premise or in a private client network. The integration runtime connects through a site-to-site VPN or private link into an India-region cloud VPC. Only approved ports are opened for SAP Gateway/OData, RFC, and monitoring export. FinSight APIs are accessed through a private endpoint where available.

## Security Design

- SAP service accounts use least-privilege authorizations for RFC, OData, and CDS views.
- FinSight uses OAuth 2.0 client credentials with scoped tokens.
- All traffic uses TLS 1.2 or higher.
- Kafka, DLQ, object storage, and metadata DB are encrypted at rest.
- Secrets are stored in a managed secret store and rotated every 90 days.
- Audit logs include user/service identity, batch ID, source document, target ID, action, and timestamp.

## Risk Register

| ID | Risk | Probability | Impact | Mitigation |
| --- | --- | --- | --- | --- |
| R-001 | SAP performance degradation during extraction | Medium | High | Package size limits, off-peak full loads, Basis review |
| R-002 | ODP provider schema changes | Medium | High | Schema registry, contract tests, alert and graceful degradation |
| R-003 | FinSight API rate limiting | High | Medium | Adaptive throttling, Retry-After compliance, queue buffering |
| R-004 | Invalid master data references | Medium | High | Preload master data, referential checks, business exception queue |
| R-005 | Currency conversion errors | Medium | High | TCURR point-in-time rates, stale-rate flag, reconciliation |
| R-006 | Duplicate loads after retry | Medium | High | Idempotency keys and payload hash comparison |
| R-007 | Network partition | Medium | Medium | Kafka buffering, circuit breaker, replay |
| R-008 | GST/TDS fields transformed incorrectly | Low | High | Tax-specific validation and field-level audit |
| R-009 | DLQ grows beyond operations capacity | Medium | Medium | DLQ thresholds, owner assignment, reprocessing workflow |
| R-010 | Poor stakeholder adoption | Medium | Medium | CFO summary, IT handoff, training, dashboard sign-off |

