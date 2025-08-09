// <copyright file="Program.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

using MeetlyOmni.Api.Data;
using MeetlyOmni.Api.Mapping;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Cors.Infrastructure;
using DotNetEnv;
using Npgsql;

var builder = WebApplication.CreateBuilder(args);

// Load .env for local development (if present)
try
{
    var envPath = Path.Combine(AppContext.BaseDirectory, ".env");
    if (File.Exists(envPath))
    {
        Env.Load(envPath);
    }
}
catch
{
    // ignore .env loading errors in production
}

// Logging config (optional, but recommended)
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddDebug();

var connectionString = builder.Configuration.GetConnectionString("MeetlyOmniDb")
    ?? Environment.GetEnvironmentVariable("ConnectionStrings__MeetlyOmniDb")
    ?? (Environment.GetEnvironmentVariable("DB_NAME") is { } db
        ? $"Host={Environment.GetEnvironmentVariable("DB_HOST") ?? "db"};Port={Environment.GetEnvironmentVariable("DB_PORT") ?? "5432"};Database={db};Username={Environment.GetEnvironmentVariable("DB_USER") ?? "postgres"};Password={Environment.GetEnvironmentVariable("DB_PASS") ?? "postgres"}"
        : null);

if (string.IsNullOrEmpty(connectionString))
{
    throw new InvalidOperationException("Database connection string 'MeetlyOmniDb' is not configured.");
}

// PostgreSQL DbContext with dynamic JSON (Npgsql 8) to support jsonb <-> List/Dictionary
var dataSourceBuilder = new NpgsqlDataSourceBuilder(connectionString);
dataSourceBuilder.EnableDynamicJson();
var dataSource = dataSourceBuilder.Build();

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseNpgsql(dataSource));

// Health Check
builder.Services.AddHealthChecks()
    .AddNpgSql(connectionString);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Register AutoMapper and scan for profiles starting from MappingProfile's assembly
builder.Services.AddAutoMapper(typeof(MappingProfile));

// CORS for frontend origin
var corsSection = builder.Configuration.GetSection("Cors:AllowedOrigins");
var allowedOrigins = corsSection.Get<string[]>() ?? Array.Empty<string>();
builder.Services.AddCors(options =>
{
    options.AddPolicy("FrontendCors", policy =>
    {
        policy.WithOrigins(allowedOrigins)
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

// HttpClient for outbound calls (Google token endpoint)
builder.Services.AddHttpClient();

var app = builder.Build();

// Swagger
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("FrontendCors");
app.UseAuthorization();

app.MapControllers();
app.MapHealthChecks("/health");

app.Run();
