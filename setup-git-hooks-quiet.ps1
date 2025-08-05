# Quiet Git hooks setup script - Minimal output version
Write-Host "Setting up quiet Git hooks..." -ForegroundColor Cyan

# Check if we're in a Git repository
if (-not (Test-Path .git)) {
    Write-Host "Error: Not in a Git repository" -ForegroundColor Red
    exit 1
}

# Ensure .git/hooks directory exists
if (-not (Test-Path .git/hooks)) {
    try {
        New-Item -ItemType Directory -Path .git/hooks -Force | Out-Null
    } catch {
        Write-Host "Failed to create .git/hooks directory: $_" -ForegroundColor Red
        exit 1
    }
}

# Create pre-commit hook content (quiet version)
$preCommitContent = @'
#!/bin/sh
echo "Running pre-commit checks..."
dotnet format MeetlyOmni.sln --verbosity quiet >/dev/null 2>&1 || exit 1
dotnet build MeetlyOmni.sln --no-restore --verbosity quiet >/dev/null 2>&1 || exit 1
dotnet test MeetlyOmni.sln --no-build --filter "Category!=Integration" --verbosity quiet --logger "console;verbosity=quiet" >/dev/null 2>&1 || exit 1
echo "Pre-commit checks passed!"
'@

# Create pre-push hook content for Windows (PowerShell) - Quiet version
$prePushContentPS = @'
# Quiet PowerShell version of pre-push hook
param([string]$TargetBranch = "origin/main")

# Suppress all output except essential messages
$ErrorActionPreference = "SilentlyContinue"

# Create directories silently
if (-not (Test-Path "coverage")) { New-Item -ItemType Directory -Path "coverage" -Force | Out-Null }
if (-not (Test-Path "coverage/baseline")) { New-Item -ItemType Directory -Path "coverage/baseline" -Force | Out-Null }

# Run tests with maximum quiet settings
dotnet test MeetlyOmni.sln --collect:"XPlat Code Coverage" --results-directory coverage --verbosity quiet --filter "Category=Unit" --logger "console;verbosity=quiet" --nologo --no-restore --no-build >$null 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Tests failed. Push blocked." -ForegroundColor Red
    exit 1
}

# Generate coverage report silently
reportgenerator -reports:coverage/*/coverage.cobertura.xml -targetdir:coverage/report -reporttypes:Html -assemblyfilters:"+MeetlyOmni.Api.Controllers*;+MeetlyOmni.Api.Service*" -classfilters:"+*Controllers*;+*Service*" >$null 2>&1

# Extract coverage data silently
$coverageFile = Get-ChildItem -Path "coverage" -Filter "coverage.cobertura.xml" -Recurse | Select-Object -First 1
if ($coverageFile) {
    [xml]$coverageXml = Get-Content $coverageFile.FullName
    $totalLines = 0
    $coveredLines = 0
    
    foreach ($package in $coverageXml.coverage.packages.package) {
        foreach ($class in $package.classes.class) {
            if ($class.name -match '\.(Controllers|Service)\.') {
                foreach ($line in $class.lines.line) {
                    $totalLines++
                    if ([int]$line.hits -gt 0) { $coveredLines++ }
                }
            }
        }
    }
    
    if ($totalLines -eq 0) {
        Write-Host "No coverage data found. Push blocked." -ForegroundColor Red
        exit 1
    }
    
    $currentCoverage = $coveredLines / $totalLines
    $currentCoveragePercent = [math]::Round($currentCoverage * 100)
    
    # Only show coverage if it's below threshold or there's an issue
    if ($currentCoveragePercent -lt 80) {
        Write-Host "Coverage: ${currentCoveragePercent}% (below 80%). Push blocked." -ForegroundColor Red
        exit 1
    }
    
    # Check baseline regression
    $baselineFile = "coverage/baseline/coverage.txt"
    if (Test-Path $baselineFile) {
        $baselineCoverage = [double](Get-Content $baselineFile)
        $baselineCoveragePercent = [math]::Round($baselineCoverage * 100)
        
        if ($currentCoveragePercent -lt $baselineCoveragePercent) {
            Write-Host "Coverage regression: ${currentCoveragePercent}% < ${baselineCoveragePercent}%. Push blocked." -ForegroundColor Red
            exit 1
        }
    } else {
        $currentCoverage | Out-File -FilePath $baselineFile -Encoding ASCII
    }
    
    # Success - minimal output
    Write-Host "Coverage check passed (${currentCoveragePercent}%)" -ForegroundColor Green
} else {
    Write-Host "No coverage file found. Push blocked." -ForegroundColor Red
    exit 1
}
'@

# Create pre-push hook content for Unix/Linux (Bash) - Quiet version
$prePushContentUnix = @'
#!/bin/bash
set -e

# Suppress all output
exec 1>/dev/null 2>&1

# Create directories
mkdir -p coverage/baseline

# Run tests silently
dotnet test MeetlyOmni.sln --collect:"XPlat Code Coverage" --results-directory coverage --verbosity quiet --filter "Category=Unit" --logger "console;verbosity=quiet" --nologo --no-restore --no-build

if [ $? -ne 0 ]; then
    echo "Tests failed. Push blocked."
    exit 1
fi

# Generate coverage report silently
reportgenerator -reports:coverage/*/coverage.cobertura.xml -targetdir:coverage/report -reporttypes:Html -assemblyfilters:"+MeetlyOmni.Api.Controllers*;+MeetlyOmni.Api.Service*" -classfilters:"+*Controllers*;+*Service*"

