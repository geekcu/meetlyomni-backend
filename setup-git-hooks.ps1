# Git hooks setup script
Write-Host "Setting up Git hooks..." -ForegroundColor Cyan

# Check if we're in a Git repository
if (-not (Test-Path .git)) {
    Write-Host "Error: Not in a Git repository" -ForegroundColor Red
    exit 1
}

Write-Host "Setting up Git hooks..."

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
dotnet test MeetlyOmni.sln --no-build --filter "Category=Unit" || exit 1
'@

# Create pre-push hook content for coverage check
$prePushContent = @'
#!/bin/sh
echo "Running code coverage check..."

# Get the target branch (usually origin/main)
TARGET_BRANCH=${1#refs/heads/}
if [ -z "$TARGET_BRANCH" ]; then
    TARGET_BRANCH="origin/main"
fi

echo "Target branch: $TARGET_BRANCH"

# Create coverage directory if it doesn't exist
mkdir -p coverage

# Run tests with coverage
echo "Running tests with coverage..."
dotnet test MeetlyOmni.sln --collect:"XPlat Code Coverage" --results-directory coverage --verbosity normal

if [ $? -ne 0 ]; then
    echo "Tests failed. Push blocked."
    exit 1
fi

# Generate coverage report
echo "Generating coverage report..."
dotnet reportgenerator -reports:coverage/*/coverage.cobertura.xml -targetdir:coverage/report -reporttypes:Html

# Extract current coverage percentage
CURRENT_COVERAGE=$(grep -o "line-rate=\"[0-9.]*\"" coverage/*/coverage.cobertura.xml | grep -o "[0-9.]*" | head -1)
CURRENT_COVERAGE_PERCENT=$(echo "$CURRENT_COVERAGE * 100" | bc -l | cut -d. -f1)

echo "Current coverage: ${CURRENT_COVERAGE_PERCENT}%"

# Check minimum threshold (80%)
if [ "$CURRENT_COVERAGE_PERCENT" -lt 80 ]; then
    echo "❌ Coverage below minimum threshold of 80%"
    echo "Current coverage: ${CURRENT_COVERAGE_PERCENT}%"
    echo "Detailed report: coverage/report/index.html"
    exit 1
fi

# Get previous coverage from target branch
echo "Checking coverage regression..."
git fetch origin
PREVIOUS_COVERAGE=$(git show origin/main:coverage/coverage.txt 2>/dev/null || echo "0")

if [ "$PREVIOUS_COVERAGE" != "0" ]; then
    PREVIOUS_COVERAGE_PERCENT=$(echo "$PREVIOUS_COVERAGE" | cut -d. -f1)
    echo "Previous coverage: ${PREVIOUS_COVERAGE_PERCENT}%"
    
    if [ "$CURRENT_COVERAGE_PERCENT" -lt "$PREVIOUS_COVERAGE_PERCENT" ]; then
        echo "❌ Coverage regression detected!"
        echo "Previous: ${PREVIOUS_COVERAGE_PERCENT}%"
        echo "Current: ${CURRENT_COVERAGE_PERCENT}%"
        echo "Detailed report: coverage/report/index.html"
        exit 1
    fi
fi

# Save current coverage for future comparison
echo "$CURRENT_COVERAGE" > coverage/coverage.txt

echo "✅ Coverage check passed!"
echo "Current coverage: ${CURRENT_COVERAGE_PERCENT}%"
echo "Detailed report: coverage/report/index.html"
'@

# Create PowerShell version for Windows
$prePushContentPS = @'
# PowerShell version of pre-push hook
param(
    [string]$TargetBranch = "origin/main"
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
    Write-Host "Tests failed. Push blocked." -ForegroundColor Red
    exit 1
}

