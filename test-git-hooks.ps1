# Test Git hooks functionality script
Write-Host "Testing Git hooks..." -ForegroundColor Cyan

# Check if pre-commit hook exists
if (Test-Path .git/hooks/pre-commit) {
    Write-Host "pre-commit hook file exists" -ForegroundColor Green
    
    # Display hook content
    Write-Host "`nPre-commit hook content:" -ForegroundColor Yellow
    Get-Content .git/hooks/pre-commit | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
    
    # Test dotnet commands availability
    Write-Host "`nTesting dotnet command availability..." -ForegroundColor Cyan
    
    try {
        $formatResult = dotnet format MeetlyOmni.sln --dry-run --verbosity quiet 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "dotnet format: Available" -ForegroundColor Green
        } else {
            Write-Host "dotnet format: Has formatting issues that need to be fixed" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "dotnet format: Failed - $_" -ForegroundColor Red
    }
    
    try {
        $buildResult = dotnet build MeetlyOmni.sln --no-restore --verbosity quiet 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "dotnet build: Success" -ForegroundColor Green
        } else {
            Write-Host "dotnet build: Has warnings or errors" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "dotnet build: Failed - $_" -ForegroundColor Red
    }
    
    try {
        $testResult = dotnet test MeetlyOmni.sln --no-build --verbosity quiet 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "dotnet test: Success" -ForegroundColor Green
        } else {
            Write-Host "dotnet test: Has failing tests" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "dotnet test: Failed - $_" -ForegroundColor Red
    }
} else {
    Write-Host "pre-commit hook file does not exist" -ForegroundColor Red
    Write-Host "Please run: .\setup-git-hooks.ps1" -ForegroundColor Yellow
}

# Check if pre-push hook exists
Write-Host "`nChecking pre-push hook..." -ForegroundColor Cyan
if (Test-Path .git/hooks/pre-push) {
    Write-Host "pre-push hook file exists" -ForegroundColor Green
    
    # Display hook content
    Write-Host "`nPre-push hook content:" -ForegroundColor Yellow
    Get-Content .git/hooks/pre-push | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
    
    # Test coverage tools availability
    Write-Host "`nTesting coverage tools availability..." -ForegroundColor Cyan
    
    try {
        $coverageResult = dotnet test MeetlyOmni.sln --collect:"XPlat Code Coverage" --results-directory coverage-test --verbosity quiet 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Code coverage collection: Available" -ForegroundColor Green
        } else {
            Write-Host "Code coverage collection: Failed" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Code coverage collection: Failed - $_" -ForegroundColor Red
    }
    
    try {
        $reportResult = dotnet reportgenerator -reports:coverage-test/*/coverage.cobertura.xml -targetdir:coverage-test/report -reporttypes:Html 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Report generator: Available" -ForegroundColor Green
        } else {
            Write-Host "Report generator: Failed" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Report generator: Failed - $_" -ForegroundColor Red
    }
    
    # Clean up test coverage files
    if (Test-Path "coverage-test") {
        Remove-Item -Path "coverage-test" -Recurse -Force
    }
    
} else {
    Write-Host "pre-push hook file does not exist" -ForegroundColor Red
    Write-Host "Please run: .\setup-git-hooks.ps1" -ForegroundColor Yellow
}

Write-Host "`nHook testing completed!" -ForegroundColor Green
Write-Host "You can now commit and push code normally." -ForegroundColor Green
Write-Host "Note: Pre-push hook will check for 80% minimum coverage and prevent regression." -ForegroundColor Yellow 