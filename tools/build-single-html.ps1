param(
  [string]$OutputPath = "submission_single_file.html"
)

$ErrorActionPreference = "Stop"

$root = Resolve-Path "."
$include = @(
  "README.md",
  "SUBMISSION_CHECKLIST.md",
  "CHANGELOG.md",
  "docs/D0_Requirements_v1.md",
  "docs/D1_Integration_Architecture_v1.md",
  "docs/D2_API_Specification_v1.md",
  "docs/D4_Error_Handling_Framework_v1.md",
  "docs/D5_Reconciliation_Specification_v1.md",
  "docs/D8_Stakeholder_Communication_v1.md",
  "api/API_SAP_Source.yaml",
  "api/API_FinSight_Destination.yaml",
  "mappings/MAP_Finance_AllDomains_v1.md",
  "monitoring/D6_Monitoring_Dashboard_v1.md",
  "tests/D7_Integration_Test_Plan_v1.md",
  "diagrams/DGM_C4_SystemContext.mmd",
  "diagrams/DGM_C4_Container.mmd",
  "diagrams/DGM_Sequence_HappyPath.mmd",
  "diagrams/DGM_Sequence_ErrorDLQ.mmd",
  "diagrams/DGM_DataFlow_Reconciliation.mmd",
  "postman/FDE9B_Postman_Collection.json",
  ".gitignore"
)

function HtmlEscape([string]$value) {
  return [System.Net.WebUtility]::HtmlEncode($value)
}

$sections = foreach ($relative in $include) {
  $path = Join-Path $root $relative
  if (Test-Path -LiteralPath $path) {
    $content = Get-Content -Raw -LiteralPath $path
    $escapedTitle = HtmlEscape $relative
    $escapedContent = HtmlEscape $content
    @"
      <section class="file-section" id="$escapedTitle">
        <div class="file-header">
          <h2>$escapedTitle</h2>
          <button type="button" data-copy="$escapedTitle">Copy</button>
        </div>
        <pre><code id="code-$escapedTitle">$escapedContent</code></pre>
      </section>
"@
  }
}

$toc = foreach ($relative in $include) {
  if (Test-Path -LiteralPath (Join-Path $root $relative)) {
    $escaped = HtmlEscape $relative
    "          <li><a href=""#$escaped"">$escaped</a></li>"
  }
}

$html = @"
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>FDE-9B SAP to FinSight Submission Bundle</title>
  <style>
    :root {
      color-scheme: light;
      --bg: #f6f7f9;
      --panel: #ffffff;
      --text: #18202a;
      --muted: #607080;
      --border: #d8dee6;
      --accent: #1769aa;
      --code-bg: #101820;
      --code-text: #eef6ff;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: Arial, Helvetica, sans-serif;
      line-height: 1.55;
      color: var(--text);
      background: var(--bg);
    }
    header {
      padding: 32px 24px;
      background: #ffffff;
      border-bottom: 1px solid var(--border);
    }
    header h1 {
      margin: 0 0 8px;
      font-size: 30px;
      line-height: 1.2;
    }
    header p {
      max-width: 900px;
      margin: 0;
      color: var(--muted);
    }
    main {
      display: grid;
      grid-template-columns: 280px minmax(0, 1fr);
      gap: 20px;
      padding: 20px;
    }
    nav {
      position: sticky;
      top: 20px;
      align-self: start;
      background: var(--panel);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 16px;
      max-height: calc(100vh - 40px);
      overflow: auto;
    }
    nav h2 {
      margin: 0 0 10px;
      font-size: 16px;
    }
    nav ul {
      list-style: none;
      padding: 0;
      margin: 0;
    }
    nav li {
      margin: 7px 0;
      overflow-wrap: anywhere;
    }
    nav a {
      color: var(--accent);
      text-decoration: none;
      font-size: 14px;
    }
    .content {
      min-width: 0;
    }
    .file-section {
      background: var(--panel);
      border: 1px solid var(--border);
      border-radius: 8px;
      margin-bottom: 18px;
      overflow: hidden;
    }
    .file-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
      padding: 12px 14px;
      border-bottom: 1px solid var(--border);
      background: #fbfcfd;
    }
    .file-header h2 {
      margin: 0;
      font-size: 16px;
      overflow-wrap: anywhere;
    }
    button {
      border: 1px solid var(--border);
      background: #ffffff;
      color: var(--text);
      border-radius: 6px;
      padding: 6px 10px;
      cursor: pointer;
      font-size: 13px;
    }
    button:hover {
      border-color: var(--accent);
      color: var(--accent);
    }
    pre {
      margin: 0;
      padding: 16px;
      overflow: auto;
      background: var(--code-bg);
      color: var(--code-text);
      font-size: 13px;
      line-height: 1.5;
    }
    code {
      font-family: Consolas, "Courier New", monospace;
      white-space: pre;
    }
    @media (max-width: 900px) {
      main {
        grid-template-columns: 1fr;
      }
      nav {
        position: static;
        max-height: none;
      }
    }
  </style>
</head>
<body>
  <header>
    <h1>FDE-9B SAP S/4HANA to FinSight Submission Bundle</h1>
    <p>This single HTML file embeds the repository deliverables for easy previewing, copying, and backup submission. Use the Copy button beside any file section to copy that file's exact content.</p>
  </header>
  <main>
    <nav>
      <h2>Files</h2>
      <ul>
$($toc -join "`n")
      </ul>
    </nav>
    <div class="content">
$($sections -join "`n")
    </div>
  </main>
  <script>
    document.querySelectorAll("button[data-copy]").forEach((button) => {
      button.addEventListener("click", async () => {
        const id = "code-" + button.getAttribute("data-copy");
        const text = document.getElementById(id).innerText;
        await navigator.clipboard.writeText(text);
        const old = button.textContent;
        button.textContent = "Copied";
        setTimeout(() => { button.textContent = old; }, 1200);
      });
    });
  </script>
</body>
</html>
"@

Set-Content -LiteralPath $OutputPath -Value $html -Encoding UTF8
Write-Host "Created $OutputPath"