# Generate coverage report
Write-Host "Generating coverage report..." -ForegroundColor Yellow
dotnet reportgenerator -reports:coverage/*/coverage.cobertura.xml -targetdir:coverage/report -reporttypes:Html

# Extract current coverage percentage
$coverageFile = Get-ChildItem -Path "coverage" -Filter "coverage.cobertura.xml" -Recurse | Select-Object -First 1
if ($coverageFile) {
    $content = Get-Content $coverageFile.FullName
    $lineRateMatch = $content | Select-String 'line-rate="([0-9.]+)"' | Select-Object -First 1
    if ($lineRateMatch) {
        $currentCoverage = [double]$lineRateMatch.Matches[0].Groups[1].Value
        $currentCoveragePercent = [math]::Round($currentCoverage * 100)
        
        Write-Host "Current coverage: ${currentCoveragePercent}%" -ForegroundColor Green
        
        # Check minimum threshold (80%)
        if ($currentCoveragePercent -lt 80) {
            Write-Host "❌ Coverage below minimum threshold of 80%" -ForegroundColor Red
            Write-Host "Current coverage: ${currentCoveragePercent}%" -ForegroundColor Red
            Write-Host "Detailed report: coverage/report/index.html" -ForegroundColor Yellow
            exit 1
        }
        
        # Get previous coverage from target branch
        Write-Host "Checking coverage regression..." -ForegroundColor Yellow
        git fetch origin
        $previousCoverageFile = "coverage/coverage.txt"
        $previousCoverage = 0
        
        if (Test-Path $previousCoverageFile) {
            $previousCoverage = [double](Get-Content $previousCoverageFile)
            $previousCoveragePercent = [math]::Round($previousCoverage * 100)
            Write-Host "Previous coverage: ${previousCoveragePercent}%" -ForegroundColor Cyan
            
            if ($currentCoveragePercent -lt $previousCoveragePercent) {
                Write-Host "❌ Coverage regression detected!" -ForegroundColor Red
                Write-Host "Previous: ${previousCoveragePercent}%" -ForegroundColor Red
                Write-Host "Current: ${currentCoveragePercent}%" -ForegroundColor Red
                Write-Host "Detailed report: coverage/report/index.html" -ForegroundColor Yellow
                exit 1
            }
        }
        
        # Save current coverage for future comparison
        $currentCoverage | Out-File -FilePath $previousCoverageFile -Encoding ASCII
        
        Write-Host "✅ Coverage check passed!" -ForegroundColor Green
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
'@

# Write pre-commit hook
try {
    $preCommitContent | Out-File -FilePath ".git/hooks/pre-commit" -Encoding ASCII
    Write-Host "Pre-commit hook created successfully!" -ForegroundColor Green
} catch {
    Write-Host "Failed to create pre-commit hook: $_" -ForegroundColor Red
    exit 1
}

# Write pre-push hook (both Unix and Windows versions)
try {
    $prePushContent | Out-File -FilePath ".git/hooks/pre-push" -Encoding ASCII
    $prePushContentPS | Out-File -FilePath ".git/hooks/pre-push.ps1" -Encoding UTF8
    
    # Create Windows batch file to call PowerShell
    $prePushBatch = @'
@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0pre-push.ps1" %*
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
'@
    $prePushBatch | Out-File -FilePath ".git/hooks/pre-push.cmd" -Encoding ASCII
    
    Write-Host "Pre-push hook created successfully!" -ForegroundColor Green
} catch {
    Write-Host "Failed to create pre-push hook: $_" -ForegroundColor Red
    exit 1
}

Write-Host "Git hooks setup completed!" -ForegroundColor Green
Write-Host "Hooks will now automatically run:" -ForegroundColor Yellow
Write-Host "  Pre-commit:" -ForegroundColor White
Write-Host "    - Code formatting (dotnet format)" -ForegroundColor White
Write-Host "    - Build validation (dotnet build)" -ForegroundColor White
Write-Host "    - Unit testing (dotnet test)" -ForegroundColor White
Write-Host "  Pre-push:" -ForegroundColor White
Write-Host "    - Code coverage check (≥80%)" -ForegroundColor White
Write-Host "    - Coverage regression prevention" -ForegroundColor White
Write-Host "    - Detailed coverage report generation" -ForegroundColor White 