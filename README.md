# Meetly Omni Backend

This project is a .NET 8 Web API backend supporting the Meetly Omni application. It provides RESTful APIs, database operations, and server-side logic.

## Tech Stack

| Technology            | Description                                                              |
|------------------------|--------------------------------------------------------------------------|
| ASP.NET Core 8         | Backend web framework for building APIs.                                 |
| Entity Framework Core  | ORM for database access and migrations.                                  |
| PostgreSQL             | Relational database used in this project.                                |
| AutoMapper             | For mapping between DTOs and entity models.                              |
| FluentValidation       | For model validation.                                                    |
| xUnit + Moq            | Unit testing framework and mocking library.                              |
| Serilog                | Structured logging to console and files.                                 |
| Swagger (Swashbuckle)  | For auto-generating API documentation.                                   |

## Getting Started

### 1. Set up PostgreSQL

Make sure PostgreSQL is installed and running. Create a database (e.g. `MeetlyOmniDb`), and update the connection string in:
```
appsettings.Development.json
```
Example:

```json
"ConnectionStrings": {
  "MeetlyOmniDb": "Host=localhost;Port=5432;Database=MeetlyOmniDb;Username=postgres;Password=yourpassword"
}
```

### 2. Apply EF Core Migrations

Make sure the .NET CLI is installed and EF tools are available. Then run:
```json
dotnet ef database update
```
This command will apply the migrations and create the necessary schema in your PostgreSQL database.

### 3. Run the Application
To start the backend server in development mode, run:
```json
dotnet run --project MeetlyOmni.Api
```
The API will be accessible at https://localhost:5001 or http://localhost:5000 depending on your launch settings.

## Available Scripts

| Command                           | Description                                    |
| --------------------------------- | ---------------------------------------------- |
| `dotnet run`                      | Runs the application.                          |
| `dotnet build`                    | Builds the solution.                           |
| `dotnet test`                     | Runs all unit tests.                           |
| `dotnet ef migrations add <Name>` | Creates a new EF Core migration.               |
| `dotnet ef database update`       | Applies the latest migrations to the database. |


## Testing
The solution includes test projects using xUnit and Moq.
To run tests:
```json
dotnet test
```

## API Documentation
Swagger is enabled. Once the application is running, you can view the API docs at:

https://localhost:5001/swagger

## Project Structure

```
MeetlyOmni.Backend/
©À©¤©¤ MeetlyOmni.Api/ # Main Web API project
©¦ ©À©¤©¤ Constants/ # Constant values and keys
©¦ ©À©¤©¤ Controllers/ # API endpoints/controllers
©¦ ©À©¤©¤ Data/ # DB context or seeders
©¦ ©À©¤©¤ DTOs/ # Data transfer objects
©¦ ©À©¤©¤ Entities/ # EF Core entity models
©¦ ©À©¤©¤ Enums/ # Enum definitions
©¦ ©À©¤©¤ Exceptions/ # Custom exception handling
©¦ ©À©¤©¤ Middlewares/ # Custom middleware logic
©¦ ©À©¤©¤ Migrations/ # EF Core migrations
©¦ ©À©¤©¤ Repository/ # Repository interfaces and implementations
©¦ ©À©¤©¤ Service/ # Business logic and service layer
©¦ ©À©¤©¤ appsettings.json # Main configuration file
©¦ ©À©¤©¤ MappingProfile.cs # AutoMapper profile
©¦ ©À©¤©¤ MeetlyOmni.Api.http # HTTP test file
©¦ ©¸©¤©¤ Program.cs # Application entry point
©À©¤©¤ MeetlyOmni.Tests/ # xUnit test project
©¸©¤©¤ README.md # Project documentation
```

