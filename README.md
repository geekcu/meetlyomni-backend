# MeetlyOmni Backend

This project is a .NET 8 Web API backend supporting the Meetly Omni application. It provides RESTful APIs, database operations, and server-side logic.

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

This project uses Git pre-commit hooks to ensure code quality. New team members need to set up the hooks after cloning the repository.

### Setup Instructions

1. **Set up Git hooks** (required for new team members):
   ```powershell
   .\setup-git-hooks.ps1
   ```

2. **Test hooks** (optional, to verify setup):
   ```powershell
   .\test-git-hooks.ps1
   ```

### What the hooks do

The pre-commit hook automatically runs before each commit:
- **Code formatting**: `dotnet format MeetlyOmni.sln`
- **Build validation**: `dotnet build MeetlyOmni.sln --no-restore`
- **Unit testing**: `dotnet test MeetlyOmni.sln --no-build`

If any step fails, the commit will be blocked until issues are resolved.