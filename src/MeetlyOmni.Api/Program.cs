// <copyright file="Program.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>
using System.Text;
using MeetlyOmni.Api.Data;
using MeetlyOmni.Api.Data.Entities;
using MeetlyOmni.Api.Data.Repository.MemberRepository;
using MeetlyOmni.Api.Data.Repository.OrganizationRepository;
using MeetlyOmni.Api.Mapping;
using MeetlyOmni.Api.Service.AuthService;
using MeetlyOmni.Api.Service.JwtService;
using MeetlyOmni.Api.Service.MemberService;
using MeetlyOmni.Api.Service.OrganizationService;
using MeetlyOmni.Api.Service.RegistrationService;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Npgsql;

var builder = WebApplication.CreateBuilder(args);

// ---- Logging ----
builder.Logging.ClearProviders();
builder.Logging.AddConsole();
builder.Logging.AddDebug();

// ---- DB Connection ----
var connectionString = builder.Configuration.GetConnectionString("MeetlyOmniDb");
if (string.IsNullOrWhiteSpace(connectionString))
{
    throw new InvalidOperationException("Database connection string 'MeetlyOmniDb' is not configured.");
}

// setup DataSource and start using Dynamic JSON（System.Text.Json）
var dsBuilder = new NpgsqlDataSourceBuilder(connectionString);
dsBuilder.EnableDynamicJson();           // key point, start Dynamic  JSON

// 如果偏好 Newtonsoft.Json，请用：dsBuilder.UseJsonNet();
var dataSource = dsBuilder.Build();

// ---- DbContext ----
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseNpgsql(dataSource));

// ---- Identity ----
builder.Services.AddIdentity<Member, ApplicationRole>(options =>
{
    options.Password.RequireDigit = true;
    options.Password.RequireLowercase = true;
    options.Password.RequireNonAlphanumeric = true;
    options.Password.RequireUppercase = true;
    options.Password.RequiredLength = 6;
    options.Password.RequiredUniqueChars = 1;

    options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(5);
    options.Lockout.MaxFailedAccessAttempts = 5;
    options.Lockout.AllowedForNewUsers = true;

    options.User.AllowedUserNameCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._@+";
    options.User.RequireUniqueEmail = true;
})
.AddEntityFrameworkStores<ApplicationDbContext>()
.AddDefaultTokenProviders();

// ---- Health Checks ----
builder.Services.AddHealthChecks().AddNpgSql(connectionString);

// ---- Controllers & Swagger ----
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// ---- AutoMapper ----
builder.Services.AddAutoMapper(typeof(MappingProfile));

// ---- Repositories ----
builder.Services.AddScoped<IOrganizationRepository, OrganizationRepository>();
builder.Services.AddScoped<IMemberRepository, MemberRepository>();

// ---- Application Services ----
builder.Services.AddScoped<IOrganizationService, OrganizationService>();
builder.Services.AddScoped<IMemberService, MemberService>();
builder.Services.AddScoped<IRegistrationService, RegistrationService>();
builder.Services.AddScoped<IAuthService, AuthService>();

// ---- JWT Options (强类型) ----
builder.Services.AddOptions<JwtOptions>()
    .Bind(builder.Configuration.GetSection("Jwt"))
    .Validate(o => !string.IsNullOrWhiteSpace(o.Issuer), "Jwt:Issuer is required")
    .Validate(o => !string.IsNullOrWhiteSpace(o.Audience), "Jwt:Audience is required")
    .Validate(o => !string.IsNullOrWhiteSpace(o.KeyB64), "Jwt:KeyB64 is required")
    .Validate(o => o.AccessTokenMinutes >= 5 && o.AccessTokenMinutes <= 120, "AccessTokenMinutes should be 5..120")
    .ValidateOnStart();

// ---- AuthN/AuthZ ----
builder.Services.AddAuthentication("Bearer")
    .AddJwtBearer(options =>
    {
        var jwt = builder.Configuration.GetSection("Jwt").Get<JwtOptions>() !;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = jwt.Issuer,

            ValidateAudience = true,
            ValidAudience = jwt.Audience,

            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Convert.FromBase64String(jwt.KeyB64)),

            ValidateLifetime = true,
            ClockSkew = TimeSpan.FromMinutes(2),

            // 和你发的 "role" claim 对齐
            RoleClaimType = "role",
        };
    });


builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins("http://localhost:3000", "https://localhost:3000")
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

builder.Services.AddAuthorization(options =>
{
    // 可选：示例策略（需要 Admin 角色）
    options.AddPolicy("RequireAdmin", p => p.RequireRole("Admin"));
});

// ---- App Services ----
builder.Services.AddScoped<ITokenService, TokenService>();

var app = builder.Build();

// ---- DB Init / Seed ----
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogInformation("Starting database initialization...");
        await ApplicationDbInitializer.SeedRolesAsync(services);
        logger.LogInformation("Database initialization completed successfully.");
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred while initializing the database.");
    }
}

// ---- Middleware ----
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseCors("AllowFrontend");
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHealthChecks("/health");

app.Run();
