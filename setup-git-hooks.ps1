# setup-hooks.ps1
param(
  [string]$Solution = "MeetlyOmni.sln",
  [int]$Threshold = 80
)

Write-Host "Setting up Git hooks..." -ForegroundColor Cyan

if (-not (Test-Path .git)) {
  Write-Host "Error: Not in a Git repository." -ForegroundColor Red
  exit 1
}

# Ensure hooks directory exists
if (-not (Test-Path .git/hooks)) {
  New-Item -ItemType Directory -Path .git/hooks -Force | Out-Null
  Write-Host "Created .git/hooks" -ForegroundColor Green
}

# ---------- pre-commit (auto-fix format + restage + fast build) ----------
$preCommit = @'
#!/bin/sh
echo "[pre-commit] dotnet format (auto-fix)..."
dotnet format || exit 1

echo "[pre-commit] re-stage formatted files..."
git add -A || exit 1

echo "[pre-commit] fast build (no restore)..."
dotnet build {SLN} --nologo --no-restore || exit 1

echo "[pre-commit] OK."
'@.Replace("{SLN}", $Solution)

Set-Content -Path ".git/hooks/pre-commit" -Value $preCommit -Encoding Ascii
try { git update-index --chmod=+x .git/hooks/pre-commit | Out-Null } catch {}

# ---------- pre-push PowerShell core logic ----------
$prePushPs1 = @'
param(
  [string]$Solution = "{SLN}",
  [int]$Threshold = {THRESHOLD}
)

function Fail($msg) { Write-Host $msg -ForegroundColor Red; exit 1 }

Write-Host "[pre-push] Verify format only..." -ForegroundColor Cyan
dotnet format --verify-no-changes
if ($LASTEXITCODE -ne 0) {
  Fail "Formatting issues found. Run 'dotnet format' locally and re-push."
}

Write-Host "[pre-push] Build (Release, no-restore)..." -ForegroundColor Cyan
dotnet build $Solution -c Release --nologo --no-restore
if ($LASTEXITCODE -ne 0) { Fail "Build failed." }

# --- locate Unit Test project(s) only (case-insensitive '*.Unit.tests.csproj') ---
$unitTestProjects = Get-ChildItem -Path . -Recurse -File -Filter *.csproj |
  Where-Object { $_.Name -match '(?i)\.Unit\.tests\.csproj$' } |
  Select-Object -ExpandProperty FullName

if (-not $unitTestProjects -or $unitTestProjects.Count -eq 0) {
  Fail "No '*.Unit.tests.csproj' found. Ensure your unit test project follows the naming pattern."
}
if ($unitTestProjects.Count -gt 1) {
  Write-Host "[pre-push] Multiple Unit test projects found. Using the first one:" -ForegroundColor Yellow
  $unitTestProjects | ForEach-Object { Write-Host "  - $_" -ForegroundColor DarkYellow }
}
$unitProj = $unitTestProjects[0]
Write-Host "[pre-push] Unit tests project: $unitProj" -ForegroundColor Yellow

# Prefer local dotnet tool; fallback to global
function RunCoverage {
  param([string[]]$Args)
  # Try local tool
  & dotnet @("tool","run","dotnet-coverage") @Args
  if ($LASTEXITCODE -eq 0) { return 0 }
  # Fallback to global
  if (Get-Command dotnet-coverage -ErrorAction SilentlyContinue) {
    & dotnet-coverage @Args
    return $LASTEXITCODE
  }
  Write-Host "dotnet-coverage not found (local or global)." -ForegroundColor Red
  return 1
}

# Ensure local tools are restored (no-op if already restored)
dotnet tool restore | Out-Null

$covDir  = Join-Path (Get-Location) "coverage"
if (-not (Test-Path $covDir)) { New-Item -ItemType Directory -Path $covDir | Out-Null }
$covFile = Join-Path $covDir "coverage.cobertura.xml"