# Extract coverage data
COVERAGE_FILE=$(find coverage -name "coverage.cobertura.xml" | head -1)

if [ -n "$COVERAGE_FILE" ]; then
    TOTAL_LINES=0
    COVERED_LINES=0
    
    while IFS= read -r line; do
        if [[ $line =~ class.*name=.*\.(Controllers|Service)\. ]]; then
            while IFS= read -r class_line; do
                if [[ $class_line =~ line.*number=.*hits= ]]; then
                    TOTAL_LINES=$((TOTAL_LINES + 1))
                    if [[ $class_line =~ hits=\"([0-9]+)\" ]] && [ "${BASH_REMATCH[1]}" -gt 0 ]; then
                        COVERED_LINES=$((COVERED_LINES + 1))
                    fi
                fi
            done < <(xmllint --xpath "//class[@name='$line']//line" "$COVERAGE_FILE" 2>/dev/null || echo "")
        fi
    done < <(xmllint --xpath "//class/@name" "$COVERAGE_FILE" 2>/dev/null | grep -o 'name="[^"]*"' | grep -E '\.(Controllers|Service)\.' || echo "")
    
    if [ "$TOTAL_LINES" -eq 0 ]; then
        echo "No coverage data found. Push blocked."
        exit 1
    fi
    
    CURRENT_COVERAGE=$(echo "scale=4; $COVERED_LINES / $TOTAL_LINES" | bc -l)
    CURRENT_COVERAGE_PERCENT=$(echo "$CURRENT_COVERAGE * 100" | bc -l | cut -d. -f1)
    
    if [ "$CURRENT_COVERAGE_PERCENT" -lt 80 ]; then
        echo "Coverage: ${CURRENT_COVERAGE_PERCENT}% (below 80%). Push blocked."
        exit 1
    fi
    
    BASELINE_FILE="coverage/baseline/coverage.txt"
    if [ -f "$BASELINE_FILE" ]; then
        BASELINE_COVERAGE=$(cat "$BASELINE_FILE")
        if ! echo "$BASELINE_COVERAGE" | grep -qE '^[0-9]+\.?[0-9]*$'; then
            echo "$CURRENT_COVERAGE" > "$BASELINE_FILE"
            exit 0
        fi
        BASELINE_COVERAGE_PERCENT=$(echo "$BASELINE_COVERAGE * 100" | bc -l | cut -d. -f1)
        
        if [ "$CURRENT_COVERAGE_PERCENT" -lt "$BASELINE_COVERAGE_PERCENT" ]; then
            echo "Coverage regression: ${CURRENT_COVERAGE_PERCENT}% < ${BASELINE_COVERAGE_PERCENT}%. Push blocked."
            exit 1
        fi
    else
        echo "$CURRENT_COVERAGE" > "$BASELINE_FILE"
    fi
    
    echo "Coverage check passed (${CURRENT_COVERAGE_PERCENT}%)"
else
    echo "No coverage file found. Push blocked."
    exit 1
fi
'@

# Write hooks
try {
    $preCommitContent | Out-File -FilePath ".git/hooks/pre-commit" -Encoding ASCII
    
    # Unix/Linux version
    $prePushContentUnix | Out-File -FilePath ".git/hooks/pre-push" -Encoding ASCII
    
    # PowerShell version for Windows
    $prePushContentPS | Out-File -FilePath ".git/hooks/pre-push.ps1" -Encoding UTF8
    
    # Windows batch file
    $prePushBatch = @'
@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0pre-push.ps1" %* >nul 2>&1
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
'@
    $prePushBatch | Out-File -FilePath ".git/hooks/pre-push.cmd" -Encoding ASCII
    
    # Make Unix script executable
    if ($IsLinux -or $IsMacOS) {
        chmod +x ".git/hooks/pre-push"
    }
    
    Write-Host "Quiet Git hooks setup completed!" -ForegroundColor Green
    Write-Host "Hooks will run silently with minimal output." -ForegroundColor Yellow
} catch {
    Write-Host "Failed to create hooks: $_" -ForegroundColor Red
    exit 1
} 