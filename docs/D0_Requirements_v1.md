# D0 Requirements and Discovery

## Client Context

Meridian Manufacturing runs SAP S/4HANA as its system of record for finance, procurement, inventory, sales, and controlling. Finance leadership needs fresher analytics in FinSight without compromising SAP stability, accounting correctness, or auditability.

## Business Objectives

| ID | Objective | Success Measure |
| --- | --- | --- |
| BO-001 | Improve finance data freshness | Standard domains available in FinSight within 4 hours |
| BO-002 | Reduce manual reconciliation | Automated source-target reconciliation after each batch |
| BO-003 | Provide CFO visibility | GL, AP, AR, budget, cash, and working capital metrics available in dashboards |
| BO-004 | Preserve financial audit trail | Every FinSight record traceable to SAP source document and extraction batch |
| BO-005 | Support India compliance | GST, TDS, fiscal year, and data residency constraints represented in design |

## Source Domains

| Domain | SAP Source | Interface | Frequency |
| --- | --- | --- | --- |
| General Ledger | ACDOCA, BKPF | ODP/CDS | 30 min delta |
| Accounts Payable | ACDOCA, LFA1, BSIK/BSAK compatibility views | ODP/CDS | 2 hour delta |
| Accounts Receivable | ACDOCA, KNA1, BSID/BSAD compatibility views | ODP/CDS | 2 hour delta |
| Cost Centre | CSKS, CSKT, SETNODE | CDS | Daily plus on-change |
| Profit Centre | CEPC, CEPCT | CDS | Daily plus on-change |
| Material Ledger | MLDOC, CKMLCR | CDS | 4 hour delta |
| Purchase Orders | EKKO, EKPO, EKBE | OData/CDS | 2 hour delta |
| Sales Orders | VBAK, VBAP, VBFA | OData/CDS | 2 hour delta |
| Fixed Assets | ANLA, ANLC, ACDOCA | CDS | Daily |
| Bank Statements | FEBKO, FEBEP | IDoc/CDS | 1 hour |
| Budget vs Actual | ACDOCA, ACDOCP | CDS | 4 hour delta |
| Inventory | MATDOC, MARA, MARD | ODP/CDS | 2 hour delta |

## Functional Requirements

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-001 | Extract initial full loads and subsequent deltas from SAP | Must |
| FR-002 | Transform SAP-specific structures into FinSight canonical schemas | Must |
| FR-003 | Validate mandatory fields, referential integrity, dates, currencies, and GST fields | Must |
| FR-004 | Load transformed data into FinSight with idempotency keys | Must |
| FR-005 | Reconcile record counts, debit/credit totals, checksums, and source-target keys | Must |
| FR-006 | Route invalid records to DLQ with actionable error codes | Must |
| FR-007 | Provide dashboards and alerts for operations and finance stakeholders | Must |
| FR-008 | Support reprocessing from Kafka and DLQ | Should |
| FR-009 | Generate stakeholder-specific reports for CFO, SAP Basis, and platform engineering | Should |

## Non-Functional Requirements

| Category | Requirement |
| --- | --- |
| Performance | Process 500,000 GL records within 2 hours during peak loads |
| Scalability | Scale transformation workers horizontally by Kafka consumer group |
| Availability | 99.5% monthly pipeline availability |
| Security | OAuth 2.0 for FinSight, SAP service accounts with least privilege, TLS 1.2+ |
| Compliance | Financial data remains in India region; audit logs retained for 7 years |
| Observability | Metrics, logs, and traces include correlation IDs and batch IDs |
| Maintainability | Versioned OpenAPI contracts and versioned mapping rules |

## Stakeholders

| Stakeholder | Concern | Communication Output |
| --- | --- | --- |
| CFO | Timely, reliable finance visibility | Executive summary and risk view |
| Controller | Reconciliation and audit evidence | Reconciliation reports |
| SAP Basis Admin | Production impact and RFC pool use | Technical handoff |
| Security Lead | Access, encryption, residency | Security controls matrix |
| Platform Engineer | API contracts and rate limits | API design review |
| Operations Team | Monitoring and incident response | Runbook and dashboard |

