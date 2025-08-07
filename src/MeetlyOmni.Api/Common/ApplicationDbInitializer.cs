// <copyright file="ApplicationDbInitializer.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

using MeetlyOmni.Api.Common.Constants;
using MeetlyOmni.Api.Data.Entities;

using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;

namespace MeetlyOmni.Api.Common;
public static class ApplicationDbInitializer
{
    public static async Task SeedRolesAsync(IServiceProvider serviceProvider)
    {
        var roleManager = serviceProvider.GetRequiredService<RoleManager<ApplicationRole>>();
        var logger = serviceProvider.GetRequiredService<ILogger<ApplicationDbInitializerLog>>();

        // 系统核心角色
        var roles = new[]
        {
            new { Name = RoleConstants.Admin, Description = "公司管理员 - 拥有完整权限" },
            new { Name = RoleConstants.Employee, Description = "公司员工 - 拥有有限权限" },
        };

        foreach (var roleInfo in roles)
        {
            if (!await roleManager.RoleExistsAsync(roleInfo.Name))
            {
                logger.LogInformation("Creating role: {RoleName}", roleInfo.Name);

                var result = await roleManager.CreateAsync(new ApplicationRole
                {
                    Name = roleInfo.Name,
                    NormalizedName = roleInfo.Name.ToUpperInvariant(),
                    Description = roleInfo.Description,
                });

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

    public static async Task SeedDefaultAdminAsync(IServiceProvider serviceProvider)
    {
        var userManager = serviceProvider.GetRequiredService<UserManager<Member>>();
        var logger = serviceProvider.GetRequiredService<ILogger<ApplicationDbInitializerLog>>();

        var adminEmail = "admin@meetlyomni.com";
        var adminUser = await userManager.FindByEmailAsync(adminEmail);

        if (adminUser == null)
        {
            logger.LogInformation("Creating default admin user...");

            var adminMember = new Member
            {
                UserName = adminEmail,
                Email = adminEmail,
                EmailConfirmed = true,
                OrgId = Guid.Empty,
                LocalMemberNumber = 1,
                LanguagePref = "en",
            };

            var defaultPassword = "Admin@123!";
            var result = await userManager.CreateAsync(adminMember, defaultPassword);

            if (result.Succeeded)
            {
                await userManager.AddToRoleAsync(adminMember, RoleConstants.Admin);
                logger.LogInformation("Successfully created default admin user: {Email}", adminEmail);
                logger.LogWarning("Default admin password is: {Password} - Please change it immediately!", defaultPassword);
            }
            else
            {
                logger.LogError(
                    "Failed to create default admin user: {Errors}",
                    string.Join(", ", result.Errors.Select(e => e.Description)));
            }
        }
        else
        {
            logger.LogDebug("Default admin user already exists: {Email}", adminEmail);
        }
    }
}

// 非 static 类型用于注入 ILogger
public class ApplicationDbInitializerLog
{
}
