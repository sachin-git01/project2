from pathlib import Path

from sap_finsight_integration.config import PipelineConfig
from sap_finsight_integration.pipeline import run_pipeline


def test_pipeline_routes_invalid_records_to_dlq(tmp_path: Path) -> None:
    config = PipelineConfig(output_dir=tmp_path)

    result = run_pipeline(config)

    assert len(result["accepted"]) == 6
    assert len(result["rejected"]) == 2
    assert result["reconciliation"]["sourceRecordCount"] == 8
    assert result["reconciliation"]["acceptedRecordCount"] == 6
    assert result["reconciliation"]["rejectedRecordCount"] == 2
    assert (tmp_path / "finsight_gl_batch.json").exists()
    assert (tmp_path / "dlq_records.json").exists()
    assert (tmp_path / "reconciliation_report.json").exists()


def test_reconciliation_balances_valid_sample(tmp_path: Path) -> None:
    config = PipelineConfig(output_dir=tmp_path)

    result = run_pipeline(config)

    assert result["reconciliation"]["debitTotalInr"] == result["reconciliation"]["creditTotalInr"]
    assert result["reconciliation"]["netAmountInr"] == 0
    assert result["reconciliation"]["status"] == "RECONCILED"

