# Project initialization script
# Run this script once when starting a new project or setting up a new developer environment

Write-Host "Initializing MeetlyOmni project..." -ForegroundColor Cyan

# Check if we're in the correct directory
if (-not (Test-Path "MeetlyOmni.sln")) {
    Write-Host "Error: Please run this script from the meetlyomni-backend directory" -ForegroundColor Red
    exit 1
}

# Step 1: Install coverage tools
Write-Host "`nStep 1: Installing coverage tools..." -ForegroundColor Yellow
try {
    & ".\install-coverage-tools.ps1"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Coverage tools installed successfully" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Coverage tools installation had issues, but continuing..." -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️ Coverage tools installation failed, but continuing..." -ForegroundColor Yellow
}

# Step 2: Setup Git hooks
Write-Host "`nStep 2: Setting up Git hooks..." -ForegroundColor Yellow
try {
    & ".\setup-git-hooks.ps1"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Git hooks setup completed" -ForegroundColor Green
    } else {
        Write-Host "❌ Git hooks setup failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Git hooks setup failed" -ForegroundColor Red
    exit 1
}

# Step 3: Test the setup (optional)
Write-Host "`nStep 3: Testing the setup..." -ForegroundColor Yellow
try {
    & ".\test-git-hooks.ps1"
    Write-Host "✅ Setup test completed" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Setup test had issues, but setup is complete" -ForegroundColor Yellow
}

Write-Host "`n🎉 Project initialization completed!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Start developing your features" -ForegroundColor White
Write-Host "2. Write tests for your code" -ForegroundColor White
Write-Host "3. Use '.\check-coverage.ps1' to check coverage manually" -ForegroundColor White
Write-Host "4. Git hooks will automatically run on commit and push" -ForegroundColor White
Write-Host "`nHappy coding! 🚀" -ForegroundColor Green 