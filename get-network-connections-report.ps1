<#
.SYNOPSIS
  Generate a modern HTML report of current TCP connections with sortable columns & live search.
#>

[CmdletBinding()]
param(
  [string]$OutputPath = ("C:\temp\NetTCPConnection_Report_{0}.html" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
)

# --- Gather data ---
try {
  $connections = Get-NetTCPConnection -ErrorAction Stop
} catch {
  Write-Error "Failed to run Get-NetTCPConnection: $($_.Exception.Message)"
  return
}

# Unique PIDs present in the connections
$uniquePids = $connections |
  Where-Object { $_.OwningProcess -ne $null } |
  Select-Object -ExpandProperty OwningProcess -Unique

# Build caches for fast lookups
$procInfoCache = @{}

try {
  $allProcs = Get-CimInstance Win32_Process -ErrorAction Stop
  $cimByPid = @{}
  foreach ($p in $allProcs) { $cimByPid[$p.ProcessId] = $p }
} catch {
  Write-Warning "Get-CimInstance Win32_Process failed: $($_.Exception.Message). Command lines may be blank."
  $cimByPid = @{}
}

$gpById = @{}
try {
  foreach ($gp in Get-Process -ErrorAction SilentlyContinue) { $gpById[$gp.Id] = $gp }
} catch { }

foreach ($p in $uniquePids) {
  $name = $null
  $cmd  = $null
  if ($gpById.ContainsKey($p))   { $name = $gpById[$p].ProcessName }
  if ($cimByPid.ContainsKey($p)) { $cmd  = $cimByPid[$p].CommandLine }
  $procInfoCache[$p] = [PSCustomObject]@{ ProcessName = $name; CommandLine = $cmd }
}

# Shape final rows (avoid assigning to $PID/$pid)
$rows = foreach ($c in $connections) {
  $procId = $c.OwningProcess
  $pi = $null
  if ($procId -and $procInfoCache.ContainsKey($procId)) { $pi = $procInfoCache[$procId] }

  $procName = $null
  $cmdLine  = $null
  if ($pi) {
    $procName = $pi.ProcessName
    $cmdLine  = $pi.CommandLine
  }

  [PSCustomObject]@{
    LocalAddress  = $c.LocalAddress
    LocalPort     = $c.LocalPort
    RemoteAddress = $c.RemoteAddress
    RemotePort    = $c.RemotePort
    State         = $c.State
    ProcessId     = $procId
    Process       = $procName
    CmdLine       = $cmdLine
  }
}

$rows = $rows | Sort-Object RemoteAddress -Descending

# --- Build HTML (inline CSS/JS, PS 5.1 compatible) ---
Add-Type -AssemblyName System.Web
function Escape-Html([string]$s) { [System.Web.HttpUtility]::HtmlEncode($s) }

$escapedComputer = Escape-Html $env:COMPUTERNAME
$now = Get-Date
$title = "Net TCP Connections Report - $escapedComputer - $($now.ToString('yyyy-MM-dd HH:mm:ss'))"

$head = @"
<style>
  :root { --bg:#0b1020; --card:#121a33; --text:#e8ecf8; --muted:#9fb0d6; --accent:#7aa2ff; }
  body { font-family: system-ui, Segoe UI, Roboto, Arial, sans-serif; background: var(--bg); color: var(--text); margin: 0; }
  header { position: sticky; top: 0; z-index: 2; background: linear-gradient(180deg, #0b1020 0%, rgba(11,16,32,0.85) 100%); border-bottom: 1px solid #1f2a4d; padding: 16px 24px; }
  h1 { margin: 0 0 6px 0; font-size: 20px; font-weight: 700; }
  .sub { color: var(--muted); font-size: 12px; }
  .wrap { padding: 24px; }
  .panel { background: var(--card); border: 1px solid #1f2a4d; border-radius: 14px; padding: 16px; box-shadow: 0 10px 25px rgba(0,0,0,0.25); }
  .toolbar { display: flex; gap: 12px; align-items: center; margin-bottom: 12px; flex-wrap: wrap; }
  .toolbar input[type="text"] { flex: 1 1 260px; padding: 10px 12px; border-radius: 10px; border: 1px solid #24335f; background: #0d1430; color: var(--text); outline: none; }
  .toolbar .hint { font-size: 12px; color: var(--muted); }
  table { width: 100%; border-collapse: collapse; }
  thead th { position: sticky; top: calc(16px + 64px); background: #162243; color: var(--text); font-weight: 600; text-align: left; padding: 10px; border-bottom: 1px solid #24335f; cursor: pointer; }
  tbody td { padding: 10px; border-bottom: 1px solid #1c2952; vertical-align: top; }
  tbody tr:nth-child(even) { background: #0f1836; }
  tbody tr:hover { background: #16234a; }
  .num { font-variant-numeric: tabular-nums; }
  .wrap-text { white-space: pre-wrap; word-break: break-word; }
  .badge { display:inline-block; padding:2px 6px; border-radius:8px; font-size:11px; border:1px solid #2b3b6f; color: var(--muted); }
  .counts { display:flex; gap:8px; align-items:center; }
  .counts .pill { background:#0f1836; border:1px solid #24335f; color: var(--muted); padding:4px 8px; border-radius:999px; font-size:12px; }
  .footer { color: var(--muted); font-size: 11px; margin-top: 10px; }
  .sort-indicator { color: var(--accent); margin-left: 6px; font-size: 12px; opacity: 0.85; }
</style>
<script>
  (function(){
    var sortState = { col: -1, dir: 1 }; // 1=asc, -1=desc
    function textOf(cell){ return ((cell && cell.textContent) || '').trim(); }
    function isNumeric(s){ return /^-?\\d+(\\.\\d+)?$/.test(s.replace(/[, ]/g,'')); }
    function cmp(a,b){
      if (isNumeric(a) && isNumeric(b)) {
        var na = parseFloat(a.replace(/[, ]/g,'')), nb = parseFloat(b.replace(/[, ]/g,''));
        return na === nb ? 0 : (na < nb ? -1 : 1);
      }
      a = a.toLowerCase(); b = b.toLowerCase();
      return a === b ? 0 : (a < b ? -1 : 1);
    }
    function clearIndicators(ths){
      for (var i=0;i<ths.length;i++){
        var span = ths[i].querySelector('.sort-indicator');
        if (span) span.textContent = '';
      }
    }
    function setIndicator(th, dir) {
      var span = th.querySelector('.sort-indicator');
      if (!span) { span = document.createElement('span'); span.className = 'sort-indicator'; th.appendChild(span); }
      span.textContent = dir === 1 ? '\\u25B2' : '\\u25BC'; // up/down triangles
    }
    function sortTable(table, col){
      var tbody = table.tBodies[0];
      var rows = Array.prototype.slice.call(tbody.rows);
      if (sortState.col === col) { sortState.dir *= -1; } else { sortState.col = col; sortState.dir = 1; }
      var ths = table.tHead.rows[0].cells;
      clearIndicators(ths);
      setIndicator(ths[col], sortState.dir);
      rows.sort(function(r1, r2){
        var a = textOf(r1.cells[col]), b = textOf(r2.cells[col]);
        return cmp(a,b) * sortState.dir;
      });
      for (var i=0;i<rows.length;i++) tbody.appendChild(rows[i]);
    }
    function filterTable(table, term){
      var t = term.toLowerCase();
      var tbody = table.tBodies[0];
      var visible = 0;
      for (var i=0;i<tbody.rows.length;i++){
        var row = tbody.rows[i];
        var hit = false;
        for (var j=0;j<row.cells.length;j++){
          if (textOf(row.cells[j]).toLowerCase().indexOf(t) !== -1) { hit = true; break; }
        }
        row.style.display = hit ? '' : 'none';
        if (hit) visible++;
      }
      var countEl = document.getElementById('visibleCount');
      if (countEl) countEl.textContent = String(visible);
    }
    window._initTable = function(){
      var table = document.getElementById('netconns');
      if (!table) return;
      var ths = table.tHead.rows[0].cells;
      for (var i=0;i<ths.length;i++){ (function(idx){ ths[idx].addEventListener('click', function(){ sortTable(table, idx); }); })(i); }
      var box = document.getElementById('searchBox');
      if (box) { box.addEventListener('input', function(){ filterTable(table, box.value); }); }
      document.getElementById('totalCount').textContent = String(table.tBodies[0].rows.length);
      document.getElementById('visibleCount').textContent = String(table.tBodies[0].rows.length);
    };
    document.addEventListener('DOMContentLoaded', window._initTable);
  })();
</script>
"@

$established = ($rows | Where-Object State -eq 'Established').Count
$listen      = ($rows | Where-Object State -eq 'Listen').Count
$totalCount  = $rows.Count

$thead = @"
<thead>
  <tr>
    <th>LocalAddress</th>
    <th class="num">LocalPort</th>
    <th>RemoteAddress</th>
    <th class="num">RemotePort</th>
    <th>State</th>
    <th class="num">ProcessId</th>
    <th>Process</th>
    <th>CmdLine</th>
  </tr>
</thead>
"@

# Build tbody
$sb = New-Object -TypeName System.Text.StringBuilder
[void]$sb.AppendLine("<tbody>")
foreach ($r in $rows) {
  $la = Escape-Html("$($r.LocalAddress)")
  $lp = Escape-Html("$($r.LocalPort)")
  $ra = Escape-Html("$($r.RemoteAddress)")
  $rp = Escape-Html("$($r.RemotePort)")
  $st = Escape-Html("$($r.State)")
  $pi = Escape-Html("$($r.ProcessId)")
  $pn = Escape-Html("$($r.Process)")
  $cl = Escape-Html("$($r.CmdLine)")
  [void]$sb.AppendLine("<tr>")
  [void]$sb.AppendLine("<td>$la</td>")
  [void]$sb.AppendLine("<td class='num'>$lp</td>")
  [void]$sb.AppendLine("<td>$ra</td>")
  [void]$sb.AppendLine("<td class='num'>$rp</td>")
  [void]$sb.AppendLine("<td><span class='badge'>$st</span></td>")
  [void]$sb.AppendLine("<td class='num'>$pi</td>")
  [void]$sb.AppendLine("<td>$pn</td>")
  [void]$sb.AppendLine("<td class='wrap-text'>$cl</td>")
  [void]$sb.AppendLine("</tr>")
}
[void]$sb.AppendLine("</tbody>")
$tbody = $sb.ToString()

# Assemble HTML
$html = @"
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta http-equiv="x-ua-compatible" content="ie=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$title</title>
$head
</head>
<body>
<header>
  <h1>$title</h1>
  <div class="sub">Computer: $($escapedComputer) &nbsp;&bull;&nbsp; User: $(Escape-Html("$env:USERNAME")) &nbsp;&bull;&nbsp; Generated: $(Escape-Html($now))</div>
</header>

<div class="wrap">
  <div class="panel">
    <div class="toolbar">
      <input id="searchBox" type="text" placeholder="Type to filter... (matches any column)">
      <div class="counts">
        <span class="pill">Total: <strong id="totalCount">$totalCount</strong></span>
        <span class="pill">Visible: <strong id="visibleCount">$totalCount</strong></span>
        <span class="pill">Established: <strong>$established</strong></span>
        <span class="pill">Listen: <strong>$listen</strong></span>
      </div>
      <span class="hint">Tip: click any header to sort (click again to reverse).</span>
    </div>

    <table id="netconns">
      $thead
      $tbody
    </table>

    <div class="footer">Report generated by PowerShell on $(Escape-Html($now.ToString('yyyy-MM-dd HH:mm:ss')))</div>
  </div>
</div>
</body>
</html>
"@

# Write out
try {
  $null = New-Item -ItemType Directory -Path (Split-Path -Parent $OutputPath) -Force
  $html | Out-File -FilePath $OutputPath -Encoding UTF8
  Write-Host "Report written to: $OutputPath" -ForegroundColor Green
  # Start-Process $OutputPath  # uncomment if you want it to auto-open
} catch {
  Write-Error "Failed to write HTML report: $($_.Exception.Message)"
}
