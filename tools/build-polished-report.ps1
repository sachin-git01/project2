param(
  [string]$HtmlPath = "Zetheta_Project_1B_POLISHED_REPORT.html"
)

$ErrorActionPreference = "Stop"

function Escape-Html([string]$value) {
  return [System.Net.WebUtility]::HtmlEncode($value)
}

function Read-Text([string]$path) {
  if (Test-Path -LiteralPath $path) {
    return Get-Content -Raw -LiteralPath $path
  }
  return ""
}

function MarkdownRows([string]$path, [string]$prefix) {
  $rows = @()
  Get-Content -LiteralPath $path | ForEach-Object {
    if ($_ -like "| $prefix*") {
      $cells = $_.Trim().Trim("|").Split("|") | ForEach-Object { $_.Trim() }
      $rows += ,$cells
    }
  }
  return $rows
}

function RenderRows($rows, [string[]]$headers, [string]$className = "") {
  $head = ($headers | ForEach-Object { "<th>$(Escape-Html $_)</th>" }) -join ""
  $body = foreach ($row in $rows) {
    $cells = foreach ($cell in $row) {
      "<td>$(Escape-Html $cell)</td>"
    }
    "<tr>$($cells -join '')</tr>"
  }
  return "<table class='$className'><thead><tr>$head</tr></thead><tbody>$($body -join "`n")</tbody></table>"
}

$mappingRows = MarkdownRows "mappings/MAP_Finance_AllDomains_v1.md" "MAP-"
$testRows = MarkdownRows "tests/D7_Integration_Test_Plan_v1.md" "TST-"
$recon = Read-Text "outputs/reconciliation_report.json"
$load = Read-Text "outputs/load_result.json"
$sampleData = Get-Content -LiteralPath "data/sample/sap_gl_entries.csv" | Select-Object -First 5

$mappingCounts = $mappingRows | Group-Object { $_[1] } | Sort-Object Name
$mappingSummaryRows = foreach ($group in $mappingCounts) {
  @($group.Name, [string]$group.Count, "Source field, target field, transformation, validation, and error handling documented")
}

$sourceEndpoints = @(
  @("SRC-001", "General Ledger", "/sap/v1/general-ledger/journal-entries", "ODP delta", "ACDOCA/BKPF"),
  @("SRC-002", "Accounts Payable", "/sap/v1/accounts-payable/open-items", "ODP delta", "ACDOCA/LFA1"),
  @("SRC-003", "Accounts Receivable", "/sap/v1/accounts-receivable/open-items", "ODP delta", "ACDOCA/KNA1"),
  @("SRC-004", "Cost Centre", "/sap/v1/master-data/cost-centres", "CDS/OData", "CSKS/CSKT"),
  @("SRC-005", "Profit Centre", "/sap/v1/master-data/profit-centres", "CDS/OData", "CEPC/CEPCT"),
  @("SRC-006", "Material Ledger", "/sap/v1/material-ledger/movements", "CDS delta", "MLDOC/CKMLCR"),
  @("SRC-007", "Purchase Orders", "/sap/v1/procurement/purchase-orders", "OData/CDS", "EKKO/EKPO/EKBE"),
  @("SRC-008", "Sales Orders", "/sap/v1/sales/sales-orders", "OData/CDS", "VBAK/VBAP/VBFA"),
  @("SRC-009", "Fixed Assets", "/sap/v1/fixed-assets/assets", "CDS", "ANLA/ANLC"),
  @("SRC-010", "Bank Statements", "/sap/v1/cash/bank-statements", "IDoc/CDS", "FEBKO/FEBEP"),
  @("SRC-011", "Budget vs Actual", "/sap/v1/controlling/budget-actuals", "CDS", "ACDOCA/ACDOCP"),
  @("SRC-012", "Inventory", "/sap/v1/inventory/stock-movements", "ODP/CDS", "MATDOC/MARA")
)

$destEndpoints = @(
  @("DST-001", "General Ledger", "/finsight/v1/journal-entries:batchUpsert"),
  @("DST-002", "Accounts Payable", "/finsight/v1/payables:batchUpsert"),
  @("DST-003", "Accounts Receivable", "/finsight/v1/receivables:batchUpsert"),
  @("DST-004", "Cost Centre", "/finsight/v1/cost-centres:batchUpsert"),
  @("DST-005", "Profit Centre", "/finsight/v1/profit-centres:batchUpsert"),
  @("DST-006", "Material Ledger", "/finsight/v1/material-movements:batchUpsert"),
  @("DST-007", "Purchase Orders", "/finsight/v1/purchase-orders:batchUpsert"),
  @("DST-008", "Sales Orders", "/finsight/v1/sales-orders:batchUpsert"),
  @("DST-009", "Fixed Assets", "/finsight/v1/fixed-assets:batchUpsert"),
  @("DST-010", "Bank Statements", "/finsight/v1/bank-statements:batchUpsert"),
  @("DST-011", "Budget vs Actual", "/finsight/v1/budget-actuals:batchUpsert"),
  @("DST-012", "Inventory", "/finsight/v1/inventory:batchUpsert")
)

$monitoringRows = @(
  @("MON-001", "Pipeline Health", "Domain freshness, failures, last successful load", "P1 when RED"),
  @("MON-002", "Throughput", "records/sec by domain", "Warn below 50% baseline"),
  @("MON-003", "Latency", "P95/P99 API latency", "Warn above 5 seconds"),
  @("MON-004", "Error Rate", "errors / requests", "Critical above 5%"),
  @("MON-005", "DLQ Depth", "failed record backlog", "P1 above 500"),
  @("MON-006", "Reconciliation", "PASS/WARN/BREAK per batch", "P2 on break"),
  @("MON-007", "SAP Health", "RFC pool, response time, work processes", "Critical above 90% pool"),
  @("MON-008", "FinSight API", "rate limit, response time, token expiry", "Warn below 10% quota"),
  @("MON-009", "Data Freshness", "now - last load", "Alert on SLA breach"),
  @("MON-010", "Resources", "CPU, memory, disk, network", "P2 above 90%"),
  @("MON-011", "Kafka Lag", "consumer group lag", "P2 above 50K"),
  @("MON-012", "Circuit Breakers", "open/half-open/closed", "P2 if open")
)

$errorRows = @(
  @("ERR-EXT-001", "SAP RFC timeout", "Retry with exponential backoff"),
  @("ERR-EXT-003", "ODP subscription invalidated", "Halt domain and alert integration team"),
  @("ERR-MAP-001", "Mandatory field missing", "Default if allowed else DLQ"),
  @("ERR-MAP-002", "Invalid date format", "Correct if possible else DLQ"),
  @("ERR-MAP-003", "Missing master data reference", "Business exception queue"),
  @("ERR-MAP-004", "Invalid currency", "Typo correction else DLQ"),
  @("ERR-LOAD-001", "FinSight HTTP 429", "Honor Retry-After and throttle"),
  @("ERR-LOAD-004", "Duplicate entry", "Compare payload hash and skip identical"),
  @("ERR-RECON-001", "Record count mismatch", "Generate break report"),
  @("ERR-SYS-001", "Kafka broker unreachable", "Circuit breaker and P1 alert")
)

$html = @"
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Project 1B - Custom API Integration Final Report</title>
  <style>
    @page { size: A4; margin: 15mm 13mm; }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: "Segoe UI", Arial, sans-serif;
      color: #1d2935;
      background: #fff;
      font-size: 11.5px;
      line-height: 1.48;
    }
    h1, h2, h3 { color: #0d3b59; line-height: 1.22; }
    h1 { font-size: 27px; margin: 0 0 8px; letter-spacing: 0; }
    h2 { font-size: 17px; margin: 18px 0 8px; border-bottom: 1.4px solid #cbd8e3; padding-bottom: 5px; }
    h3 { font-size: 13px; margin: 12px 0 6px; color: #14506f; }
    p { margin: 6px 0; }
    .cover {
      min-height: 255mm;
      padding: 22mm 15mm;
      background: linear-gradient(180deg, #f7fbfd 0%, #ffffff 55%);
      border: 2px solid #0e6f8f;
      border-radius: 10px;
      page-break-after: always;
    }
    .kicker {
      text-transform: uppercase;
      color: #0e6f8f;
      font-size: 11px;
      letter-spacing: .08em;
      font-weight: 700;
      margin-bottom: 12px;
    }
    .subtitle { font-size: 15px; color: #4f6171; margin-bottom: 18px; }
    .badge-row { display: flex; gap: 8px; flex-wrap: wrap; margin: 16px 0; }
    .badge {
      border: 1px solid #a8d5b4;
      background: #eaf7ee;
      color: #155c2b;
      border-radius: 20px;
      padding: 5px 9px;
      font-weight: 700;
      font-size: 11px;
    }
    .meta {
      display: grid;
      grid-template-columns: 150px 1fr;
      gap: 7px 12px;
      margin-top: 20px;
      font-size: 12px;
      border-top: 1px solid #d7e3ea;
      padding-top: 14px;
    }
    .label { font-weight: 700; color: #2e4558; }
    .section { page-break-inside: auto; }
    .avoid-break { page-break-inside: avoid; }
    .page-break { page-break-before: always; }
    .grid-2 {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 10px;
    }
    .card {
      border: 1px solid #d4e0e8;
      border-radius: 7px;
      padding: 10px;
      background: #fbfdfe;
      page-break-inside: avoid;
    }
    .metric {
      font-size: 21px;
      font-weight: 800;
      color: #0e6f8f;
      margin-bottom: 2px;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      margin: 8px 0 13px;
    }
    th, td {
      border: 1px solid #d4e0e8;
      padding: 5px 6px;
      vertical-align: top;
      text-align: left;
    }
    th {
      background: #edf6fa;
      color: #0d3b59;
      font-weight: 700;
    }
    tr { page-break-inside: avoid; }
    .small-table { font-size: 9px; line-height: 1.32; }
    .small-table th, .small-table td { padding: 4px; }
    .mapping-table { font-size: 7.8px; line-height: 1.25; }
    .mapping-table th, .mapping-table td { padding: 3px; }
    .toc li { margin: 4px 0; }
    .diagram {
      font-family: Consolas, "Courier New", monospace;
      white-space: pre-wrap;
      background: #f5f8fa;
      border: 1px solid #d4e0e8;
      border-radius: 7px;
      padding: 10px;
      font-size: 10px;
      page-break-inside: avoid;
    }
    pre {
      white-space: pre-wrap;
      overflow-wrap: anywhere;
      background: #f7f9fb;
      border: 1px solid #d4e0e8;
      border-radius: 6px;
      padding: 8px;
      font-family: Consolas, "Courier New", monospace;
      font-size: 9px;
      line-height: 1.34;
    }
    .note {
      background: #fff8e5;
      border-left: 4px solid #e8aa00;
      padding: 8px 10px;
      margin: 8px 0;
      page-break-inside: avoid;
    }
    .footer-note { color: #617383; font-size: 10px; margin-top: 10px; }
  </style>
</head>
<body>
  <section class="cover">
    <div class="kicker">Final Resubmission Document</div>
    <h1>Project 1B: Custom API Integration</h1>
    <p class="subtitle">SAP S/4HANA ERP to FinSight Financial Analytics Platform</p>
    <div class="badge-row">
      <span class="badge">OpenAPI 3.0</span>
      <span class="badge">102 Field Mappings</span>
      <span class="badge">25 Test Scenarios</span>
      <span class="badge">Runnable Prototype</span>
      <span class="badge">Reconciliation Evidence</span>
    </div>
    <p>
      This report presents a clean, complete, and implementation-backed solution for designing an end-to-end API integration framework between SAP S/4HANA and a financial analytics platform.
    </p>
    <div class="meta">
      <div class="label">Participant</div><div>Sachin / sachin-git01</div>
      <div class="label">GitHub Repository</div><div>https://github.com/sachin-git01/project2</div>
      <div class="label">Source System</div><div>SAP S/4HANA ERP</div>
      <div class="label">Target Platform</div><div>FinSight Financial Analytics Platform</div>
      <div class="label">Primary Output</div><div>Design documentation, API specs, mapping spec, monitoring plan, test plan, and runnable proof-of-concept</div>
      <div class="label">Validation Status</div><div>Prototype executed successfully; reconciliation status is RECONCILED</div>
    </div>
  </section>

  <section class="section toc">
    <h2>Table of Contents</h2>
    <ol>
      <li>Executive Summary</li>
      <li>Problem Statement Alignment</li>
      <li>Business and Technical Objectives</li>
      <li>End-to-End Architecture</li>
      <li>API Specification</li>
      <li>Data Mapping and Transformation</li>
      <li>Error Handling and Resilience</li>
      <li>Reconciliation and Audit Controls</li>
      <li>Monitoring and Operations</li>
      <li>Runnable Prototype and Validation Evidence</li>
      <li>Testing Strategy</li>
      <li>Submission Deliverables</li>
      <li>Appendix A: Full Mapping Table</li>
      <li>Appendix B: Full Test Scenario Table</li>
    </ol>
  </section>

  <section class="section">
    <h2>1. Executive Summary</h2>
    <p>
      Meridian Manufacturing uses SAP S/4HANA as its ERP system of record but needs faster and more reliable financial analytics in FinSight. This solution removes manual exports by creating a resilient integration layer that extracts SAP data, transforms it into canonical financial schemas, loads it to FinSight, and verifies every batch through reconciliation.
    </p>
    <p>
      The design follows enterprise integration best practices: SAP-supported extraction methods, Kafka-based decoupling, idempotent destination APIs, DLQ isolation, circuit breakers, audit lineage, and operational dashboards.
    </p>
    <div class="grid-2">
      <div class="card"><div class="metric">4 hr</div><strong>Standard freshness SLA</strong><br>Finance analytics available within 4 hours for standard domains.</div>
      <div class="card"><div class="metric">102</div><strong>Field mappings</strong><br>Field-level source, target, transformation, validation, and error handling rules.</div>
      <div class="card"><div class="metric">25</div><strong>Test scenarios</strong><br>Functional, non-functional, failure, security, and reconciliation tests.</div>
      <div class="card"><div class="metric">0</div><strong>Duplicate tolerance</strong><br>Idempotency keys prevent duplicate FinSight writes.</div>
    </div>
  </section>

  <section class="section">
    <h2>2. Problem Statement Alignment</h2>
    <table>
      <thead><tr><th>Project Requirement</th><th>Solution Coverage</th><th>Evidence</th></tr></thead>
      <tbody>
        <tr><td>Custom API integration framework</td><td>Source API facade, Kafka integration layer, transformation engine, validation service, FinSight loader, reconciliation, and monitoring.</td><td>Architecture + APIs + prototype</td></tr>
        <tr><td>SAP S/4HANA source system</td><td>Uses ACDOCA, BKPF, ODP, CDS, OData, RFC, IDoc, and SAP master data concepts.</td><td>Source endpoint table and mappings</td></tr>
        <tr><td>Financial analytics platform</td><td>Defines FinSight batch ingestion endpoints and canonical financial payloads.</td><td>Destination API table</td></tr>
        <tr><td>API specification</td><td>OpenAPI 3.0 YAML files for SAP and FinSight.</td><td>api/API_SAP_Source.yaml and api/API_FinSight_Destination.yaml</td></tr>
        <tr><td>Data extraction</td><td>ODP/CDS delta strategy plus runnable CSV extraction simulation.</td><td>Prototype and extraction design</td></tr>
        <tr><td>Transformation logic</td><td>102 documented mappings plus executable Python transformation logic.</td><td>Appendix A and transform.py</td></tr>
        <tr><td>Communication protocols</td><td>HTTPS/OData, RFC/SNC, Kafka, OAuth 2.0, TLS 1.2+, and API gateway controls.</td><td>Architecture and security sections</td></tr>
      </tbody>
    </table>
  </section>

  <section class="section">
    <h2>3. Business and Technical Objectives</h2>
    <table>
      <thead><tr><th>Objective</th><th>Implementation</th><th>Success Measure</th></tr></thead>
      <tbody>
        <tr><td>Improve finance visibility</td><td>Automated SAP-to-FinSight data flow</td><td>Dashboards refreshed within SLA</td></tr>
        <tr><td>Reduce manual reconciliation</td><td>Batch reconciliation service</td><td>Counts, totals, and checksums match</td></tr>
        <tr><td>Protect SAP stability</td><td>Delta extraction, package limits, off-peak full loads</td><td>No production performance degradation</td></tr>
        <tr><td>Ensure auditability</td><td>Lineage fields from SAP document to FinSight record</td><td>Every target record traceable</td></tr>
        <tr><td>Handle failures safely</td><td>Retries, circuit breakers, DLQ, business exception queues</td><td>No data loss during transient failures</td></tr>
      </tbody>
    </table>
  </section>

  <section class="section">
    <h2>4. End-to-End Architecture</h2>
    <div class="diagram">SAP S/4HANA
  | ODP / CDS / OData / RFC / IDoc
  v
SAP Connector + Scheduler
  | publishes domain events
  v
Kafka Topics and Schema Registry
  | consumed by domain workers
  v
Transformation Engine -> Validation Service -> FinSight Loader -> FinSight APIs
          |                     |                    |
          v                     v                    v
    Audit Store               DLQ             Reconciliation Service
          \____________________|____________________/
                         Monitoring Stack</div>
    <h3>Architecture Components</h3>
    <table>
      <thead><tr><th>Component</th><th>Responsibility</th></tr></thead>
      <tbody>
        <tr><td>Scheduler</td><td>Triggers full loads, deltas, retries, and reconciliation jobs.</td></tr>
        <tr><td>SAP Connector</td><td>Reads SAP source data through supported enterprise interfaces.</td></tr>
        <tr><td>Kafka</td><td>Buffers messages, supports replay, and isolates SAP from FinSight outages.</td></tr>
        <tr><td>Transformation Engine</td><td>Converts SAP records to canonical FinSight schemas.</td></tr>
        <tr><td>Validation Service</td><td>Checks mandatory fields, dates, currency, and master data references.</td></tr>
        <tr><td>FinSight Loader</td><td>Loads records using batch upsert APIs and idempotency keys.</td></tr>
        <tr><td>Reconciliation Service</td><td>Compares source and target counts, amounts, checksums, and lineage.</td></tr>
        <tr><td>Monitoring Stack</td><td>Tracks freshness, throughput, errors, DLQ, lag, and circuit breakers.</td></tr>
      </tbody>
    </table>
  </section>

  <section class="section">
    <h2>5. API Specification</h2>
    <h3>SAP Source APIs</h3>
    $(RenderRows $sourceEndpoints @("ID", "Domain", "Endpoint", "Extraction", "SAP Source") "small-table")
    <h3>FinSight Destination APIs</h3>
    $(RenderRows $destEndpoints @("ID", "Domain", "Endpoint") "small-table")
    <div class="note">
      API design includes OAuth 2.0 authentication, cursor pagination, delta tokens, rate-limit headers, Retry-After handling, common error envelope, and mandatory Idempotency-Key for writes.
    </div>
  </section>

  <section class="section">
    <h2>6. Data Mapping and Transformation</h2>
    <p>
      The project includes 102 field-level mappings across 12 domains. Each mapping includes source field, target field, transformation rule, validation, and error handling.
    </p>
    $(RenderRows $mappingSummaryRows @("Domain", "Mapping Count", "Coverage") "small-table")
    <h3>Core Transformation Rules</h3>
    <table>
      <thead><tr><th>Rule</th><th>Decision</th></tr></thead>
      <tbody>
        <tr><td>Date conversion</td><td>SAP YYYYMMDD values are converted to ISO YYYY-MM-DD.</td></tr>
        <tr><td>Currency conversion</td><td>Transaction currency is validated against ISO 4217 and converted to INR using point-in-time rates.</td></tr>
        <tr><td>Fiscal period handling</td><td>Periods 013-016 are mapped as special periods while preserving audit flags.</td></tr>
        <tr><td>Idempotency</td><td>Keys are generated from tenant, domain, company code, fiscal year, document number, and line item.</td></tr>
        <tr><td>Lineage</td><td>Every target record carries source system, source table, source document, and batch ID.</td></tr>
      </tbody>
    </table>
  </section>

  <section class="section">
    <h2>7. Error Handling and Resilience</h2>
    $(RenderRows $errorRows @("Code", "Scenario", "Default Action") "small-table")
    <h3>Resilience Patterns</h3>
    <table>
      <thead><tr><th>Pattern</th><th>Usage</th></tr></thead>
      <tbody>
        <tr><td>Exponential backoff with jitter</td><td>Retries transient SAP and FinSight failures without overwhelming recovering services.</td></tr>
        <tr><td>Circuit breaker</td><td>Stops repeated calls to unhealthy SAP, FinSight, or Kafka dependencies.</td></tr>
        <tr><td>Dead letter queue</td><td>Stores records that fail validation or mapping after controlled handling.</td></tr>
        <tr><td>Idempotent receiver</td><td>Prevents duplicate target writes during retry or replay.</td></tr>
        <tr><td>Bulkhead isolation</td><td>Prevents one failed domain from blocking other domains.</td></tr>
      </tbody>
    </table>
  </section>

  <section class="section">
    <h2>8. Reconciliation and Audit Controls</h2>
    <table>
      <thead><tr><th>Control</th><th>Purpose</th><th>Expected Result</th></tr></thead>
      <tbody>
        <tr><td>Record count</td><td>Source count equals accepted plus rejected records.</td><td>No unexplained missing records.</td></tr>
        <tr><td>Debit-credit total</td><td>Validates financial balance after transformation.</td><td>Debit total equals credit total for balanced batches.</td></tr>
        <tr><td>Checksum</td><td>Detects accidental changes in business keys or amounts.</td><td>Stable hash per batch.</td></tr>
        <tr><td>Lineage</td><td>Connects FinSight record back to SAP source document.</td><td>Audit-ready traceability.</td></tr>
      </tbody>
    </table>
    <h3>Generated Reconciliation Evidence</h3>
    <pre>$(Escape-Html $recon)</pre>
  </section>

  <section class="section">
    <h2>9. Monitoring and Operations</h2>
    $(RenderRows $monitoringRows @("Panel", "Title", "Metric Focus", "Alert") "small-table")
  </section>

  <section class="section">
    <h2>10. Runnable Prototype and Validation Evidence</h2>
    <p>
      A runnable Python prototype is included to prove the integration behavior. It reads SAP-style GL data, validates records, transforms valid rows into FinSight JSON, routes invalid records to DLQ, and generates a reconciliation report.
    </p>
    <h3>Run Commands</h3>
    <pre>`$env:PYTHONPATH='src'
python -m sap_finsight_integration.cli
python -m unittest discover -s tests -p '*unittest.py'`</pre>
    <h3>Observed Result</h3>
    <table>
      <thead><tr><th>Item</th><th>Result</th></tr></thead>
      <tbody>
        <tr><td>Batch ID</td><td>BATCH-GL-20260629-0930</td></tr>
        <tr><td>Status</td><td>RECONCILED</td></tr>
        <tr><td>Accepted records</td><td>6</td></tr>
        <tr><td>DLQ records</td><td>2</td></tr>
        <tr><td>Automated tests</td><td>2 tests passed using Python unittest</td></tr>
      </tbody>
    </table>
    <h3>Sample SAP Input</h3>
    <pre>$(Escape-Html (($sampleData -join "`n")))</pre>
    <h3>Load Result</h3>
    <pre>$(Escape-Html $load)</pre>
  </section>

  <section class="section">
    <h2>11. Testing Strategy</h2>
    <p>
      The test plan covers functional correctness, performance, concurrency, failure recovery, security, and reconciliation controls. The complete test table is included in Appendix B.
    </p>
    <table>
      <thead><tr><th>Category</th><th>Coverage</th></tr></thead>
      <tbody>
        <tr><td>Functional</td><td>GL, AP, AR, master data, hierarchy, P2P, bank statements, budget, and full reconciliation.</td></tr>
        <tr><td>Non-functional</td><td>Peak load, concurrency, latency, scalability, and endurance.</td></tr>
        <tr><td>Failure</td><td>SAP RFC failure, FinSight 429, Kafka failure, malformed records, and network partition.</td></tr>
        <tr><td>Security</td><td>OAuth expiry, invalid token, TLS, and encryption.</td></tr>
        <tr><td>Reconciliation</td><td>Deliberate amount variance and missing master data.</td></tr>
      </tbody>
    </table>
  </section>

  <section class="section">
    <h2>12. Submission Deliverables</h2>
    <table>
      <thead><tr><th>Deliverable</th><th>Artifact</th><th>Status</th></tr></thead>
      <tbody>
        <tr><td>Project overview</td><td>README.md</td><td>Complete</td></tr>
        <tr><td>Requirements</td><td>docs/D0_Requirements_v1.md</td><td>Complete</td></tr>
        <tr><td>Architecture</td><td>docs/D1_Integration_Architecture_v1.md and diagrams/*.mmd</td><td>Complete</td></tr>
        <tr><td>API specs</td><td>api/API_SAP_Source.yaml and api/API_FinSight_Destination.yaml</td><td>Complete</td></tr>
        <tr><td>Mappings</td><td>mappings/MAP_Finance_AllDomains_v1.md</td><td>Complete, 102 mappings</td></tr>
        <tr><td>Error handling</td><td>docs/D4_Error_Handling_Framework_v1.md</td><td>Complete</td></tr>
        <tr><td>Reconciliation</td><td>docs/D5_Reconciliation_Specification_v1.md</td><td>Complete</td></tr>
        <tr><td>Monitoring</td><td>monitoring/D6_Monitoring_Dashboard_v1.md</td><td>Complete</td></tr>
        <tr><td>Test plan</td><td>tests/D7_Integration_Test_Plan_v1.md</td><td>Complete, 25 scenarios</td></tr>
        <tr><td>Runnable prototype</td><td>src/, data/sample/, outputs/, tests/</td><td>Complete and verified</td></tr>
      </tbody>
    </table>
  </section>

  <section class="section page-break">
    <h2>Appendix A: Full Mapping Table</h2>
    <p class="footer-note">Full 102-field mapping evidence. Font is compact only for appendix density; main explanation appears in Section 6.</p>
    $(RenderRows $mappingRows @("ID", "Domain", "Source Field", "Target Field", "Transformation", "Validation", "Error Handling") "mapping-table")
  </section>

  <section class="section page-break">
    <h2>Appendix B: Full Test Scenario Table</h2>
    $(RenderRows $testRows @("ID", "Category/Title", "Preconditions/Title", "Steps/Validation", "Expected Result") "small-table")
  </section>
</body>
</html>
"@

Set-Content -LiteralPath $HtmlPath -Value $html -Encoding UTF8
Write-Host "Created $HtmlPath"
