# D2 API Specification

## Scope

The API design covers two sides of the integration:

- SAP source extraction APIs exposed through a controlled integration facade.
- FinSight destination ingestion APIs that receive canonical financial payloads.

OpenAPI files:

- `api/API_SAP_Source.yaml`
- `api/API_FinSight_Destination.yaml`

## Source Endpoints

| ID | Endpoint | Domain | Extraction |
| --- | --- | --- | --- |
| SRC-001 | `/sap/v1/general-ledger/journal-entries` | General Ledger | ODP delta |
| SRC-002 | `/sap/v1/accounts-payable/open-items` | Accounts Payable | ODP delta |
| SRC-003 | `/sap/v1/accounts-receivable/open-items` | Accounts Receivable | ODP delta |
| SRC-004 | `/sap/v1/master-data/cost-centres` | Cost Centre | CDS/OData |
| SRC-005 | `/sap/v1/master-data/profit-centres` | Profit Centre | CDS/OData |
| SRC-006 | `/sap/v1/material-ledger/movements` | Material Ledger | CDS delta |
| SRC-007 | `/sap/v1/procurement/purchase-orders` | Purchase Orders | OData/CDS |
| SRC-008 | `/sap/v1/sales/sales-orders` | Sales Orders | OData/CDS |
| SRC-009 | `/sap/v1/fixed-assets/assets` | Fixed Assets | CDS |
| SRC-010 | `/sap/v1/cash/bank-statements` | Bank Statements | IDoc/CDS |
| SRC-011 | `/sap/v1/controlling/budget-actuals` | Budget vs Actual | CDS |
| SRC-012 | `/sap/v1/inventory/stock-movements` | Inventory | ODP/CDS |

## Destination Endpoints

| ID | Endpoint | Domain |
| --- | --- | --- |
| DST-001 | `/finsight/v1/journal-entries:batchUpsert` | General Ledger |
| DST-002 | `/finsight/v1/payables:batchUpsert` | Accounts Payable |
| DST-003 | `/finsight/v1/receivables:batchUpsert` | Accounts Receivable |
| DST-004 | `/finsight/v1/cost-centres:batchUpsert` | Cost Centre |
| DST-005 | `/finsight/v1/profit-centres:batchUpsert` | Profit Centre |
| DST-006 | `/finsight/v1/material-movements:batchUpsert` | Material Ledger |
| DST-007 | `/finsight/v1/purchase-orders:batchUpsert` | Purchase Orders |
| DST-008 | `/finsight/v1/sales-orders:batchUpsert` | Sales Orders |
| DST-009 | `/finsight/v1/fixed-assets:batchUpsert` | Fixed Assets |
| DST-010 | `/finsight/v1/bank-statements:batchUpsert` | Bank Statements |
| DST-011 | `/finsight/v1/budget-actuals:batchUpsert` | Budget vs Actual |
| DST-012 | `/finsight/v1/inventory:batchUpsert` | Inventory |

## Authentication

SAP extraction uses a technical service account with SAP Gateway/OData and RFC authorization objects. FinSight uses OAuth 2.0 client credentials. Tokens are cached by the loader and refreshed before expiry. Expired tokens are retried once after refresh.

## Idempotency

All FinSight write requests require an `Idempotency-Key` header. The key is deterministic and includes tenant, domain, SAP document number, fiscal year, company code, and line item where applicable.

## Pagination and Delta Strategy

Source endpoints support cursor-based pagination using `cursor` and `limit`. Delta extraction uses `deltaToken` and returns `nextDeltaToken`. The integration commits a delta token only after messages are durably published and batch metadata is recorded.

## Rate Limiting

FinSight responses include:

- `X-RateLimit-Limit`
- `X-RateLimit-Remaining`
- `X-RateLimit-Reset`
- `Retry-After` on HTTP 429

The loader honors `Retry-After`, uses exponential backoff with jitter, and slows consumer polling when remaining quota falls below 10%.

## Error Response

All APIs use a shared error envelope:

```json
{
  "errorCode": "ERR-LOAD-001",
  "message": "Rate limit exceeded",
  "correlationId": "corr-20260628-001",
  "details": {
    "domain": "GL",
    "batchId": "BATCH-GL-20260628-0930"
  }
}
```