Write-Host "[pre-push] Unit tests + coverage (Cobertura)..." -ForegroundColor Cyan

# Build the test command as ONE string (only the Unit tests project)
$testCmd = "dotnet test `"$unitProj`" -c Release --no-build"

# dotnet-coverage: pass the command as a single argument to 'collect'
$covArgs = @(
  "collect",
  $testCmd,
  "-f","cobertura",
  "-o",$covFile
)

$exit = RunCoverage -Args $covArgs
if ($exit -ne 0) { Fail "dotnet-coverage or tests failed." }
if (-not (Test-Path $covFile)) { Fail "Coverage file not found: $covFile" }

[xml]$xml = Get-Content -LiteralPath $covFile
$classes = @()
if ($xml.coverage.packages.package.classes.class) {
  $classes = @($xml.coverage.packages.package.classes.class)
} elseif ($xml.coverage.packages.package.classes) {
  $classes = @($xml.coverage.packages.package.classes)
}
if (-not $classes -or $classes.Count -eq 0) { Fail "No classes found in coverage report." }

# Match Controllers/ and Service(s)/ (handles both '\' and '/')
$pattern = '(\\|/)Controllers(\\|/)|(\\|/)Services?(\\|/)'
$targetClasses = $classes | Where-Object { $_.filename -match $pattern }
if (-not $targetClasses -or $targetClasses.Count -eq 0) {
  Fail "No files under Controllers/ or Service(s)/ matched in coverage. Check paths."
}

$total = 0; $covered = 0
foreach ($cls in $targetClasses) {
  if ($cls.lines -and $cls.lines.line) {
    $lines = @($cls.lines.line)
    $total += $lines.Count
    $covered += (@($lines | Where-Object { [int]($_.hits) -gt 0 })).Count
  } elseif ($cls.'line-rate') {
    # Rare fallback
    $total += 100
    $covered += [int](100 * [double]$cls.'line-rate')
  }
}

if ($total -le 0) { Fail "No line data found in coverage report (total=0)." }
$rate = [math]::Round(100.0 * $covered / $total, 2)
Write-Host ("[pre-push] Controllers/Services coverage: {0}% (covered {1} / total {2})" -f $rate, $covered, $total) -ForegroundColor Yellow

if ($rate -lt $Threshold) {
  Fail ("Coverage below threshold {0}% < {1}% on Controllers/Services." -f $rate, $Threshold)
}

Write-Host "[pre-push] OK. Coverage gate passed." -ForegroundColor Green
'@.Replace("{SLN}", $Solution).Replace("{THRESHOLD}", "$Threshold")

Set-Content -Path ".git/hooks/pre-push.ps1" -Value $prePushPs1 -Encoding UTF8

# ---------- pre-push shim (bash) that calls the PowerShell script ----------
$prePushShim = @'
#!/bin/sh
if command -v pwsh >/dev/null 2>&1; then
  pwsh -NoLogo -NoProfile -File ".git/hooks/pre-push.ps1" --Solution "{SLN}" --Threshold {THRESHOLD}
elif command -v powershell >/dev/null 2>&1; then
  powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File ".git/hooks/pre-push.ps1" -Solution "{SLN}" -Threshold {THRESHOLD}
else
  echo "PowerShell not found. Please install PowerShell 7 (pwsh) or Windows PowerShell)."
  exit 1
fi
'@.Replace("{SLN}", $Solution).Replace("{THRESHOLD}", "$Threshold")

Set-Content -Path ".git/hooks/pre-push" -Value $prePushShim -Encoding Ascii
try { git update-index --chmod=+x .git/hooks/pre-push | Out-Null } catch {}

Write-Host "Git hooks setup completed." -ForegroundColor Green
Write-Host " - pre-commit: auto-fix format + restage + fast build" -ForegroundColor White
Write-Host " - pre-push: verify-only format + Unit tests + coverage >= $Threshold% (Controllers/Services)" -ForegroundColor White
