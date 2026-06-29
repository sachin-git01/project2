param(
  [string]$HtmlPath = "Zetheta_Project_1B_FINAL_FULL_DOCUMENT.html"
)

$ErrorActionPreference = "Stop"

function E([string]$value) {
  return [System.Net.WebUtility]::HtmlEncode($value)
}

function ReadArtifact([string]$path) {
  if (Test-Path -LiteralPath $path) {
    return Get-Content -Raw -LiteralPath $path
  }
  return "Missing file: $path"
}

function ArtifactSection([string]$title, [string]$path, [string]$note = "") {
  $content = E (ReadArtifact $path)
  $noteHtml = ""
  if ($note) {
    $noteHtml = "<p class='note'>$(E $note)</p>"
  }
  return @"
  <section class="artifact">
    <h2>$title</h2>
    $noteHtml
    <p><strong>Source file:</strong> <code>$path</code></p>
    <pre>$content</pre>
  </section>
"@
}

$artifactSections = @(
  ArtifactSection "Appendix A - README and Project Overview" "README.md" "Primary project navigation and reviewer guide."
  ArtifactSection "Appendix B - Resubmission Improvement Note" "RESUBMISSION_NOTE.md" "Explains what was improved after the low-score feedback."
  ArtifactSection "Appendix C - Requirements Document" "docs/D0_Requirements_v1.md" "Business, technical, stakeholder, and non-functional requirements."
  ArtifactSection "Appendix D - Integration Architecture" "docs/D1_Integration_Architecture_v1.md" "C4-style architecture, risk register, technology stack, and security design."
  ArtifactSection "Appendix E - API Specification Document" "docs/D2_API_Specification_v1.md" "Source and destination endpoint coverage."
  ArtifactSection "Appendix F - SAP Source OpenAPI 3.0 YAML" "api/API_SAP_Source.yaml" "Machine-readable API specification for SAP source extraction."
  ArtifactSection "Appendix G - FinSight Destination OpenAPI 3.0 YAML" "api/API_FinSight_Destination.yaml" "Machine-readable API specification for destination ingestion."
  ArtifactSection "Appendix H - Data Mapping Specification With 102 Mappings" "mappings/MAP_Finance_AllDomains_v1.md" "Exceeds the 50-field minimum and covers 12 domains."
  ArtifactSection "Appendix I - Error Handling Framework" "docs/D4_Error_Handling_Framework_v1.md" "Retry, circuit breaker, DLQ, and error-code registry."
  ArtifactSection "Appendix J - Reconciliation Specification" "docs/D5_Reconciliation_Specification_v1.md" "Record count, amount, checksum, lineage, and break workflow."
  ArtifactSection "Appendix K - Monitoring Dashboard Specification" "monitoring/D6_Monitoring_Dashboard_v1.md" "12 monitoring panels and alert routing."
  ArtifactSection "Appendix L - Integration Test Plan" "tests/D7_Integration_Test_Plan_v1.md" "25 required test scenarios."
  ArtifactSection "Appendix M - Stakeholder Communication" "docs/D8_Stakeholder_Communication_v1.md" "CFO summary, IT handoff, and platform engineering review."
  ArtifactSection "Appendix N - Runnable Prototype Documentation" "docs/D9_Runnable_Prototype_v1.md" "How to run and verify the working prototype."
  ArtifactSection "Appendix O - Sample SAP GL Input Data" "data/sample/sap_gl_entries.csv" "SAP-style source records used by the prototype."
  ArtifactSection "Appendix P - Prototype Transformation Code" "src/sap_finsight_integration/transform.py" "Executable validation, mapping, idempotency, and lineage logic."
  ArtifactSection "Appendix Q - Prototype Reconciliation Code" "src/sap_finsight_integration/reconcile.py" "Executable record-count, amount, checksum, and status logic."
  ArtifactSection "Appendix R - Prototype Pipeline Code" "src/sap_finsight_integration/pipeline.py" "End-to-end orchestration."
  ArtifactSection "Appendix S - Automated Unit Tests" "tests/test_pipeline_unittest.py" "No-dependency tests that verify DLQ and reconciliation behavior."
  ArtifactSection "Appendix T - Generated FinSight Payload" "outputs/finsight_gl_batch.json" "Target payload evidence."
  ArtifactSection "Appendix U - Generated DLQ Records" "outputs/dlq_records.json" "Invalid-record handling evidence."
  ArtifactSection "Appendix V - Generated Reconciliation Report" "outputs/reconciliation_report.json" "Successful reconciliation evidence."
  ArtifactSection "Appendix W - Postman Collection Skeleton" "postman/FDE9B_Postman_Collection.json" "API execution support artifact."
  ArtifactSection "Appendix X - C4 Container Diagram Source" "diagrams/DGM_C4_Container.mmd" "Version-controllable diagram source."
  ArtifactSection "Appendix Y - Happy Path Sequence Diagram Source" "diagrams/DGM_Sequence_HappyPath.mmd" "End-to-end sequence source."
  ArtifactSection "Appendix Z - Error and DLQ Sequence Diagram Source" "diagrams/DGM_Sequence_ErrorDLQ.mmd" "Failure-flow sequence source."
)

