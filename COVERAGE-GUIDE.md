# Code Coverage Guide for Controllers and Services

This guide explains how to use the enhanced code coverage system that specifically targets Controllers and Services in the MeetlyOmni backend project.

## Overview

The coverage system enforces:
- **Minimum threshold**: 80% line coverage for Controllers and Services
- **Regression prevention**: Coverage cannot decrease below the previous baseline
- **Cross-platform support**: Works on Windows (PowerShell) and Unix/Linux (Bash)
- **Automatic enforcement**: Git hooks prevent pushes that violate coverage requirements

## Quick Start

### 1. Setup Git Hooks

Run the enhanced setup script to install the coverage hooks:

```powershell
# Windows
.\setup-git-hooks-enhanced.ps1

# Unix/Linux
chmod +x setup-git-hooks-enhanced.ps1
./setup-git-hooks-enhanced.ps1
```

### 2. Initial Baseline Setup

Set up the initial coverage baseline:

```powershell
# Windows
.\check-coverage-enhanced.ps1 -UpdateBaseline

# Unix/Linux
chmod +x check-coverage-enhanced.sh
./check-coverage-enhanced.sh --update-baseline
```

### 3. Manual Coverage Check

Run coverage checks manually:

```powershell
# Windows
.\check-coverage-enhanced.ps1

# Unix/Linux
./check-coverage-enhanced.sh
```

## How It Works

### Coverage Scope

The system specifically targets:
- **Controllers**: `src/MeetlyOmni.Api/Controllers/*.cs`
- **Services**: `src/MeetlyOmni.Api/Service/*.cs`

Other code (models, data access, etc.) is excluded from coverage requirements.

### Baseline Tracking

- Coverage baseline is stored in `coverage/baseline/coverage.txt`
- The baseline represents the minimum acceptable coverage percentage
- New commits cannot push if coverage drops below the baseline
- Baseline can be updated when coverage improves

### Git Hook Behavior

**Pre-push Hook**:
1. Runs tests with coverage collection
2. Generates coverage report for Controllers and Services
3. Checks minimum threshold (80%)
4. Compares against baseline
5. Blocks push if requirements not met

**Pre-commit Hook**:
1. Formats code with `dotnet format`
2. Builds solution
3. Runs unit tests

## Commands Reference

### Enhanced Coverage Check Script

#### Windows (PowerShell)

```powershell
# Basic coverage check
.\check-coverage-enhanced.ps1

# Check with custom threshold
.\check-coverage-enhanced.ps1 -MinThreshold 85

# Skip regression check
.\check-coverage-enhanced.ps1 -SkipRegressionCheck

# Update baseline
.\check-coverage-enhanced.ps1 -UpdateBaseline

# Help
.\check-coverage-enhanced.ps1 -?
```

#### Unix/Linux (Bash)

```bash
# Basic coverage check
./check-coverage-enhanced.sh

# Check with custom threshold
./check-coverage-enhanced.sh --min-threshold 85

# Skip regression check
./check-coverage-enhanced.sh --skip-regression-check

# Update baseline
./check-coverage-enhanced.sh --update-baseline

# Help
./check-coverage-enhanced.sh --help
```

### Pre-push Hook Script

#### Windows (PowerShell)

```powershell
# Manual pre-push check
.\pre-push-coverage.ps1

# With custom target branch
.\pre-push-coverage.ps1 -TargetBranch "origin/develop"
```

#### Unix/Linux (Bash)

```bash
# Manual pre-push check
./pre-push-coverage.sh

# With custom target branch
./pre-push-coverage.sh origin/develop
```

## Configuration

### Coverage Filter

The system uses a filter file (`coverage/coverage.filter`) to include only Controllers and Services:

```
[Filters]
+[MeetlyOmni.Api.Controllers]*Controllers*
+[MeetlyOmni.Api.Service]*Service*
-[MeetlyOmni.Api.Controllers]*.Program*
-[MeetlyOmni.Api.Service]*.Program*
```

### Threshold Configuration

