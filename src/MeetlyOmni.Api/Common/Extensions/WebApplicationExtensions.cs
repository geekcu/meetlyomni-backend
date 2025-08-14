// <copyright file="WebApplicationExtensions.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

using MeetlyOmni.Api.Data;

using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace MeetlyOmni.Api.Common.Extensions;

public static class WebApplicationExtensions
{
    /// <summary>
    /// Applies database migrations and seeds initial data.
    /// </summary>
    /// <returns><placeholder>A <see cref="Task"/> representing the asynchronous operation.</placeholder></returns>
    public static async Task InitializeDatabaseAsync(this WebApplication app)
    {
        using var scope = app.Services.CreateScope();
        var services = scope.ServiceProvider;

        var configuration = services.GetRequiredService<IConfiguration>();
        var logger = services.GetRequiredService<ILoggerFactory>().CreateLogger("DatabaseInitialization");

        var applyMigrations = configuration.GetValue<bool>("Database:ApplyMigrationsOnStartup");
        var seedOnStartup = configuration.GetValue<bool>("Database:SeedOnStartup");
        var useAdvisoryLock = configuration.GetValue<bool>("Database:UseAdvisoryLock");
        var advisoryLockKey = configuration.GetValue<long>("Database:AdvisoryLockKey");
        var failFast = configuration.GetValue<bool>("Database:FailFastOnInitFailure", true);

        if (!applyMigrations && !seedOnStartup)
        {
            logger.LogInformation("Database initialization skipped by configuration.");
            return;
        }

        ApplicationDbContext? db = null;

        try
        {
            db = services.GetRequiredService<ApplicationDbContext>();

            await db.Database.OpenConnectionAsync();

            if (useAdvisoryLock)
            {
                logger.LogInformation("Acquiring advisory lock {Key}...", advisoryLockKey);
                await db.Database.ExecuteSqlRawAsync("SELECT pg_advisory_lock({0});", advisoryLockKey);
            }

            if (applyMigrations)
            {
                logger.LogInformation("Applying database migrations...");
                await db.Database.MigrateAsync();
            }

            if (seedOnStartup)
            {
                logger.LogInformation("Seeding baseline data (roles)...");
                await ApplicationDbInitializer.SeedRolesAsync(services);
            }

            logger.LogInformation("Database initialization completed successfully.");
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "An error occurred during database initialization.");
            if (failFast)
            {
                throw;
            }
        }
        finally
        {
            try
            {
                if (useAdvisoryLock && db is not null)
                {
                    logger.LogInformation("Releasing advisory lock {Key}...", advisoryLockKey);
                    await db.Database.ExecuteSqlRawAsync("SELECT pg_advisory_unlock({0});", advisoryLockKey);
                }
            }
            catch (Exception unlockEx)
            {
                logger.LogWarning(unlockEx, "Failed to release advisory lock.");
            }

            if (db is not null)
            {
                await db.Database.CloseConnectionAsync();
            }
        }
    }
}
