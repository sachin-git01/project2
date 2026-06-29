import json
from pathlib import Path
from typing import Any

from .config import PipelineConfig


def write_json(path: Path, payload: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2), encoding="utf-8")


def load_to_finsight_file(records: list[dict[str, Any]], config: PipelineConfig) -> dict[str, Any]:
    payload = {
        "batchId": config.batch_id,
        "tenantId": config.tenant_id,
        "domain": config.domain,
        "records": records,
    }
    write_json(config.output_dir / "finsight_gl_batch.json", payload)
    return {
        "batchId": config.batch_id,
        "status": "COMPLETED",
        "acceptedCount": len(records),
        "rejectedCount": 0,
    }

