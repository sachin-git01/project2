# D7 Integration Test Plan

## Functional Tests

| ID | Title | Preconditions | Steps | Expected Result |
| --- | --- | --- | --- | --- |
| TST-FNC-001 | Happy Path GL Extraction | 100 GL entries in SAP sandbox | Trigger delta, verify Kafka count, load FinSight, reconcile | 100 records loaded, checksum match |
| TST-FNC-002 | AP Open Items Multi-Currency | INR, USD, EUR AP items and TCURR rates | Extract AP, convert currency, check ageing | Correct INR conversion and ageing |
| TST-FNC-003 | Master Data Delta Sync | Existing cost centre sync | Create cost centre, run cycle, query target | New cost centre appears |
| TST-FNC-004 | Multi-Company Code Batch | Entries for MC01, MC02, MC03 | Extract mixed batch, verify routing | Each company routes to correct tenant |
| TST-FNC-005 | Fiscal Period Mapping | SAP periods 001-016 | Extract all periods, verify mapping | 013-016 flagged as special periods |
| TST-FNC-006 | 7-Level Hierarchy Flatten | Cost centre hierarchy exists | Extract hierarchy and inspect target | Level1-Level7 populated |
| TST-FNC-007 | P2P Flow Tracing | PO, GR, invoice, payment exist | Extract stages and trace flow | All stages linked |
| TST-FNC-008 | Bank Statement Load | 50 bank items | Load IDoc/CDS, transform, validate clearing | Matched cleared, unmatched open |
| TST-FNC-009 | Budget vs Actual Variance | Budget and actuals for 5 centres | Extract both and calculate variance | Matches SAP CO report |
| TST-FNC-010 | End-of-Day Full Reconciliation | Full day across domains | Run all extractions and recon | Zero unexplained breaks |

## Non-Functional Tests

| ID | Category | Title | Key Validation |
| --- | --- | --- | --- |
| TST-NFR-001 | Performance | Peak 500K GL entries | Completes within 2-hour SLA |
| TST-NFR-002 | Concurrency | 12 domains run together | No deadlocks or resource contention |
| TST-NFR-003 | Latency | 500 concurrent FinSight requests | P95 under 5 seconds, controlled 429 |
| TST-NFR-004 | Scalability | 1K to 100K records | Linear throughput until documented ceiling |
| TST-NFR-005 | Endurance | 24-hour operation | No memory leak or connection exhaustion |

## Failure Tests

| ID | Category | Title | Key Validation |
| --- | --- | --- | --- |
| TST-FLR-001 | Failure | SAP RFC failure mid-batch | Circuit opens, partial batch preserved |
| TST-FLR-002 | Failure | FinSight HTTP 429 | Honors Retry-After and succeeds eventually |
| TST-FLR-003 | Failure | Kafka broker failure | Failover with zero message loss |
| TST-FLR-004 | Failure | 10 malformed records in 100 | 90 succeed, 10 DLQ |
| TST-FLR-005 | Failure | 5-minute network partition | Buffers and recovers with eventual consistency |

## Security and Reconciliation Tests

| ID | Category | Title | Key Validation |
| --- | --- | --- | --- |
| TST-SEC-001 | Security | OAuth token expires | Automatic refresh without data loss |
| TST-SEC-002 | Security | Invalid token | HTTP 401, audit log, no data exposure |
| TST-SEC-003 | Security | Encryption verification | TLS 1.2+ in transit, AES-256 at rest |
| TST-REC-001 | Reconciliation | INR 1.50 discrepancy | Break detected and alert generated |
| TST-REC-002 | Reconciliation | Missing cost centre | Referential check catches orphan |

## Exit Criteria

- All functional tests pass.
- No P1 or P2 unresolved defects.
- Performance test meets 500K GL records within 2 hours.
- Security tests produce audit evidence.
- Reconciliation breaks are either resolved or documented with owner approval.

