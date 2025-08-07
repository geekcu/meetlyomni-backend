// <copyright file="ApplicationRoleConfiguration.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

using MeetlyOmni.Api.Common.Extensions;
using MeetlyOmni.Api.Data.Entities;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MeetlyOmni.Api.Data.Configurations;
public class ApplicationRoleConfiguration : IEntityTypeConfiguration<ApplicationRole>
{
    public void Configure(EntityTypeBuilder<ApplicationRole> builder)
    {
        // using Roles instead of AspNetRoles
        builder.ToTable("Roles");

        builder.Property(r => r.Id)
               .HasDefaultValueSql("gen_random_uuid()")
               .IsRequired();

        builder.ConfigureString(r => r.Name, maxLength: 100);
        builder.ConfigureString(r => r.NormalizedName, maxLength: 100);
        builder.ConfigureString(r => r.ConcurrencyStamp, maxLength: 255);
        builder.ConfigureString(r => r.Description, maxLength: 500, isRequired: false);

        builder.Property(r => r.CreatedAt)
               .HasDefaultValueSql("NOW()");

        builder.Property(r => r.UpdatedAt)
               .HasDefaultValueSql("NOW()");

        // 注意：角色通过 ApplicationDbInitializer 在应用启动时创建
        // 这样可以确保角色存在，并且有完整的错误处理和日志记录
    }
}
