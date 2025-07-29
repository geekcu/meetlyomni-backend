# MeetlyOmni Backend

This project is a .NET 8 Web API backend supporting the Meetly Omni application. It provides RESTful APIs, database operations, and server-side logic.

## Quick Start

**New to this project?** Follow our comprehensive [Setup Guide](./SETUP-GUIDE.md) to get everything running locally.

### For Experienced Developers

```bash
# Quick setup (assumes PostgreSQL is running)
git clone <repository-url>
cd MeetlyOmni/meetlyomni-backend
dotnet user-secrets set "ConnectionStrings:DefaultConnection" "Host=localhost;Port=5432;Database=meetlyomni_dev;Username=your_user;Password=your_password"
dotnet ef database update --project src/MeetlyOmni.Api
dotnet run --project src/MeetlyOmni.Api
```

## Technology Stack

- **.NET 8**: The latest long-term support version of .NET
- **ASP.NET Core**: Web API framework
- **Entity Framework Core**: Object-Relational Mapping (ORM)
- **PostgreSQL**: Primary database
- **AutoMapper**: Object-to-object mapping
- **StyleCop.Analyzers**: Code style analysis and enforcement

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
└── README.md                    # Project documentation
```

## Git Hooks Setup

This project uses Git hooks to ensure code quality and maintain high test coverage. New team members need to set up the hooks after cloning the repository.

### Quick Start Guide

#### Step 1: Initial Setup (One-time)
For new team members or project initialization:

```powershell
# Clone the repository
git clone <repository-url>
cd meetlyomni-backend

# One-command setup (recommended)
.\init-project.ps1
```

**What this does:**
- Installs required coverage tools
- Sets up Git hooks (pre-commit and pre-push)
- Tests the setup
- Provides next steps guidance

#### Step 2: Verify Setup
After running the setup, verify everything works:

```powershell
# Test the hooks
.\test-git-hooks.ps1

# Check coverage manually
.\check-coverage.ps1
```

**Expected output:**
- All tools are available
- Hooks are properly installed
- Coverage will be 0% initially (this is normal)

#### Step 3: Start Development
Now you can start developing with automatic quality checks:

```powershell
# Make changes to your code
# Add tests for your new features
# Commit your changes (hooks will run automatically)
git add .
git commit -m "Add new feature"

# Push your changes (coverage check will run)
git push
```

### Manual Setup (Advanced)
If you prefer to run scripts individually:

1. **Install coverage tools** (required once):
   ```powershell
   .\install-coverage-tools.ps1
   ```

2. **Set up Git hooks** (required once):
   ```powershell
   .\setup-git-hooks.ps1
   ```

3. **Test hooks** (optional, to verify setup):
   ```powershell
   .\test-git-hooks.ps1
   ```

### What the hooks do

#### Pre-commit Hook
Automatically runs before each commit:

- **Code formatting**: `dotnet format MeetlyOmni.sln`
- **Build validation**: `dotnet build MeetlyOmni.sln --no-restore`
- **Unit testing**: `dotnet test MeetlyOmni.sln --no-build`

#### Pre-push Hook
Automatically runs before each push:

- **Code coverage check**: Ensures minimum 80% line coverage
- **Coverage regression prevention**: Prevents coverage from dropping below previous baseline
- **Detailed reporting**: Generates HTML coverage reports

If any step fails, the commit/push will be blocked until issues are resolved.

### Manual Coverage Check

To manually check code coverage locally:

```powershell
# Check coverage with default 80% threshold
.\check-coverage.ps1

# Check coverage with custom threshold
.\check-coverage.ps1 -MinThreshold 85

# Check coverage without regression check
.\check-coverage.ps1 -SkipRegressionCheck
```

### Understanding Code Coverage

#### Initial State (0% Coverage)
When you first set up the project, you'll see **0% coverage**. This is **normal and expected** because:

- **Tests exist** but they're empty placeholder tests
- **No business code is being tested** yet
- **You need to write actual tests** for your API code

#### How to Improve Coverage
To reach the 80% coverage requirement:

1. **Write tests for your Controllers:**
   ```csharp
   [Fact]
   public async Task GetMembers_ShouldReturnMembers()
   {
       var controller = new MemberController(memberService);
       var result = await controller.GetMembers();
       Assert.NotNull(result);
   }
   ```

2. **Write tests for your Services:**
   ```csharp
   [Fact]
   public async Task CreateMember_ShouldCreateNewMember()
   {
       var service = new MemberService(repository);
       var member = await service.CreateMember(new MemberDto());
       Assert.NotNull(member);
   }
   ```

3. **Write tests for your Repositories:**
   ```csharp
   [Fact]
   public async Task GetById_ShouldReturnMember()
   {
       var repository = new MemberRepository(context);
       var member = await repository.GetByIdAsync(1);
       Assert.NotNull(member);
   }
   ```

#### Coverage Goals
- **Minimum threshold**: 80% line coverage
- **Regression prevention**: Coverage cannot decrease
- **Focus areas**: Controllers, Services, Repositories

### Coverage Reports

After running coverage checks, detailed HTML reports are available at:
- `coverage/report/index.html`

### Prerequisites

For coverage checking to work, ensure you have the required tools installed:

```powershell
# Install coverage tools (run once)
.\install-coverage-tools.ps1
```

Or install manually:
1. **XPlat Code Coverage** package:
   ```bash
   dotnet tool install -g dotnet-coverage
   ```

2. **ReportGenerator** tool:
   ```bash
   dotnet tool install -g dotnet-reportgenerator-globaltool
   ```

### Troubleshooting

#### Common Issues

**Problem**: `dotnet-reportgenerator does not exist`
```powershell
# Solution: Reinstall the tool
dotnet tool uninstall -g dotnet-reportgenerator-globaltool
dotnet tool install -g dotnet-reportgenerator-globaltool
```

**Problem**: `bc: command not found` (Windows)
```powershell
# Solution: Use PowerShell version instead
# The pre-push hook will automatically use PowerShell on Windows
```

**Problem**: Coverage stuck at 0%
- **Normal for new projects**
- **Write actual tests** for your business code
- **Focus on Controllers, Services, Repositories**

**Problem**: Push blocked by coverage check
```powershell
# Temporary bypass (use sparingly)
git push --no-verify

