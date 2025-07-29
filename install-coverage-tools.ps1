# Install coverage tools script
Write-Host "Installing code coverage tools..." -ForegroundColor Cyan

# Check if dotnet-coverage is installed
Write-Host "Checking dotnet-coverage..." -ForegroundColor Yellow
try {
    $coverageVersion = dotnet coverage --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "dotnet-coverage is already installed: $coverageVersion" -ForegroundColor Green
    } else {
        Write-Host "Installing dotnet-coverage..." -ForegroundColor Yellow
        dotnet tool install -g dotnet-coverage
        if ($LASTEXITCODE -eq 0) {
            Write-Host "dotnet-coverage installed successfully" -ForegroundColor Green
        } else {
            Write-Host "Failed to install dotnet-coverage" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "Installing dotnet-coverage..." -ForegroundColor Yellow
    dotnet tool install -g dotnet-coverage
    if ($LASTEXITCODE -eq 0) {
        Write-Host "dotnet-coverage installed successfully" -ForegroundColor Green
    } else {
        Write-Host "Failed to install dotnet-coverage" -ForegroundColor Red
    }
}

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
Write-Host "  .\check-coverage.ps1" -ForegroundColor White
Write-Host "  .\setup-git-hooks.ps1" -ForegroundColor White 