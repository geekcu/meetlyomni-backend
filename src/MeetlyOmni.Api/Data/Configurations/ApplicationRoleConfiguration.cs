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
        // 设置表名为 Roles 而不是默认的 AspNetRoles
        builder.ToTable("Roles");

        builder.Property(r => r.Id)
               .HasDefaultValueSql("gen_random_uuid()")
               .IsRequired();

        builder.ConfigureString(r => r.Name, maxLength: 100);
        builder.ConfigureString(r => r.NormalizedName, maxLength: 100);
        builder.ConfigureString(r => r.Description, maxLength: 500, isRequired: false);

        // 为 ConcurrencyStamp 设置默认值
        builder.Property(r => r.ConcurrencyStamp)
               .HasDefaultValueSql("gen_random_uuid()::text")
               .IsRequired();
    }
}
