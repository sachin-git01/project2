# D5 Reconciliation Specification

## Objective

Reconciliation proves that the records accepted by FinSight match the SAP source extract after transformation. It is mandatory for financial confidence, audit evidence, and operational sign-off.

## Reconciliation Levels

| Level | Check | Example |
| --- | --- | --- |
| Batch | Source count equals loaded plus rejected count | SAP 6,240 = FinSight 6,236 + DLQ 4 |
| Amount | Debit and credit totals match within tolerance | INR debit total equals credit total |
| Checksum | Stable hash of source business keys and normalized amounts | SHA-256 per batch |
| Referential | Foreign keys resolve to loaded master data | Cost centre exists |
| Lineage | Every target record links to source document and batch | SAP BELNR to FinSight ID |

## Batch Report Fields

| Field | Example |
| --- | --- |
| Batch ID | BATCH-GL-20260628-0930 |
| Extraction Timestamp | 2026-06-28T09:30:00+05:30 |
| Load Completion Timestamp | 2026-06-28T09:32:45+05:30 |
| Domain | General Ledger |
| Company Code | 1000 |
| Source Record Count | 6240 |
| Target Accepted Count | 6236 |
| DLQ Count | 4 |
| Source Debit Total | 125000000.00 INR |
| Source Credit Total | 125000000.00 INR |
| Target Debit Total | 125000000.00 INR |
| Target Credit Total | 125000000.00 INR |
| Status | RECONCILED_WITH_REJECTIONS |

## Tolerances

| Check | Tolerance |
| --- | --- |
| Record count | Exact, after accounting for DLQ/business exceptions |
| Functional currency totals | INR 0.00 for GL, INR 1.00 for analytical summaries |
| Foreign currency conversion | INR 0.50 due to rounding |
| Debit-credit balance | INR 0.00 |
| Checksum | Exact |

## Break Workflow

1. Reconciliation detects variance.
2. Break report is generated with source keys, target keys, amount variance, and probable cause.
3. Alert is routed to operations for technical breaks or finance data steward for business breaks.
4. Affected batch is marked `RECON_BREAK`.
5. Reprocessing is blocked for target overwrite until owner approves action.
6. Audit trail records resolution, approver, timestamp, and final status.

## Sample Reconciliation SQL Logic

```sql
select
  batch_id,
  company_code,
  count(*) as record_count,
  sum(debit_amount_inr) as debit_total,
  sum(credit_amount_inr) as credit_total,
  sha256(string_agg(source_business_key || normalized_amount_inr, '|' order by source_business_key)) as batch_checksum
from canonical_journal_entries
where batch_id = :batch_id
group by batch_id, company_code;
```

