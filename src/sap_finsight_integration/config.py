from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class PipelineConfig:
    source_file: Path = Path("data/sample/sap_gl_entries.csv")
    output_dir: Path = Path("outputs")
    batch_id: str = "BATCH-GL-20260629-0930"
    tenant_id: str = "MERIDIAN-IN"
    domain: str = "GENERAL_LEDGER"
    functional_currency: str = "INR"


SUPPORTED_CURRENCIES = {"INR", "USD", "EUR"}
EXCHANGE_RATES_TO_INR = {
    "INR": 1.0,
    "USD": 83.50,
    "EUR": 89.25,
}
KNOWN_COST_CENTRES = {"CC100", "CC200", "CC300"}
KNOWN_PROFIT_CENTRES = {"PC100", "PC200", "PC300"}

