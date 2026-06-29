# Changelog

## Day 1 - Repository Setup and Discovery

- Created repository structure for documentation, API specs, mappings, diagrams, monitoring, tests, and Postman artifacts.
- Defined project overview, business problem, scope, assumptions, SLAs, and acceptance checklist in `README.md`.
- Captured initial business, technical, security, compliance, and non-functional requirements.
- Drafted C4 and data-flow diagram source files in Mermaid format.

## Day 2 - Architecture Design

- Added target architecture using extraction, Kafka, transformation, reconciliation, DLQ, and monitoring components.
- Documented technology choices and alternatives.
- Added network and deployment assumptions for India-region processing.

## Day 3 - API and Data Flow

- Added OpenAPI specifications for SAP source APIs and FinSight destination APIs.
- Documented end-to-end happy path, retry/DLQ flow, and reconciliation mismatch flow.

## Day 4 - Mapping, Resilience, and Controls

- Added 80+ field mappings across GL, AP, AR, cost centre, profit centre, material ledger, PO, SO, fixed assets, bank statements, budget/actual, and inventory.
- Added error handling, reconciliation, monitoring, and test specifications.

## Resubmission Upgrade - Runnable Evidence

- Added Python integration prototype covering SAP CSV extraction, FinSight canonical transformation, validation, DLQ routing, and reconciliation.
- Added sample SAP GL data with valid and invalid records.
- Added pytest tests proving DLQ routing and balanced reconciliation.
- Added D9 prototype documentation and README run instructions.
