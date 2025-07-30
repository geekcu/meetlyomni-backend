# Enhanced Code Coverage Check Script
# This script runs coverage checks specifically for Controllers and Services
# with baseline tracking and regression prevention

param(
    [int]$MinThreshold = 80,
    [switch]$SkipRegressionCheck,
    [switch]$UpdateBaseline,
    [string]$TargetBranch = "origin/main"
)

Write-Host "Running enhanced code coverage check for Controllers and Services..." -ForegroundColor Cyan

# Create coverage directory if it doesn't exist
if (-not (Test-Path "coverage")) {
    New-Item -ItemType Directory -Path "coverage" -Force | Out-Null
}

# Create baseline directory if it doesn't exist
if (-not (Test-Path "coverage/baseline")) {
    New-Item -ItemType Directory -Path "coverage/baseline" -Force | Out-Null
}

# Define the assemblies to include in coverage (Controllers and Services)
$includeAssemblies = @(
    "src/MeetlyOmni.Api/Controllers/*.cs",
    "src/MeetlyOmni.Api/Service/*.cs"
)

# Note: Filtering is now done via reportgenerator parameters instead of filter file

# Run tests with coverage for specific assemblies
Write-Host "Running tests with coverage for Controllers and Services..." -ForegroundColor Yellow
dotnet test MeetlyOmni.sln --collect:"XPlat Code Coverage" --results-directory coverage --verbosity normal --filter "Category!=Integration"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Tests failed. Coverage check aborted." -ForegroundColor Red
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
        
        # Check minimum threshold
        if ($currentCoveragePercent -lt $MinThreshold) {
            Write-Host "Coverage below minimum threshold of ${MinThreshold}%" -ForegroundColor Red
            Write-Host "Current coverage: ${currentCoveragePercent}%" -ForegroundColor Red
            Write-Host "Detailed report: coverage/report/index.html" -ForegroundColor Yellow
            exit 1
        }
        
        # Handle baseline update
        if ($UpdateBaseline) {
            $baselineFile = "coverage/baseline/coverage.txt"
            $currentCoverage | Out-File -FilePath $baselineFile -Encoding ASCII
            Write-Host "Baseline updated to: ${currentCoveragePercent}%" -ForegroundColor Green
            exit 0
        }
        
        # Check for regression (unless skipped)
        if (-not $SkipRegressionCheck) {
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
                    Write-Host "To update baseline, run: .\check-coverage-enhanced.ps1 -UpdateBaseline" -ForegroundColor Yellow
                    exit 1
                }
            } else {
                Write-Host "No baseline found. Creating initial baseline..." -ForegroundColor Yellow
                $currentCoverage | Out-File -FilePath $baselineFile -Encoding ASCII
                Write-Host "Initial baseline set to: ${currentCoveragePercent}%" -ForegroundColor Green
            }
        }
        
        Write-Host "Coverage check passed!" -ForegroundColor Green
        Write-Host "Current coverage: ${currentCoveragePercent}%" -ForegroundColor Green
        Write-Host "Detailed report: coverage/report/index.html" -ForegroundColor Cyan
    } else {
        Write-Host "Could not extract coverage percentage" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "No coverage file found" -ForegroundColor Red
    exit 1
} 