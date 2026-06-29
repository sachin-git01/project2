from hashlib import sha256
from typing import Any

from .config import PipelineConfig


def _signed_amount(record: dict[str, Any]) -> float:
    amount = float(record["amountInFunctionalCurrency"])
    return amount if record["debitCredit"] == "DEBIT" else -amount


def reconcile(source_rows: list[dict[str, str]], accepted: list[dict[str, Any]], rejected: list[dict[str, Any]], config: PipelineConfig) -> dict[str, Any]:
    source_count = len(source_rows)
    accepted_count = len(accepted)
    rejected_count = len(rejected)
    debit_total = round(sum(r["amountInFunctionalCurrency"] for r in accepted if r["debitCredit"] == "DEBIT"), 2)
    credit_total = round(sum(r["amountInFunctionalCurrency"] for r in accepted if r["debitCredit"] == "CREDIT"), 2)
    net_amount = round(sum(_signed_amount(r) for r in accepted), 2)
    checksum_input = "|".join(sorted(f"{r['sourceBusinessKey']}:{r['amountInFunctionalCurrency']}:{r['debitCredit']}" for r in accepted))

    status = "RECONCILED"
    if source_count != accepted_count + rejected_count:
        status = "RECON_BREAK"
    elif abs(net_amount) > 0.01:
        status = "RECON_WARNING_UNBALANCED_SAMPLE"

    return {
        "batchId": config.batch_id,
        "domain": config.domain,
        "sourceRecordCount": source_count,
        "acceptedRecordCount": accepted_count,
        "rejectedRecordCount": rejected_count,
        "debitTotalInr": debit_total,
        "creditTotalInr": credit_total,
        "netAmountInr": net_amount,
        "checksum": sha256(checksum_input.encode("utf-8")).hexdigest(),
        "status": status,
    }

