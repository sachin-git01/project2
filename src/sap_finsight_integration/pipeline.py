from .config import PipelineConfig
from .extract import extract_csv
from .load import load_to_finsight_file, write_json
from .reconcile import reconcile
from .transform import transform_batch


def run_pipeline(config: PipelineConfig | None = None) -> dict[str, object]:
    config = config or PipelineConfig()
    source_rows = extract_csv(config.source_file)
    accepted, rejected = transform_batch(source_rows, config)
    load_result = load_to_finsight_file(accepted, config)
    recon_report = reconcile(source_rows, accepted, rejected, config)

    write_json(config.output_dir / "dlq_records.json", rejected)
    write_json(config.output_dir / "reconciliation_report.json", recon_report)
    write_json(config.output_dir / "load_result.json", load_result)

    return {
        "accepted": accepted,
        "rejected": rejected,
        "loadResult": load_result,
        "reconciliation": recon_report,
    }

