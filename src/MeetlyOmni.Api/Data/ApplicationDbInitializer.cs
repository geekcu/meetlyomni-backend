// <copyright file="ApplicationDbInitializer.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

using MeetlyOmni.Api.Common.Constants;
using MeetlyOmni.Api.Data.Entities;

using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;

namespace MeetlyOmni.Api.Data;
public static class ApplicationDbInitializer
{
    public static async Task SeedRolesAsync(IServiceProvider serviceProvider)
    {
        var roleManager = serviceProvider.GetRequiredService<RoleManager<ApplicationRole>>();
        var logger = serviceProvider.GetRequiredService<ILogger<ApplicationDbInitializerLog>>();

        var roles = new[]
        {
            new { Name = RoleConstants.Admin, Description = "Company admin - has full access to all features" },
            new { Name = RoleConstants.Employee, Description = "Company employee - can create events and games" },
        };

        foreach (var roleInfo in roles)
        {
            if (!await roleManager.RoleExistsAsync(roleInfo.Name))
            {
                logger.LogInformation("Creating role: {RoleName}", roleInfo.Name);

                var role = new ApplicationRole(roleInfo.Name)
                {
                    Description = roleInfo.Description,
                };

                var result = await roleManager.CreateAsync(role);

                if (result.Succeeded)
                {
                    logger.LogInformation("Successfully created role: {RoleName}", roleInfo.Name);
                }
                else
                {
                    logger.LogError(
                        "Failed to create role {RoleName}: {Errors}",
                        roleInfo.Name, string.Join(", ", result.Errors.Select(e => e.Description)));
                }
            }
            else
            {
                logger.LogDebug("Role already exists: {RoleName}", roleInfo.Name);
            }
        }
    }
}

// 用于 ILogger 注入上下文
public class ApplicationDbInitializerLog
{
}
