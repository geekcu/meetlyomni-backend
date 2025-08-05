# Install coverage tools script
Write-Host "Installing code coverage tools..." -ForegroundColor Cyan

# XPlat Code Coverage is included with .NET SDK
Write-Host "XPlat Code Coverage is included with .NET SDK - no installation needed" -ForegroundColor Green

# Check if ReportGenerator is installed
Write-Host "Checking ReportGenerator..." -ForegroundColor Yellow
try {
    $reportVersion = reportgenerator --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "ReportGenerator is already installed: $reportVersion" -ForegroundColor Green
    } else {
        Write-Host "Installing ReportGenerator..." -ForegroundColor Yellow
        dotnet tool install -g dotnet-reportgenerator-globaltool
        if ($LASTEXITCODE -eq 0) {
            Write-Host "ReportGenerator installed successfully" -ForegroundColor Green
        } else {
            Write-Host "Failed to install ReportGenerator" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "Installing ReportGenerator..." -ForegroundColor Yellow
    dotnet tool install -g dotnet-reportgenerator-globaltool
    if ($LASTEXITCODE -eq 0) {
        Write-Host "ReportGenerator installed successfully" -ForegroundColor Green
    } else {
        Write-Host "Failed to install ReportGenerator" -ForegroundColor Red
    }
}

Write-Host "`nCoverage tools installation completed!" -ForegroundColor Green
Write-Host "You can now run coverage checks with:" -ForegroundColor Yellow
<<<<<<< HEAD
Write-Host "  .\check-coverage-enhanced.ps1" -ForegroundColor White
Write-Host "  .\setup-git-hooks-enhanced.ps1" -ForegroundColor White 
=======
Write-Host "  .\check-coverage.ps1" -ForegroundColor White
Write-Host "  .\setup-git-hooks.ps1" -ForegroundColor White 
>>>>>>> 9652d65 (rebase:rebase to branch after hotfix)