# Better: Write tests to improve coverage
```

#### Getting Help

1. **Check tool installation:**
   ```powershell
   dotnet tool list -g
   ```

2. **Test hooks manually:**
   ```powershell
   .\test-git-hooks.ps1
   ```

3. **Check coverage report:**
   - Open `coverage/report/index.html` in browser
   - Look for specific uncovered lines

## API Documentation

Once running, visit:

- **Swagger UI**: https://localhost:5001/swagger
- **Health Check**: https://localhost:5001/health

## Contributing

1. Follow the [Setup Guide](./SETUP-GUIDE.md) to configure your environment
2. Create a feature branch from `main`
3. Make your changes with appropriate tests
4. Ensure all Git hooks pass
5. Submit a pull request with a clear description

```
MeetlyOmni.Backend/
├── MeetlyOmni.Api/               # Main Web API project
│   ├── Common/                   # Shared helpers, utilities, extensions
│   ├── Controllers/              # API controllers (route entry points)
│   ├── Data/                     # Data access layer
│   │   ├── Configurations/       # Entity configurations (Fluent API)
│   │   ├── Entities/             # EF Core entity models
│   │   ├── Repository/           # Repository interfaces and implementations
│   │   └── ApplicationDbContext.cs  # EF Core database context
│   ├── Filters/                  # Action and exception filters
│   ├── Mapping/                  # AutoMapper configuration
│   ├── Middlewares/             # Custom middleware components
│   ├── Migrations/              # EF Core migration files
│   ├── Models/                  # View models / DTOs
│   ├── Properties/              # Project properties (e.g., launchSettings.json)
│   ├── Service/                 # Business logic services
│   ├── appsettings.Development.json  # Development environment config
│   ├── appsettings.json         # Default application configuration
│   ├── MeetlyOmni.Api.csproj    # API project file
│   ├── MeetlyOmni.Api.http      # HTTP test requests file
│   └── Program.cs               # Application entry point
├── MeetlyOmni.Tests/            # xUnit test project
│   └── ...                      # Unit test files
├── global.json                  # SDK version configuration
├── MeetlyOmni.sln               # Solution file
├── .gitignore                   # Git ignore rules
└── README.md                    # Project documentation
```

## Docker Compose Usage

### 0. What does this Docker Compose include?

This Docker Compose setup includes the following services:

- **API Service**: The .NET 8 Web API for Meetly Omni.
- **Database (PostgreSQL)**: A PostgreSQL database instance.
- **SQL Query Tool (Adminer)**: A web-based database management tool.

### 1. Benefits of Using Docker Compose

Using Docker Compose to start the API service, database, and Adminer has several advantages over setting them up individually:

- **Simplified Setup**: Easily start all services with a single command.
- **Consistency**: Ensures the same environment across different development machines.
- **Isolation**: Runs each service in its own container, avoiding conflicts.

### 2. How to Use Docker Compose

**Pre-requisite**: Make sure Docker Desktop is installed and running.

To start the services, run the following command in the project root:

```bash
docker-compose up -d
```

This command will start all the services in detached mode.

### 3. Accessing Services

- **Adminer**: Once the services are up, you can access Adminer at `http://localhost:8081`. Use the following credentials to connect to the PostgreSQL database:

  - **System**: PostgreSQL
  - **Server**: db
  - **Username**: (your database username)
  - **Password**: (your database password)
  - **Database**: (your database name)

- # **API Swagger**: The API documentation is available at `http://localhost:5000/swagger`. You can use this interface to explore and test the API endpoints.

## Support

- 📖 **Setup Issues**: See [SETUP-GUIDE.md](./SETUP-GUIDE.md)
- 🐛 **Bugs**: Create an issue with reproduction steps
- 💡 **Feature Requests**: Discuss with the team first
