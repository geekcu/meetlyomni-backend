# Git hooks setup script
Write-Host "Setting up Git hooks..." -ForegroundColor Cyan

# Find Git repository root
$gitDir = & git rev-parse --show-toplevel 2>$null
if (-not $gitDir) {
    Write-Host "Error: Not in a Git repository" -ForegroundColor Red
    exit 1
}

$hooksDir = Join-Path $gitDir ".git/hooks"
if (-not (Test-Path $hooksDir)) {
    New-Item -ItemType Directory -Path $hooksDir -Force | Out-Null
    Write-Host "Created $hooksDir" -ForegroundColor Green
}

# Pre-commit hook content (Bash) ¨C format issues are WARN only
$preCommitContent = @'
#!/usr/bin/env bash

echo "Running dotnet format check..."
dotnet format MeetlyOmni.sln --verify-no-changes --no-restore
FORMAT_EXIT=$?
if [ $FORMAT_EXIT -ne 0 ]; then
  echo "[WARNING] Code formatting issues found. You may run 'dotnet format' to fix them."
  # Do NOT block the commit because of formatting
fi

echo "Building solution..."
dotnet build MeetlyOmni.sln --no-restore || exit 1

echo "Running unit tests..."
dotnet test MeetlyOmni.sln --no-build --filter "Category=Unit" || exit 1
'@

# Write pre-commit with LF endings (bash-friendly)
$hookPath = Join-Path $hooksDir "pre-commit"
[System.IO.File]::WriteAllText($hookPath, ($preCommitContent -replace "`r`n","`n"), [System.Text.Encoding]::ASCII)

Write-Host "Created pre-commit hook at $hookPath" -ForegroundColor Green
Write-Host "Git pre-commit hook set up successfully!" -ForegroundColor Cyan