- **Minimum threshold**: 80% (configurable)
- **Regression threshold**: Previous baseline (automatic)

### Test Filtering

Tests are filtered to exclude integration tests:
```bash
dotnet test --filter "Category!=Integration"
```

## Troubleshooting

### Common Issues

#### 1. "No coverage file found"

**Cause**: Tests didn't generate coverage data
**Solution**: 
- Ensure tests are running successfully
- Check that coverage tools are installed
- Verify test project configuration

#### 2. "Coverage below minimum threshold"

**Cause**: Coverage is below 80%
**Solution**:
- Add more unit tests for Controllers and Services
- Improve existing test coverage
- Review uncovered code paths

#### 3. "Coverage regression detected"

**Cause**: Current coverage is below the baseline
**Solution**:
- Add tests to improve coverage
- Update baseline if the regression is acceptable:
  ```powershell
  .\check-coverage-enhanced.ps1 -UpdateBaseline
  ```

#### 4. "Tests failed. Push blocked."

**Cause**: Unit tests are failing
**Solution**:
- Fix failing tests
- Ensure all tests pass before pushing

### Debugging

#### Enable Verbose Output

```powershell
# Windows
dotnet test --verbosity detailed

# Unix/Linux
dotnet test --verbosity detailed
```

#### Check Coverage Report

Open the generated HTML report:
```
coverage/report/index.html
```

#### Manual Coverage Analysis

```powershell
# Windows
reportgenerator -reports:coverage/*/coverage.cobertura.xml -targetdir:coverage/report -reporttypes:Html

# Unix/Linux
reportgenerator -reports:coverage/*/coverage.cobertura.xml -targetdir:coverage/report -reporttypes:Html
```

## Best Practices

### Writing Tests for Controllers

```csharp
[Test]
public void Controller_Action_ShouldReturnExpectedResult()
{
    // Arrange
    var service = new Mock<IMyService>();
    var controller = new MyController(service.Object);
    
    // Act
    var result = controller.Action();
    
    // Assert
    Assert.IsNotNull(result);
    // Add more assertions
}
```

### Writing Tests for Services

```csharp
[Test]
public void Service_Method_ShouldProcessCorrectly()
{
    // Arrange
    var repository = new Mock<IMyRepository>();
    var service = new MyService(repository.Object);
    
    // Act
    var result = service.ProcessData(input);
    
    // Assert
    Assert.IsNotNull(result);
    // Add more assertions
}
```

### Maintaining High Coverage

1. **Test all public methods** in Controllers and Services
2. **Test edge cases** and error conditions
3. **Use mocking** for external dependencies
4. **Test both success and failure scenarios**
5. **Keep tests focused** and maintainable

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Coverage Check
on: [push, pull_request]

jobs:
  coverage:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '8.0.x'
      - name: Install coverage tools
        run: |
          dotnet tool install --global dotnet-coverage
          dotnet tool install --global dotnet-reportgenerator-globaltool
      - name: Run coverage check
        run: ./check-coverage-enhanced.sh
```

## File Structure

```
meetlyomni-backend/
├── check-coverage-enhanced.ps1          # Windows coverage script
├── check-coverage-enhanced.sh           # Unix/Linux coverage script
├── pre-push-coverage.ps1               # Windows pre-push hook
├── pre-push-coverage.sh                # Unix/Linux pre-push hook
├── setup-git-hooks-enhanced.ps1        # Enhanced setup script
├── coverage/
│   ├── baseline/
│   │   └── coverage.txt                # Baseline coverage data
│   ├── coverage.filter                  # Coverage filter configuration
│   └── report/                         # Generated HTML reports
└── .git/hooks/
    ├── pre-commit                      # Pre-commit hook
    ├── pre-push                        # Unix/Linux pre-push hook
    ├── pre-push.ps1                    # Windows PowerShell pre-push hook
    └── pre-push.cmd                    # Windows batch pre-push hook
```

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review the generated coverage report
3. Run manual coverage checks with verbose output
4. Ensure all dependencies are installed correctly 