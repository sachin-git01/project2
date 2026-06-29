from .pipeline import run_pipeline


def main() -> None:
    result = run_pipeline()
    recon = result["reconciliation"]
    print(f"Batch: {recon['batchId']}")
    print(f"Status: {recon['status']}")
    print(f"Accepted: {recon['acceptedRecordCount']}")
    print(f"Rejected/DLQ: {recon['rejectedRecordCount']}")
    print("Outputs written to outputs/")


if __name__ == "__main__":
    main()

