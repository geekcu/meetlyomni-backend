using System;
using MeetlyOmni.Api.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace MeetlyOmni.Api.Data.DesignTime
{
    public class DesignTimeDbContextFactory : IDesignTimeDbContextFactory<ApplicationDbContext>
    {
        public ApplicationDbContext CreateDbContext(string[] args)
        {
            var optionsBuilder = new DbContextOptionsBuilder<ApplicationDbContext>();

            // Prefer full connection string from env var
            var conn = Environment.GetEnvironmentVariable("ConnectionStrings__MeetlyOmniDb");

            if (string.IsNullOrWhiteSpace(conn))
            {
                // Fallback compose-style variables
                var db = Environment.GetEnvironmentVariable("DB_NAME") ?? "meetly";
                var user = Environment.GetEnvironmentVariable("DB_USER") ?? "postgres";
                var pass = Environment.GetEnvironmentVariable("DB_PASS") ?? "postgres";
                var host = Environment.GetEnvironmentVariable("DB_HOST") ?? "db";
                var port = Environment.GetEnvironmentVariable("DB_PORT") ?? "5432";
                conn = $"Host={host};Port={port};Database={db};Username={user};Password={pass}";
            }

            optionsBuilder.UseNpgsql(conn);
            return new ApplicationDbContext(optionsBuilder.Options);
        }
    }
}


