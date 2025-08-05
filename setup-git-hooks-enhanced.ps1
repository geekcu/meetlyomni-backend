# Enhanced Git hooks setup script with Controllers and Services coverage
Write-Host "Setting up enhanced Git hooks with Controllers and Services coverage..." -ForegroundColor Cyan

# Check if we're in a Git repository
if (-not (Test-Path .git)) {
    Write-Host "Error: Not in a Git repository" -ForegroundColor Red
    exit 1
}

Write-Host "Setting up enhanced Git hooks..."

# Ensure .git/hooks directory exists
if (-not (Test-Path .git/hooks)) {
    try {
        New-Item -ItemType Directory -Path .git/hooks -Force | Out-Null
        Write-Host "Created .git/hooks directory" -ForegroundColor Green
    } catch {
        Write-Host "Failed to create .git/hooks directory: $_" -ForegroundColor Red
        exit 1
    }
}

# Create pre-commit hook content
$preCommitContent = @'
#!/bin/sh
echo "Running dotnet format..."
dotnet format MeetlyOmni.sln || exit 1

echo "Building solution..."
dotnet build MeetlyOmni.sln --no-restore || exit 1

echo "Running tests..."
dotnet test MeetlyOmni.sln --no-build || exit 1
'@

# Create pre-push hook content for Windows (PowerShell)
$prePushContentPS = @'
# PowerShell version of pre-push hook for Controllers and Services coverage
param()

Write-Host "Running pre-push coverage check for Controllers and Services..." -ForegroundColor Cyan

# Create coverage directory if it doesn't exist
if (-not (Test-Path "coverage")) {
    New-Item -ItemType Directory -Path "coverage" -Force | Out-Null
}

# Create baseline directory if it doesn't exist
if (-not (Test-Path "coverage/baseline")) {
    New-Item -ItemType Directory -Path "coverage/baseline" -Force | Out-Null
}

# Note: Filtering is now done via reportgenerator parameters instead of filter file

# Run tests with coverage for specific assemblies
Write-Host "Running tests with coverage for Controllers and Services..." -ForegroundColor Yellow
dotnet test MeetlyOmni.sln --collect:"XPlat Code Coverage" --results-directory coverage --verbosity normal --filter "Category!=Integration"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Tests failed. Push blocked." -ForegroundColor Red
    exit 1
}

