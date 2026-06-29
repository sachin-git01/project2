import tempfile
import unittest
from pathlib import Path

from sap_finsight_integration.config import PipelineConfig
from sap_finsight_integration.pipeline import run_pipeline


class PipelineTestCase(unittest.TestCase):
    def test_pipeline_routes_invalid_records_to_dlq(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            config = PipelineConfig(output_dir=Path(directory))
            result = run_pipeline(config)

            self.assertEqual(len(result["accepted"]), 6)
            self.assertEqual(len(result["rejected"]), 2)
            self.assertEqual(result["reconciliation"]["sourceRecordCount"], 8)
            self.assertEqual(result["reconciliation"]["acceptedRecordCount"], 6)
            self.assertEqual(result["reconciliation"]["rejectedRecordCount"], 2)
            self.assertTrue((Path(directory) / "finsight_gl_batch.json").exists())
            self.assertTrue((Path(directory) / "dlq_records.json").exists())
            self.assertTrue((Path(directory) / "reconciliation_report.json").exists())

    def test_reconciliation_balances_valid_sample(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            config = PipelineConfig(output_dir=Path(directory))
            result = run_pipeline(config)

            self.assertEqual(result["reconciliation"]["debitTotalInr"], result["reconciliation"]["creditTotalInr"])
            self.assertEqual(result["reconciliation"]["netAmountInr"], 0)
            self.assertEqual(result["reconciliation"]["status"], "RECONCILED")


if __name__ == "__main__":
    unittest.main()

