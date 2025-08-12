# setup-git-hooks-simple.ps1
param(
  [string]$Solution = "MeetlyOmni.sln"
)

Write-Host "Setting up simplified Git hooks..." -ForegroundColor Cyan

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

# ---------- pre-push (simplified - format + build + tests only) ----------
$prePushPs1 = @'
param(
  [string]$Solution = "{SLN}"
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

Write-Host "[pre-push] Running unit tests..." -ForegroundColor Cyan
dotnet test $unitProj -c Release --no-build
if ($LASTEXITCODE -ne 0) { Fail "Unit tests failed." }

Write-Host "[pre-push] OK. All checks passed." -ForegroundColor Green
'@.Replace("{SLN}", $Solution)

Set-Content -Path ".git/hooks/pre-push.ps1" -Value $prePushPs1 -Encoding UTF8

# ---------- pre-push shim (bash) that calls the PowerShell script ----------
$prePushShim = @'
#!/bin/sh
if command -v pwsh >/dev/null 2>&1; then
  pwsh -NoLogo -NoProfile -File ".git/hooks/pre-push.ps1" --Solution "{SLN}"
elif command -v powershell >/dev/null 2>&1; then
  powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File ".git/hooks/pre-push.ps1" -Solution "{SLN}"
else
  echo "PowerShell not found. Please install PowerShell 7 (pwsh) or Windows PowerShell)."
  exit 1
fi
'@.Replace("{SLN}", $Solution)

Set-Content -Path ".git/hooks/pre-push" -Value $prePushShim -Encoding Ascii
try { git update-index --chmod=+x .git/hooks/pre-push | Out-Null } catch {}

Write-Host "Simplified Git hooks setup completed." -ForegroundColor Green
Write-Host " - pre-commit: auto-fix format + restage + fast build" -ForegroundColor White
Write-Host " - pre-push: verify-only format + build + unit tests (coverage disabled)" -ForegroundColor White
