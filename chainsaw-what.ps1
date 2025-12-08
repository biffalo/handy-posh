<#
.SYNOPSIS
    Automate a Chainsaw hunt on the current system using local Windows event logs.

.DESCRIPTION
    - Prompts for how many days back to search
    - Prompts for Sigma rule level (critical/high/medium/all)
    - Determines which Chainsaw binary is present
    - Builds proper --from / --to ISO datetime strings
    - Saves each run to a timestamped output folder
#>

# Ensure we're in the script's directory
Set-Location -Path $PSScriptRoot

# Identify valid Chainsaw binary
$possibleBins = @(
    "chainsaw.exe",
    "chainsaw_x86_64-pc-windows-msvc.exe"
)

$ChainsawPath = $null

foreach ($bin in $possibleBins) {
    $testPath = Join-Path $PSScriptRoot $bin
    if (Test-Path $testPath) {
        $ChainsawPath = $testPath
        break
    }
}

if (-not $ChainsawPath) {
    Write-Host "ERROR: No Chainsaw binary found!" -ForegroundColor Red
    Write-Host "Expected one of:" -ForegroundColor Yellow
    $possibleBins | ForEach-Object { Write-Host "  - $_" -ForegroundColor DarkYellow }
    return
}

Write-Host "Using Chainsaw binary: $(Split-Path $ChainsawPath -Leaf)" -ForegroundColor Cyan

# Prompt for days back (with validation)
do {
    Write-Host "How many days back would you like to search?" -ForegroundColor Magenta
    $daysInput = Read-Host "Enter a number of days (e.g. 1, 3, 7)"
    $isInt = [int]::TryParse($daysInput, [ref]$null)
    if (-not $isInt -or [int]$daysInput -lt 0) {
        Write-Host "Please enter a valid non-negative integer." -ForegroundColor Yellow
    }
} until ($isInt -and [int]$daysInput -ge 0)

$days = [int]$daysInput

# Build date/time range
$now  = Get-Date
$from = $now.AddDays(-$days).ToString("yyyy-MM-dd")
$to   = $now.ToString("yyyy-MM-dd")
$time = $now.ToString("HH:mm:ss")

$fromStamp = "{0}T{1}" -f $from, $time
$toStamp   = "{0}T{1}" -f $to,   $time

# Select Sigma rule level
Write-Host ""
Write-Host "Please select what level of Sigma rules to use:" -ForegroundColor Magenta
Write-Host "1. Critical" -ForegroundColor DarkRed
Write-Host "2. High"     -ForegroundColor Red
Write-Host "3. Medium"   -ForegroundColor Yellow
Write-Host "4. ALL"      -ForegroundColor Green

$validSelection = $false
while (-not $validSelection) {
    $selection = Read-Host "Enter a number (1-4)"
    switch ($selection) {
        '1' { $level = 'critical'; $validSelection = $true }
        '2' { $level = 'high';     $validSelection = $true }
        '3' { $level = 'medium';   $validSelection = $true }
        '4' { $level = 'all';      $validSelection = $true }
        default {
            Write-Host "Invalid selection. Please enter a number between 1 and 4." -ForegroundColor Yellow
        }
    }
}

Write-Host ""
if ($level -eq 'all') {
    Write-Host "You selected ALL Sigma rule levels." -ForegroundColor Magenta
} else {
    Write-Host "You selected --level $level" -ForegroundColor Magenta
}

# Build output folder name
$timestamp = $now.ToString("yyyyMMdd-HHmmss")
$outputDir = "results-$($level)-$($timestamp)"

# Build Chainsaw arguments
$chainsawArgs = @(
    'hunt', 'C:\Windows\System32\winevt\Logs'
    '-s', 'sigma/rules/'
    '-r', 'rules/'
    '--mapping', '.\mappings\sigma-event-logs-all.yml'
    '--from', $fromStamp
    '--to',   $toStamp
    '--csv'
    '--output', $outputDir
    '--skip-errors'
)

if ($level -ne 'all') {
    $chainsawArgs += '--level'
    $chainsawArgs += $level
}

Write-Host ""
Write-Host "Running Chainsaw with the following parameters:" -ForegroundColor Cyan
Write-Host "  Binary: $ChainsawPath"
Write-Host "  From:   $fromStamp"
Write-Host "  To:     $toStamp"
Write-Host "  Level:  $level"
Write-Host "  Output: $outputDir"
Write-Host ""

# Execute Chainsaw
& $ChainsawPath @chainsawArgs
$exitCode = $LASTEXITCODE

Write-Host ""
if ($exitCode -eq 0) {
    Write-Host "Chainsaw completed successfully. Results saved in '$outputDir'." -ForegroundColor Green
} else {
    Write-Host "Chainsaw exited with code $exitCode. Check the output for details." -ForegroundColor Red
}
