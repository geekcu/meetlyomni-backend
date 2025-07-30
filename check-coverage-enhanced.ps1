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

# Run tests with coverage using dotnet-coverage
Write-Host "Running tests with coverage for Controllers and Services..." -ForegroundColor Yellow
dotnet-coverage collect -o coverage.xml -f cobertura dotnet test --no-build

if ($LASTEXITCODE -ne 0) {
    Write-Host "Tests failed. Coverage check aborted." -ForegroundColor Red
    exit 1
}

# Generate coverage report
Write-Host "Generating coverage report..." -ForegroundColor Yellow
reportgenerator -reports:coverage.xml -targetdir:coverage/report -reporttypes:Html

# Extract current coverage percentage for Controllers and Services only
$coverageFile = "coverage.xml"
if (Test-Path $coverageFile) {
    $content = Get-Content $coverageFile
    
    # Find all Controllers and Services classes
    $controllerServiceClasses = $content | Select-String 'class.*name="([^"]*\.(Controllers|Service)\.[^"]*)"' | ForEach-Object { $_.Matches[0].Groups[1].Value }
    
    if ($controllerServiceClasses.Count -eq 0) {
        Write-Host "No Controllers or Services found in coverage data" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Found Controllers and Services classes: $($controllerServiceClasses -join ', ')" -ForegroundColor Cyan
    
    # Calculate coverage for Controllers and Services only
    $totalLines = 0
    $coveredLines = 0
    
    foreach ($class in $controllerServiceClasses) {
        Write-Host "Processing class: $class" -ForegroundColor Yellow
        
        # Find the class section in the XML
        $classStartIndex = -1
        for ($i = 0; $i -lt $content.Count; $i++) {
            if ($content[$i] -match "class.*name=`"$class`"") {
                $classStartIndex = $i
                break
            }
        }
        
        if ($classStartIndex -ge 0) {
            # Find the lines section for this class
            $linesStartIndex = -1
            $linesEndIndex = -1
            
            for ($i = $classStartIndex; $i -lt $content.Count; $i++) {
                if ($content[$i] -match '<lines>') {
                    $linesStartIndex = $i
                }
                if ($content[$i] -match '</lines>') {
                    $linesEndIndex = $i
                    break
                }
            }
            
            if ($linesStartIndex -ge 0 -and $linesEndIndex -ge 0) {
                $linesSection = $content[($linesStartIndex + 1)..($linesEndIndex - 1)]
                
                foreach ($line in $linesSection) {
                    if ($line -match '<line number="([0-9]+)" hits="([0-9]+)"') {
                        $totalLines++
                        $hits = [int]$Matches[2]
                        if ($hits -gt 0) {
                            $coveredLines++
                        }
                    }
                }
            }
        }
    }
    
    if ($totalLines -eq 0) {
        Write-Host "No lines found in Controllers and Services" -ForegroundColor Red
        exit 1
    }
    
    $currentCoverage = $coveredLines / $totalLines
    $currentCoveragePercent = [math]::Round($currentCoverage * 100)
    
    Write-Host "Total lines in Controllers and Services: $totalLines" -ForegroundColor Cyan
    Write-Host "Covered lines in Controllers and Services: $coveredLines" -ForegroundColor Cyan
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
    Write-Host "No coverage file found" -ForegroundColor Red
    exit 1
} 

exit 0