$html = @"
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Final Full Submission - Project 1B Custom API Integration</title>
  <style>
    @page { size: A4; margin: 14mm; }
    body {
      margin: 0;
      font-family: Arial, Helvetica, sans-serif;
      color: #17212b;
      background: white;
      line-height: 1.48;
      font-size: 12px;
    }
    h1, h2, h3 { color: #073b5c; line-height: 1.2; }
    h1 { font-size: 28px; margin: 0 0 10px; }
    h2 { font-size: 18px; margin-top: 26px; padding-bottom: 5px; border-bottom: 1px solid #d5e0e8; }
    h3 { font-size: 14px; margin-top: 16px; }
    p { margin: 7px 0; }
    table {
      width: 100%;
      border-collapse: collapse;
      margin: 10px 0 16px;
      page-break-inside: avoid;
    }
    th, td {
      border: 1px solid #cfdae3;
      padding: 6px;
      vertical-align: top;
      text-align: left;
    }
    th { background: #edf6fa; color: #073b5c; }
    code { font-family: Consolas, "Courier New", monospace; }
    pre {
      white-space: pre-wrap;
      overflow-wrap: anywhere;
      background: #f6f8fa;
      border: 1px solid #d5e0e8;
      border-radius: 4px;
      padding: 9px;
      font-family: Consolas, "Courier New", monospace;
      font-size: 9px;
      line-height: 1.35;
    }
    .cover {
      border: 2px solid #0a7192;
      border-radius: 8px;
      padding: 24px;
      margin-bottom: 18px;
      page-break-after: always;
    }
    .subtitle { color: #53616f; font-size: 15px; }
    .badge {
      display: inline-block;
      border: 1px solid #8fc8a2;
      background: #e8f6ed;
      color: #135d2c;
      border-radius: 14px;
      padding: 4px 9px;
      font-weight: bold;
      margin: 6px 0;
    }
    .meta {
      display: grid;
      grid-template-columns: 165px 1fr;
      gap: 6px 12px;
      margin-top: 18px;
    }
    .label { font-weight: bold; }
    .toc {
      page-break-after: always;
    }
    .artifact {
      page-break-before: always;
    }
    .note {
      background: #fff8e1;
      border-left: 4px solid #f0b429;
      padding: 7px 9px;
    }
    .score-card td:first-child { width: 28%; font-weight: bold; }
  </style>
</head>
<body>
  <section class="cover">
    <h1>Project 1B: Custom API Integration Between Client ERP and Financial Analytics Platform</h1>
    <p class="subtitle">Final Full Resubmission Document - SAP S/4HANA to FinSight</p>
    <p><span class="badge">Includes complete documentation, OpenAPI specs, 102 mappings, 25 tests, runnable prototype, and validation evidence</span></p>
    <div class="meta">
      <div class="label">Participant</div><div>Sachin / sachin-git01</div>
      <div class="label">Repository</div><div>https://github.com/sachin-git01/project2</div>
      <div class="label">Project Type</div><div>Enterprise Technology / API Integration / FinTech Analytics</div>
      <div class="label">Source System</div><div>SAP S/4HANA ERP</div>
      <div class="label">Target Platform</div><div>FinSight Financial Analytics Platform</div>
      <div class="label">Submission Format</div><div>Single PDF document with appendices and implementation evidence</div>
    </div>
  </section>

  <section class="toc">
    <h2>Table of Contents</h2>
    <ol>
      <li>Executive Summary</li>
      <li>Problem Statement Alignment</li>
      <li>Evaluator Compliance Matrix</li>
      <li>End-to-End Architecture</li>
      <li>API, Mapping, Error Handling, Reconciliation, Monitoring, and Test Evidence</li>
      <li>Runnable Prototype Evidence</li>
      <li>Appendices A-Z containing full source artifacts</li>
    </ol>
  </section>

  <h2>1. Executive Summary</h2>
  <p>
    This document presents a complete solution for Project 1B: designing and implementing a custom API integration framework that connects a client's SAP S/4HANA ERP system with a financial analytics platform. The solution covers the full lifecycle requested in the problem statement: API specification, data extraction, transformation logic, communication protocols, error handling, reconciliation, monitoring, stakeholder communication, and practical implementation evidence.
  </p>
  <p>
    The proposed framework extracts financial and operational data from SAP S/4HANA through supported integration interfaces, routes it through a resilient integration layer, transforms and validates records into FinSight canonical schemas, loads records with idempotency controls, and reconciles source-to-target results for audit confidence.
  </p>

  <h2>2. Problem Statement Alignment</h2>
  <table class="score-card">
    <tr><th>Requirement From Project</th><th>How This Submission Addresses It</th><th>Evidence</th></tr>
    <tr><td>Custom API integration framework</td><td>Designed SAP source extraction APIs and FinSight destination ingestion APIs, with OAuth, pagination, delta tokens, idempotency, and rate limiting.</td><td>Appendix E, F, G</td></tr>
    <tr><td>Connect client's ERP system SAP S/4HANA</td><td>Uses SAP S/4HANA concepts including ACDOCA, CDS views, ODP, RFC, BAPI, OData, and IDoc.</td><td>Appendix C, D, F</td></tr>
    <tr><td>Financial analytics platform</td><td>Defines FinSight canonical payloads and batch upsert endpoints for analytics ingestion.</td><td>Appendix E, G, T</td></tr>
    <tr><td>API specification</td><td>Two OpenAPI 3.0 YAML specifications covering source and target APIs.</td><td>Appendix F, G</td></tr>
    <tr><td>Data extraction</td><td>Documents ODP/CDS delta extraction and includes executable CSV extractor in prototype.</td><td>Appendix C, D, O, R</td></tr>
    <tr><td>Transformation logic</td><td>Includes 102 field mappings and executable Python transformation rules.</td><td>Appendix H, P</td></tr>
    <tr><td>System communication protocols</td><td>Documents HTTPS/OData, RFC/SNC, Kafka topics, OAuth 2.0, TLS, and API gateway patterns.</td><td>Appendix D, E, F, G</td></tr>
    <tr><td>Error handling</td><td>Defines retry, backoff, circuit breakers, DLQ, business exceptions, and error code registry.</td><td>Appendix I, U</td></tr>
    <tr><td>Reconciliation</td><td>Defines count, amount, checksum, and lineage reconciliation and includes generated report.</td><td>Appendix J, Q, V</td></tr>
    <tr><td>Monitoring</td><td>Defines 12 dashboard panels and alert routing.</td><td>Appendix K</td></tr>
    <tr><td>Testing</td><td>Includes 25 scenario test plan and runnable unit tests.</td><td>Appendix L, S</td></tr>
  </table>

  <h2>3. Implementation Evidence Summary</h2>
  <table>
    <tr><th>Metric</th><th>Result</th></tr>
    <tr><td>Field mappings</td><td>102 mapping rows</td></tr>
    <tr><td>Mandatory test scenarios</td><td>25 scenarios</td></tr>
    <tr><td>Source API endpoints</td><td>12 SAP endpoints</td></tr>
    <tr><td>Destination API endpoints</td><td>12 FinSight batch upsert endpoints plus ingestion status</td></tr>
    <tr><td>Prototype accepted records</td><td>6 records</td></tr>
    <tr><td>Prototype DLQ records</td><td>2 records</td></tr>
    <tr><td>Prototype reconciliation status</td><td>RECONCILED</td></tr>
    <tr><td>Automated tests</td><td>2 unittest tests passed locally</td></tr>
  </table>

  <h2>4. End-to-End Architecture Overview</h2>
  <p>
    SAP S/4HANA remains the system of record. The integration framework uses a scheduler and SAP connector to extract deltas, Kafka to decouple source and destination systems, a transformation engine to normalize records, validation rules to protect analytics quality, a loader to write to FinSight using idempotent API calls, and reconciliation services to verify that every financial record is accounted for.
  </p>
  <pre>SAP S/4HANA -> SAP Connector -> Kafka Topics -> Transformation Engine -> Validation Service -> FinSight Loader -> FinSight Analytics
                                      |                         |                         |
                                      v                         v                         v
                               Audit Store                   DLQ                 Reconciliation Service
                                      \_________________________|_________________________/
                                                        Monitoring Stack</pre>

  <h2>5. Run and Validation Commands</h2>
  <pre>`$env:PYTHONPATH='src'
python -m sap_finsight_integration.cli
python -m unittest discover -s tests -p '*unittest.py'`</pre>
  <p>Observed local result: batch status <strong>RECONCILED</strong>, 6 accepted records, 2 DLQ records, and 2 automated tests passing.</p>

  $($artifactSections -join "`n")
</body>
</html>
"@

Set-Content -LiteralPath $HtmlPath -Value $html -Encoding UTF8
Write-Host "Created $HtmlPath"
