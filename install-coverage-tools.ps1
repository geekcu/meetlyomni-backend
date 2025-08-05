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

# Check for Unix/Linux dependencies (if running on Unix-like system)
if ($IsLinux -or $IsMacOS) {
    Write-Host "`nChecking Unix/Linux dependencies..." -ForegroundColor Yellow
    
    # Check for xmllint
    try {
        $xmllintVersion = xmllint --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "xmllint is available" -ForegroundColor Green
        } else {
            Write-Host "Warning: xmllint not found. Install libxml2-utils package." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Warning: xmllint not found. Install libxml2-utils package." -ForegroundColor Yellow
    }
    
    # Check for bc
    try {
        $bcVersion = bc --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "bc is available" -ForegroundColor Green
        } else {
            Write-Host "Warning: bc not found. Install bc package." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Warning: bc not found. Install bc package." -ForegroundColor Yellow
    }
}

Write-Host "`nCoverage tools installation completed!" -ForegroundColor Green
Write-Host "You can now run coverage checks with:" -ForegroundColor Yellow
Write-Host "  .\check-coverage-enhanced.ps1" -ForegroundColor White
Write-Host "  .\setup-git-hooks-enhanced.ps1" -ForegroundColor White 