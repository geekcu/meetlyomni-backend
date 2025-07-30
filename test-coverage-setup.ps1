# Test script to verify coverage setup
Write-Host "Testing enhanced coverage setup..." -ForegroundColor Cyan

# Check if required tools are installed
Write-Host "Checking required tools..." -ForegroundColor Yellow

# Check if dotnet is available
try {
    $dotnetVersion = dotnet --version
    Write-Host "✓ .NET SDK found: $dotnetVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ .NET SDK not found" -ForegroundColor Red
    exit 1
}

# Check if reportgenerator is available
try {
    $reportGeneratorVersion = reportgenerator -version
    Write-Host "✓ ReportGenerator found: $reportGeneratorVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ ReportGenerator not found. Installing..." -ForegroundColor Yellow
    dotnet tool install --global dotnet-reportgenerator-globaltool
    Write-Host "✓ ReportGenerator installed" -ForegroundColor Green
}

# Check if coverage tools are available
try {
    $coverageVersion = dotnet-coverage --version
    Write-Host "✓ Coverage tools found: $coverageVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Coverage tools not found. Installing..." -ForegroundColor Yellow
    dotnet tool install --global dotnet-coverage
    Write-Host "✓ Coverage tools installed" -ForegroundColor Green
}

# Test the enhanced coverage script
Write-Host "Testing enhanced coverage script..." -ForegroundColor Yellow

try {
    # Run a basic coverage check (skip regression for testing)
    $result = & .\check-coverage-enhanced.ps1 -SkipRegressionCheck 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Enhanced coverage script works correctly" -ForegroundColor Green
    } else {
        Write-Host "✗ Enhanced coverage script failed" -ForegroundColor Red
        Write-Host "Output: $result" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Error running enhanced coverage script: $_" -ForegroundColor Red
}

# Test the pre-push hook script
Write-Host "Testing pre-push hook script..." -ForegroundColor Yellow

try {
    # Run the pre-push hook (skip regression for testing)
    $hookResult = & .\pre-push-coverage.ps1 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Pre-push hook script works correctly" -ForegroundColor Green
    } else {
        Write-Host "✗ Pre-push hook script failed (this might be expected if coverage is low)" -ForegroundColor Yellow
        Write-Host "Output: $hookResult" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Error running pre-push hook script: $_" -ForegroundColor Red
}

# Check if Git hooks directory exists
if (Test-Path ".git/hooks") {
    Write-Host "✓ Git hooks directory exists" -ForegroundColor Green
} else {
    Write-Host "✗ Git hooks directory not found" -ForegroundColor Red
}

# Check if setup script exists
if (Test-Path "setup-git-hooks-enhanced.ps1") {
    Write-Host "✓ Enhanced setup script exists" -ForegroundColor Green
} else {
    Write-Host "✗ Enhanced setup script not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "Setup verification completed!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run: .\setup-git-hooks-enhanced.ps1" -ForegroundColor White
Write-Host "2. Run: .\check-coverage-enhanced.ps1 -UpdateBaseline" -ForegroundColor White
Write-Host "3. Add tests for Controllers and Services to meet 80% coverage" -ForegroundColor White
Write-Host "4. Try pushing to test the Git hooks" -ForegroundColor White 