# Generate coverage report
Write-Host "Generating coverage report..." -ForegroundColor Yellow
reportgenerator -reports:coverage/*/coverage.cobertura.xml -targetdir:coverage/report -reporttypes:Html -assemblyfilters:"+MeetlyOmni.Api.Controllers*;+MeetlyOmni.Api.Service*" -classfilters:"+*Controllers*;+*Service*"

# Extract current coverage percentage
$coverageFile = Get-ChildItem -Path "coverage" -Filter "coverage.cobertura.xml" -Recurse | Select-Object -First 1
if ($coverageFile) {
    $content = Get-Content $coverageFile.FullName
    $lineRateMatch = $content | Select-String 'line-rate="([0-9.]+)"' | Select-Object -First 1
    if ($lineRateMatch) {
        $currentCoverage = [double]$lineRateMatch.Matches[0].Groups[1].Value
        $currentCoveragePercent = [math]::Round($currentCoverage * 100)
        
        Write-Host "Current coverage for Controllers and Services: ${currentCoveragePercent}%" -ForegroundColor Green
        
        # Check minimum threshold (80%)
        if ($currentCoveragePercent -lt 80) {
            Write-Host "Coverage below minimum threshold of 80%" -ForegroundColor Red
            Write-Host "Current coverage: ${currentCoveragePercent}%" -ForegroundColor Red
            Write-Host "Detailed report: coverage/report/index.html" -ForegroundColor Yellow
            Write-Host "Push blocked due to insufficient coverage." -ForegroundColor Red
            exit 1
        }
        
        # Check for regression against baseline
        Write-Host "Checking coverage regression..." -ForegroundColor Yellow
        
        # Get baseline coverage
        $baselineFile = "coverage/baseline/coverage.txt"
        $baselineCoverage = 0
        
        if (Test-Path $baselineFile) {
            $baselineCoverage = [double](Get-Content $baselineFile)
            $baselineCoveragePercent = [math]::Round($baselineCoverage * 100)
            Write-Host "Baseline coverage: ${baselineCoveragePercent}%" -ForegroundColor Cyan
            
            if ($currentCoveragePercent -lt $baselineCoveragePercent) {
                Write-Host "Coverage regression detected!" -ForegroundColor Red
                Write-Host "Baseline: ${baselineCoveragePercent}%" -ForegroundColor Red
                Write-Host "Current: ${currentCoveragePercent}%" -ForegroundColor Red
                Write-Host "Difference: -$($baselineCoveragePercent - $currentCoveragePercent)%" -ForegroundColor Red
                Write-Host "Detailed report: coverage/report/index.html" -ForegroundColor Yellow
                Write-Host "Push blocked due to coverage regression." -ForegroundColor Red
                Write-Host "To update baseline, run: .\check-coverage-enhanced.ps1 -UpdateBaseline" -ForegroundColor Yellow
                exit 1
            }
        } else {
            Write-Host "No baseline found. Creating initial baseline..." -ForegroundColor Yellow
            $currentCoverage | Out-File -FilePath $baselineFile -Encoding ASCII
            Write-Host "Initial baseline set to: ${currentCoveragePercent}%" -ForegroundColor Green
        }
        
        Write-Host "Coverage check passed!" -ForegroundColor Green
        Write-Host "Current coverage: ${currentCoveragePercent}%" -ForegroundColor Green
        Write-Host "Detailed report: coverage/report/index.html" -ForegroundColor Cyan
    } else {
        Write-Host "Could not extract coverage percentage" -ForegroundColor Red
        Write-Host "Push blocked due to coverage analysis failure." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "No coverage file found" -ForegroundColor Red
    Write-Host "Push blocked due to missing coverage data." -ForegroundColor Red
    exit 1
}
'@

# Create pre-push hook content for Unix/Linux (Bash)
$prePushContentUnix = @'
#!/bin/bash
# Pre-push Coverage Hook for Controllers and Services
# This script runs before git push and enforces coverage requirements

set -e

echo "Running pre-push coverage check for Controllers and Services..."

# Create coverage directory if it doesn't exist
mkdir -p coverage
mkdir -p coverage/baseline

# Note: Filtering is now done via reportgenerator parameters instead of filter file

# Run tests with coverage for specific assemblies
echo "Running tests with coverage for Controllers and Services..."
dotnet test MeetlyOmni.sln --collect:"XPlat Code Coverage" --results-directory coverage --verbosity normal --filter "Category!=Integration"

if [ $? -ne 0 ]; then
    echo "Tests failed. Push blocked."
    exit 1
fi

# Generate coverage report
echo "Generating coverage report..."
reportgenerator -reports:coverage/*/coverage.cobertura.xml -targetdir:coverage/report -reporttypes:Html -assemblyfilters:"+MeetlyOmni.Api.Controllers*;+MeetlyOmni.Api.Service*" -classfilters:"+*Controllers*;+*Service*"

# Extract current coverage percentage
COVERAGE_FILE=$(find coverage -name "coverage.cobertura.xml" | head -1)

