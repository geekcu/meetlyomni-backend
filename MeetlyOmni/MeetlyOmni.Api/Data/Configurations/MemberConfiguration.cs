// <copyright file="MemberConfiguration.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Data.Configurations
{
    using MeetlyOmni.Api.Common.Enums.Members;
    using MeetlyOmni.Api.Common.Extensions;
    using MeetlyOmni.Api.Data.Entities;

    using Microsoft.EntityFrameworkCore;
    using Microsoft.EntityFrameworkCore.Metadata.Builders;

    public class MemberConfiguration : IEntityTypeConfiguration<Member>
    {
        public void Configure(EntityTypeBuilder<Member> builder)
        {
            builder.HasKey(m => m.MemberId);
            builder.Property(m => m.MemberId)
                   .HasMaxLength(50)
                   .IsRequired();

            builder.Property(m => m.OrgId).IsRequired();
            builder.Property(m => m.LocalMemberNumber).IsRequired();

            builder.ConfigureString(m => m.Email, maxLength: 255);
            builder.ConfigureString(m => m.PasswordHash, maxLength: 255);
            builder.ConfigureString(m => m.Nickname, maxLength: 100, isRequired: false);
            builder.ConfigureString(m => m.Phone, maxLength: 20, isRequired: false);
            builder.ConfigureString(m => m.LanguagePref, maxLength: 10);

            builder.ConfigureJsonbList(m => m.Tags);

            builder.Property(m => m.Points)
                   .HasDefaultValue(0);

            builder.ConfigureEnumAsString(
                m => m.Status,
                maxLength: 20,
                defaultValue: MemberStatus.Active);

            builder.Property(m => m.CreatedAt)
                   .HasDefaultValueSql("NOW()");

            builder.Property(m => m.UpdatedAt)
                   .HasDefaultValueSql("NOW()");

            // foreign key relationships
            builder.HasOne(m => m.Organization)
                   .WithMany(o => o.Members)
                   .HasForeignKey(m => m.OrgId);
        }
    }
}
