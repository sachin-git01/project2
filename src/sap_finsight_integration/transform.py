from datetime import datetime
from hashlib import sha256
from typing import Any

from .config import (
    EXCHANGE_RATES_TO_INR,
    KNOWN_COST_CENTRES,
    KNOWN_PROFIT_CENTRES,
    SUPPORTED_CURRENCIES,
    PipelineConfig,
)


def _parse_sap_date(value: str) -> str:
    return datetime.strptime(value, "%Y%m%d").date().isoformat()


def _decimal(value: str) -> float:
    return round(float(value), 2)


def _source_key(row: dict[str, str]) -> str:
    return ":".join(
        [
            row["company_code"],
            row["document_number"],
            row["fiscal_year"],
            row["line_item"].zfill(3),
        ]
    )


def validate_source(row: dict[str, str]) -> list[dict[str, str]]:
    errors: list[dict[str, str]] = []

    required = ["company_code", "fiscal_year", "document_number", "line_item", "gl_account", "posting_date", "currency", "amount", "debit_credit"]
    for field in required:
        if not row.get(field):
            errors.append({"errorCode": "ERR-MAP-001", "field": field, "message": "Required field is missing"})

    if row.get("currency") and row["currency"] not in SUPPORTED_CURRENCIES:
        errors.append({"errorCode": "ERR-MAP-004", "field": "currency", "message": "Unsupported currency"})

    if row.get("cost_centre") and row["cost_centre"] not in KNOWN_COST_CENTRES:
        errors.append({"errorCode": "ERR-MAP-003", "field": "cost_centre", "message": "Unknown cost centre"})

    if row.get("profit_centre") and row["profit_centre"] not in KNOWN_PROFIT_CENTRES:
        errors.append({"errorCode": "ERR-MAP-003", "field": "profit_centre", "message": "Unknown profit centre"})

    try:
        if row.get("posting_date"):
            _parse_sap_date(row["posting_date"])
    except ValueError:
        errors.append({"errorCode": "ERR-MAP-002", "field": "posting_date", "message": "Invalid SAP date"})

    try:
        if row.get("amount"):
            _decimal(row["amount"])
    except ValueError:
        errors.append({"errorCode": "ERR-MAP-006", "field": "amount", "message": "Amount is not numeric"})

    if row.get("debit_credit") not in {"S", "H"}:
        errors.append({"errorCode": "ERR-MAP-001", "field": "debit_credit", "message": "Expected S or H"})

    return errors


def transform_row(row: dict[str, str], config: PipelineConfig) -> dict[str, Any]:
    currency = row["currency"]
    amount_transaction = _decimal(row["amount"])
    amount_inr = round(amount_transaction * EXCHANGE_RATES_TO_INR[currency], 2)
    source_key = _source_key(row)

    return {
        "sourceBusinessKey": source_key,
        "idempotencyKey": sha256(f"{config.tenant_id}:{config.domain}:{source_key}".encode("utf-8")).hexdigest(),
        "tenantId": config.tenant_id,
        "companyCode": row["company_code"],
        "fiscalYear": row["fiscal_year"],
        "fiscalPeriod": row["fiscal_period"],
        "specialPeriod": row["fiscal_period"] in {"013", "014", "015", "016"},
        "sourceDocument": row["document_number"],
        "lineItem": row["line_item"].zfill(3),
        "postingDate": _parse_sap_date(row["posting_date"]),
        "glAccount": row["gl_account"],
        "costCentre": row.get("cost_centre") or None,
        "profitCentre": row.get("profit_centre") or None,
        "currency": currency,
        "amountInTransactionCurrency": amount_transaction,
        "amountInFunctionalCurrency": amount_inr,
        "debitCredit": "DEBIT" if row["debit_credit"] == "S" else "CREDIT",
        "lineage": {
            "sourceSystem": "SAP_S4HANA",
            "sourceTable": "ACDOCA",
            "sourceDocument": row["document_number"],
            "batchId": config.batch_id,
        },
    }


def transform_batch(rows: list[dict[str, str]], config: PipelineConfig) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    accepted: list[dict[str, Any]] = []
    rejected: list[dict[str, Any]] = []

    for row in rows:
        errors = validate_source(row)
        if errors:
            rejected.append(
                {
                    "batchId": config.batch_id,
                    "domain": config.domain,
                    "sourceKey": _source_key(row) if row.get("company_code") and row.get("document_number") and row.get("fiscal_year") and row.get("line_item") else "UNKNOWN",
                    "errors": errors,
                    "sourcePayload": row,
                }
            )
        else:
            accepted.append(transform_row(row, config))

    return accepted, rejected

