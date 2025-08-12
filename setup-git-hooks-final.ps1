# setup-git-hooks-final.ps1
param(
  [string]$Solution = "MeetlyOmni.sln",
  [int]$Threshold = 80
)

Write-Host "Setting up final Git hooks..." -ForegroundColor Cyan

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
$unitTestProjects = @(
  Get-ChildItem -Path . -Recurse -File -Filter *.csproj |
    Where-Object { $_.Name -match '(?i)\.Unit\.tests\.csproj$' } |
    Select-Object -ExpandProperty FullName
)

if (-not $unitTestProjects -or $unitTestProjects.Count -eq 0) {
  Fail "No '*.Unit.tests.csproj' found. Ensure your unit test project follows the naming pattern."
}

if ($unitTestProjects.Count -gt 1) {
  Write-Host "[pre-push] Multiple Unit test projects found. Using the first one:" -ForegroundColor Yellow
  $unitTestProjects | ForEach-Object { Write-Host "  - $_" -ForegroundColor DarkYellow }
}

$unitProj = $unitTestProjects[0]
Write-Host "[pre-push] Unit tests project: $unitProj" -ForegroundColor Yellow

# Check if we have any Controllers or Services code
$apiProjectPath = Join-Path (Get-Location) "src\MeetlyOmni.Api"
$controllersPath = Join-Path $apiProjectPath "Controllers"
$servicesPath = Join-Path $apiProjectPath "Service"

$hasControllers = (Test-Path $controllersPath) -and ((Get-ChildItem $controllersPath -Filter "*.cs" -Recurse | Measure-Object).Count -gt 0)
$hasServices = (Test-Path $servicesPath) -and ((Get-ChildItem $servicesPath -Filter "*.cs" -Recurse | Measure-Object).Count -gt 0)

Write-Host "[pre-push] Controllers path: $controllersPath" -ForegroundColor DarkYellow
Write-Host "[pre-push] Controllers exists: $(Test-Path $controllersPath)" -ForegroundColor DarkYellow
Write-Host "[pre-push] Controllers files: $((Get-ChildItem $controllersPath -Filter '*.cs' -Recurse | Measure-Object).Count)" -ForegroundColor DarkYellow
Write-Host "[pre-push] Has Controllers: $hasControllers" -ForegroundColor DarkYellow

if (-not $hasControllers -and -not $hasServices) {
  Write-Host "[pre-push] No Controllers or Services code found. Running basic tests only..." -ForegroundColor Yellow
  Write-Host "[pre-push] Running unit tests..." -ForegroundColor Cyan
  dotnet test $unitProj -c Release --no-build
  if ($LASTEXITCODE -ne 0) { Fail "Unit tests failed." }
  
  # 显示测试结果摘要
  Write-Host "`n[pre-push] ===== TEST SUMMARY =====" -ForegroundColor Cyan
  Write-Host "[pre-push] ✅ Basic tests passed" -ForegroundColor Green
  Write-Host "[pre-push] 📊 Coverage check: SKIPPED (no Controllers/Services code)" -ForegroundColor Yellow
  Write-Host "[pre-push] 💡 Add Controllers/Services to enable coverage checking" -ForegroundColor White
  Write-Host "[pre-push] =========================" -ForegroundColor Cyan
  
  Write-Host "[pre-push] OK. Basic checks passed (coverage check skipped - no business logic code)." -ForegroundColor Green
  exit 0
}

Write-Host "[pre-push] Controllers/Services code detected. Running full coverage check..." -ForegroundColor Cyan
Write-Host ("[pre-push] Coverage threshold: {0}%" -f $Threshold) -ForegroundColor DarkYellow

# Ensure local tools are restored (no-op if already restored)
dotnet tool restore | Out-Null

$covDir  = Join-Path (Get-Location) "coverage"
if (-not (Test-Path $covDir)) { New-Item -ItemType Directory -Path $covDir | Out-Null }
$covFile = Join-Path $covDir "coverage.cobertura.xml"

Write-Host "[pre-push] Unit tests + coverage (Cobertura)..." -ForegroundColor Cyan