if [ -n "$COVERAGE_FILE" ]; then
    CURRENT_COVERAGE=$(grep -o "line-rate=\"[0-9.]*\"" "$COVERAGE_FILE" | grep -o "[0-9.]*" | head -1)
    CURRENT_COVERAGE_PERCENT=$(echo "$CURRENT_COVERAGE * 100" | bc -l | cut -d. -f1)
    
    echo "Current coverage for Controllers and Services: ${CURRENT_COVERAGE_PERCENT}%"
    
    # Check minimum threshold (80%)
    if [ "$CURRENT_COVERAGE_PERCENT" -lt 80 ]; then
        echo "Coverage below minimum threshold of 80%"
        echo "Current coverage: ${CURRENT_COVERAGE_PERCENT}%"
        echo "Detailed report: coverage/report/index.html"
        echo "Push blocked due to insufficient coverage."
        exit 1
    fi
    
    # Check for regression against baseline
    echo "Checking coverage regression..."
    
    # Get baseline coverage
    BASELINE_FILE="coverage/baseline/coverage.txt"
    BASELINE_COVERAGE=0
    
    if [ -f "$BASELINE_FILE" ]; then
        BASELINE_COVERAGE=$(cat "$BASELINE_FILE")
        BASELINE_COVERAGE_PERCENT=$(echo "$BASELINE_COVERAGE * 100" | bc -l | cut -d. -f1)
        echo "Baseline coverage: ${BASELINE_COVERAGE_PERCENT}%"
        
        if [ "$CURRENT_COVERAGE_PERCENT" -lt "$BASELINE_COVERAGE_PERCENT" ]; then
            DIFFERENCE=$((BASELINE_COVERAGE_PERCENT - CURRENT_COVERAGE_PERCENT))
            echo "Coverage regression detected!"
            echo "Baseline: ${BASELINE_COVERAGE_PERCENT}%"
            echo "Current: ${CURRENT_COVERAGE_PERCENT}%"
            echo "Difference: -${DIFFERENCE}%"
            echo "Detailed report: coverage/report/index.html"
            echo "Push blocked due to coverage regression."
            echo "To update baseline, run: ./check-coverage-enhanced.sh --update-baseline"
            exit 1
        fi
    else
        echo "No baseline found. Creating initial baseline..."
        echo "$CURRENT_COVERAGE" > "$BASELINE_FILE"
        echo "Initial baseline set to: ${CURRENT_COVERAGE_PERCENT}%"
    fi
    
    echo "Coverage check passed!"
    echo "Current coverage: ${CURRENT_COVERAGE_PERCENT}%"
    echo "Detailed report: coverage/report/index.html"
else
    echo "No coverage file found"
    echo "Push blocked due to missing coverage data."
    exit 1
fi
'@

# Write pre-commit hook
try {
    $preCommitContent | Out-File -FilePath ".git/hooks/pre-commit" -Encoding ASCII
    Write-Host "Pre-commit hook created successfully!" -ForegroundColor Green
} catch {
    Write-Host "Failed to create pre-commit hook: $_" -ForegroundColor Red
    exit 1
}

# Write pre-push hooks for different platforms
try {
    # Unix/Linux version
    $prePushContentUnix | Out-File -FilePath ".git/hooks/pre-push" -Encoding ASCII
    
    # PowerShell version for Windows
    $prePushContentPS | Out-File -FilePath ".git/hooks/pre-push.ps1" -Encoding UTF8
    
    # Create Windows batch file to call PowerShell
    $prePushBatch = @'
@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0pre-push.ps1" %*
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
'@
    $prePushBatch | Out-File -FilePath ".git/hooks/pre-push.cmd" -Encoding ASCII
    
    # Make Unix script executable
    if ($IsLinux -or $IsMacOS) {
        chmod +x ".git/hooks/pre-push"
    }
    
    Write-Host "Pre-push hook created successfully!" -ForegroundColor Green
} catch {
    Write-Host "Failed to create pre-push hook: $_" -ForegroundColor Red
    exit 1
}

Write-Host "Enhanced Git hooks setup completed!" -ForegroundColor Green
Write-Host "Hooks will now automatically run:" -ForegroundColor Yellow
Write-Host "  Pre-commit:" -ForegroundColor White
Write-Host "    - Code formatting (dotnet format)" -ForegroundColor White
Write-Host "    - Build validation (dotnet build)" -ForegroundColor White
Write-Host "    - Unit testing (dotnet test)" -ForegroundColor White
Write-Host "  Pre-push:" -ForegroundColor White
Write-Host "    - Controllers and Services coverage check (≥80%)" -ForegroundColor White
Write-Host "    - Coverage regression prevention" -ForegroundColor White
Write-Host "    - Baseline tracking and comparison" -ForegroundColor White
Write-Host "    - Detailed coverage report generation" -ForegroundColor White
Write-Host ""
Write-Host "Manual coverage check commands:" -ForegroundColor Cyan
Write-Host "  Windows: .\check-coverage-enhanced.ps1" -ForegroundColor White
Write-Host "  Unix/Linux: ./check-coverage-enhanced.sh" -ForegroundColor White
Write-Host "  Update baseline: .\check-coverage-enhanced.ps1 -UpdateBaseline" -ForegroundColor White 