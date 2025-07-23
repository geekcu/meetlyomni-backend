# MeetlyOmni Backend

This project is a .NET 8 Web API backend supporting the Meetly Omni application. It provides RESTful APIs, database operations, and server-side logic.

## 🚀 Quick Start

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

## Support

- 📖 **Setup Issues**: See [SETUP-GUIDE.md](./SETUP-GUIDE.md)
- 🐛 **Bugs**: Create an issue with reproduction steps
- 💡 **Feature Requests**: Discuss with the team first