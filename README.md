# MeetlyOmni Backend

.NET 8 Web API backend for the Meetly Omni application with enhanced code coverage system.

## Quick Start

### Prerequisites
- .NET 8 SDK
- PostgreSQL
- Git

### Setup
```powershell
# Clone and setup
git clone <repository-url>
cd meetlyomni-backend

# Setup enhanced coverage system
.\setup-git-hooks-enhanced.ps1

# Set initial coverage baseline
.\check-coverage-enhanced.ps1 -UpdateBaseline

# Configure database
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Host=localhost;Port=5432;Database=meetlyomni_dev;Username=your_user;Password=your_password"
dotnet ef database update --project src/MeetlyOmni.Api

# Run the application
dotnet run --project src/MeetlyOmni.Api
```

## Enhanced Coverage System

This project uses an **enhanced coverage system** that specifically targets **Controllers and Services** with baseline tracking and regression prevention.

### Features
- **Targeted Coverage**: Only Controllers and Services are measured
- **Minimum Threshold**: 80% line coverage required
- **Regression Prevention**: Coverage cannot decrease below baseline
- **Cross-Platform**: Works on Windows (PowerShell) and Unix/Linux (Bash)
- **Git Integration**: Automatic enforcement via pre-push hooks

### Quick Commands

```powershell
# Manual coverage check
.\check-coverage-enhanced.ps1

# Check with custom threshold
.\check-coverage-enhanced.ps1 -MinThreshold 85

# Update baseline when coverage improves
.\check-coverage-enhanced.ps1 -UpdateBaseline

# Skip regression check (for testing)
.\check-coverage-enhanced.ps1 -SkipRegressionCheck
```

### Coverage Scope
- **Controllers**: `src/MeetlyOmni.Api/Controllers/*.cs`
- **Services**: `src/MeetlyOmni.Api/Service/*.cs`

Other code (models, data access, etc.) is excluded from coverage requirements.

### Baseline Tracking
- Coverage baseline is stored in `coverage/baseline/coverage.txt`
- New commits cannot push if coverage drops below the baseline
- Baseline can be updated when coverage improves

For detailed information, see [Coverage Guide](./COVERAGE-GUIDE.md).

## Project Structure

```
src/
├── MeetlyOmni.Api/
│   ├── Common/
│   │   ├── Constants/          # Application constants
│   │   ├── Enums/             # Enumeration definitions
│   │   └── Extensions/        # Extension methods
│   ├── Controllers/           # API controllers
│   ├── Data/
│   │   ├── Entities/          # Database entity models
│   │   ├── Configurations/    # Entity Framework configurations
│   │   └── Repository/        # Data access layer
│   ├── Filters/              # Action filters
│   ├── Mapping/              # AutoMapper profiles
│   ├── Middlewares/          # Custom middleware
│   ├── Migrations/           # Database migrations
│   ├── Models/               # DTOs and view models
│   ├── Service/              # Business logic services
│   └── Program.cs            # Application entry point
└── MeetlyOmni.Tests/         # Unit tests
```

## Technology Stack

- **.NET 8**: Latest LTS version
- **ASP.NET Core**: Web API framework
- **Entity Framework Core**: ORM
- **PostgreSQL**: Primary database
- **AutoMapper**: Object mapping
- **StyleCop.Analyzers**: Code style enforcement

## Git Hooks

The project uses Git hooks for automatic quality checks:

### Pre-commit Hook
- Code formatting with `dotnet format`
- Build validation
- Unit testing

### Pre-push Hook
- Controllers and Services coverage check (≥80%)
- Coverage regression prevention
- Baseline tracking and comparison
- Detailed coverage report generation

## Development Workflow

1. **Make changes** to your code
2. **Write tests** for Controllers and Services
3. **Commit changes** (pre-commit hooks run automatically)
4. **Push changes** (pre-push hooks enforce coverage requirements)

## Troubleshooting

### Common Issues

**Coverage below 80%:**
- Add more unit tests for Controllers and Services
- Review uncovered code paths

**Coverage regression:**
- Add tests to improve coverage
- Update baseline if acceptable: `.\check-coverage-enhanced.ps1 -UpdateBaseline`

**Tests failing:**
- Fix failing tests before pushing

### Manual Coverage Check
```powershell
# Check coverage with default 80% threshold
.\check-coverage-enhanced.ps1

# Check coverage with custom threshold
.\check-coverage-enhanced.ps1 -MinThreshold 85

# Skip regression check
.\check-coverage-enhanced.ps1 -SkipRegressionCheck

# Update baseline (when coverage improves)
.\check-coverage-enhanced.ps1 -UpdateBaseline
```

### Coverage Reports
After running coverage checks, detailed HTML reports are available at:
- `coverage/report/index.html`

## Prerequisites

For coverage checking to work, ensure you have the required tools installed:

```powershell
# Install coverage tools (run once)
.\install-coverage-tools.ps1
```

Or install manually:
1. **Coverage collection** is handled by the XPlat Code Coverage collector included with .NET SDK (no separate installation needed)

2. **ReportGenerator** tool:
   ```bash
   dotnet tool install -g dotnet-reportgenerator-globaltool
   ```

## Support

For detailed coverage system documentation, see [Coverage Guide](./COVERAGE-GUIDE.md).

For implementation details, see [Implementation Summary](./IMPLEMENTATION-SUMMARY.md).
