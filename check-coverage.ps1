# Code coverage check script
# Run this script to manually check code coverage locally

param(
    [int]$MinThreshold = 80,
    [switch]$SkipRegressionCheck
)

Write-Host "Running code coverage check..." -ForegroundColor Cyan

# Create coverage directory if it doesn't exist
if (-not (Test-Path "coverage")) {
    New-Item -ItemType Directory -Path "coverage" -Force | Out-Null
}

# Run tests with coverage
Write-Host "Running tests with coverage..." -ForegroundColor Yellow
dotnet test MeetlyOmni.sln --collect:"XPlat Code Coverage" --results-directory coverage --verbosity normal

if ($LASTEXITCODE -ne 0) {
    Write-Host "Tests failed. Coverage check aborted." -ForegroundColor Red
    exit 1
}

# Generate coverage report
Write-Host "Generating coverage report..." -ForegroundColor Yellow
reportgenerator -reports:coverage/*/coverage.cobertura.xml -targetdir:coverage/report -reporttypes:Html

# Extract current coverage percentage
$coverageFile = Get-ChildItem -Path "coverage" -Filter "coverage.cobertura.xml" -Recurse | Select-Object -First 1
if ($coverageFile) {
    $content = Get-Content $coverageFile.FullName
    $lineRateMatch = $content | Select-String 'line-rate="([0-9.]+)"' | Select-Object -First 1
    if ($lineRateMatch) {
        $currentCoverage = [double]$lineRateMatch.Matches[0].Groups[1].Value
        $currentCoveragePercent = [math]::Round($currentCoverage * 100)
        
        Write-Host "Current coverage: ${currentCoveragePercent}%" -ForegroundColor Green
        
        # Check minimum threshold
        if ($currentCoveragePercent -lt $MinThreshold) {
            Write-Host "Coverage below minimum threshold of ${MinThreshold}%" -ForegroundColor Red
            Write-Host "Current coverage: ${currentCoveragePercent}%" -ForegroundColor Red
            Write-Host "Detailed report: coverage/report/index.html" -ForegroundColor Yellow
            exit 1
        }
        
        # Check for regression (unless skipped)
        if (-not $SkipRegressionCheck) {
            Write-Host "Checking coverage regression..." -ForegroundColor Yellow
            git fetch origin
            $previousCoverageFile = "coverage/coverage.txt"
            $previousCoverage = 0
            
            if (Test-Path $previousCoverageFile) {
                $previousCoverage = [double](Get-Content $previousCoverageFile)
                $previousCoveragePercent = [math]::Round($previousCoverage * 100)
                Write-Host "Previous coverage: ${previousCoveragePercent}%" -ForegroundColor Cyan
                
                if ($currentCoveragePercent -lt $previousCoveragePercent) {
                    Write-Host "Coverage regression detected!" -ForegroundColor Red
                    Write-Host "Previous: ${previousCoveragePercent}%" -ForegroundColor Red
                    Write-Host "Current: ${currentCoveragePercent}%" -ForegroundColor Red
                    Write-Host "Detailed report: coverage/report/index.html" -ForegroundColor Yellow
                    exit 1
                }
            }
        }
        
        # Save current coverage for future comparison
        $currentCoverage | Out-File -FilePath "coverage/coverage.txt" -Encoding ASCII
        
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