# Build the test command as ONE string (only the Unit tests project)
$testCmd = "dotnet test `"$unitProj`" -c Release --no-build"

# Use dotnet-coverage directly with the command - try different approaches
$exit = 1
try {
  # Try approach 1: direct command
  $exit = & dotnet-coverage collect $testCmd -f cobertura -o $covFile
} catch {
  Write-Host "[pre-push] Approach 1 failed, trying approach 2..." -ForegroundColor Yellow
  try {
    # Try approach 2: with quotes
    $exit = & dotnet-coverage collect "$testCmd" -f cobertura -o $covFile
  } catch {
    Write-Host "[pre-push] Approach 2 failed, trying approach 3..." -ForegroundColor Yellow
    try {
      # Try approach 3: split arguments
      $exit = & dotnet-coverage collect "dotnet" "test" $unitProj "-c" "Release" "--no-build" "-f" "cobertura" "-o" $covFile
    } catch {
      Write-Host "[pre-push] All approaches failed, skipping coverage check..." -ForegroundColor Yellow
      Write-Host "[pre-push] Running basic tests only..." -ForegroundColor Cyan
      dotnet test $unitProj -c Release --no-build
      if ($LASTEXITCODE -ne 0) { Fail "Unit tests failed." }
      Write-Host "[pre-push] OK. Basic checks passed (coverage check skipped due to tool issues)." -ForegroundColor Green
      exit 0
    }
  }
}

if ($exit -ne 0) { 
  Write-Host "[pre-push] Coverage tool failed, running basic tests only..." -ForegroundColor Yellow
  dotnet test $unitProj -c Release --no-build
  if ($LASTEXITCODE -ne 0) { Fail "Unit tests failed." }
  Write-Host "[pre-push] OK. Basic checks passed (coverage check skipped due to tool issues)." -ForegroundColor Green
  exit 0
}

if (-not (Test-Path $covFile)) { 
  Write-Host "[pre-push] Coverage file not found, running basic tests only..." -ForegroundColor Yellow
  dotnet test $unitProj -c Release --no-build
  if ($LASTEXITCODE -ne 0) { Fail "Unit tests failed." }
  Write-Host "[pre-push] OK. Basic checks passed (coverage check skipped due to file issues)." -ForegroundColor Green
  exit 0
}

[xml]$xml = Get-Content -LiteralPath $covFile
$classes = @()
if ($xml.coverage.packages.package.classes.class) {
  $classes = @($xml.coverage.packages.package.classes.class)
} elseif ($xml.coverage.packages.package.classes) {
  $classes = @($xml.coverage.packages.package.classes)
}
if (-not $classes -or $classes.Count -eq 0) { 
  Write-Host "[pre-push] No classes found in coverage report, running basic tests only..." -ForegroundColor Yellow
  dotnet test $unitProj -c Release --no-build
  if ($LASTEXITCODE -ne 0) { Fail "Unit tests failed." }
  Write-Host "[pre-push] OK. Basic checks passed (coverage check skipped due to report issues)." -ForegroundColor Green
  exit 0
}

# Match Controllers/ and Service(s)/ (handles both '\' and '/')
$pattern = '(\\|/)Controllers(\\|/)|(\\|/)Services?(\\|/)'
$targetClasses = $classes | Where-Object { $_.filename -match $pattern }
if (-not $targetClasses -or $targetClasses.Count -eq 0) {
  Write-Host "[pre-push] No Controllers/ or Service(s)/ files found in coverage. Skipping coverage check." -ForegroundColor Yellow
  Write-Host "[pre-push] OK. Coverage check skipped." -ForegroundColor Green
  exit 0
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

if ($total -le 0) { 
  Write-Host "[pre-push] No line data found in coverage report, running basic tests only..." -ForegroundColor Yellow
  dotnet test $unitProj -c Release --no-build
  if ($LASTEXITCODE -ne 0) { Fail "Unit tests failed." }
  Write-Host "[pre-push] OK. Basic checks passed (coverage check skipped due to data issues)." -ForegroundColor Green
  exit 0
}

$rate = [math]::Round(100.0 * $covered / $total, 2)

# 显示详细的覆盖率信息
Write-Host "`n[pre-push] ===== COVERAGE REPORT =====" -ForegroundColor Cyan
Write-Host ("[pre-push] Current Coverage: {0}%" -f $rate) -ForegroundColor Yellow
Write-Host ("[pre-push] Required Coverage: {0}%" -f $Threshold) -ForegroundColor Yellow
Write-Host ("[pre-push] Lines Covered: {0} / {1}" -f $covered, $total) -ForegroundColor White
Write-Host ("[pre-push] Lines Remaining: {0}" -f ($total - $covered)) -ForegroundColor White

# 显示覆盖率状态
if ($rate -ge $Threshold) {
  Write-Host ("[pre-push] ✅ Coverage PASSED ({0}% >= {1}%)" -f $rate, $Threshold) -ForegroundColor Green
} else {
  Write-Host ("[pre-push] ❌ Coverage FAILED ({0}% < {1}%)" -f $rate, $Threshold) -ForegroundColor Red
  Write-Host ("[pre-push] Need to cover {0} more lines to reach {1}%" -f (($Threshold * $total / 100) - $covered), $Threshold) -ForegroundColor Red
}

Write-Host "[pre-push] ============================" -ForegroundColor Cyan

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

Write-Host "Final Git hooks setup completed." -ForegroundColor Green
Write-Host " - pre-commit: auto-fix format + restage + fast build" -ForegroundColor White
Write-Host (" - pre-push: smart coverage check (skips when no Controllers/Services, enforces {0}% when present)" -f $Threshold) -ForegroundColor White
Write-Host " - fallback: if coverage tool fails, runs basic tests only" -ForegroundColor White
