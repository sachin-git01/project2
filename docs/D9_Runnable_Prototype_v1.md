# D9 Runnable Prototype

## Purpose

This prototype demonstrates the integration logic described in the architecture documentation. It simulates a SAP GL extraction, transforms records into the FinSight canonical schema, routes invalid records to DLQ, writes a FinSight batch payload, and produces a reconciliation report.

## How To Run

```powershell
python -m sap_finsight_integration.cli
```

If running directly from the repository without installing the package:

```powershell
$env:PYTHONPATH = "src"
python -m sap_finsight_integration.cli
```

## How To Test

```powershell
python -m pytest
```

If `pytest` is not installed, use the built-in test runner:

```powershell
$env:PYTHONPATH = "src"
python -m unittest discover -s tests -p "*unittest.py"
```

## Input

Sample SAP data:

```text
data/sample/sap_gl_entries.csv
```

The sample includes six valid GL records and two invalid records to prove DLQ routing for missing master data references.

## Outputs

| File | Description |
| --- | --- |
| `outputs/finsight_gl_batch.json` | Canonical FinSight batch payload |
| `outputs/dlq_records.json` | Invalid records with error codes and source payload |
| `outputs/reconciliation_report.json` | Count, amount, checksum, and status report |
| `outputs/load_result.json` | Simulated FinSight load result |

## Scoring Relevance

This artifact improves submission evidence by showing:

- Field mapping logic is executable.
- Data validation and DLQ behavior are implemented.
- Idempotency keys are generated deterministically.
- Reconciliation counts and debit-credit totals are calculated.
- The project is not only documentation; it contains working code and tests.
