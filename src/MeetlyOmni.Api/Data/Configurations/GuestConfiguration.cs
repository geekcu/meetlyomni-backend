// <copyright file="GuestConfiguration.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Data.Configurations
{
    using MeetlyOmni.Api.Common.Extensions;
    using MeetlyOmni.Api.Data.Entities;

    using Microsoft.EntityFrameworkCore;
    using Microsoft.EntityFrameworkCore.Metadata.Builders;

    public class GuestConfiguration : IEntityTypeConfiguration<Guest>
    {
        public void Configure(EntityTypeBuilder<Guest> builder)
        {
            builder.HasKey(g => g.GuestId);
            builder.Property(g => g.EventId).IsRequired();

            builder.ConfigureString(g => g.Name, maxLength: 255);
            builder.ConfigureString(g => g.Company, maxLength: 255, isRequired: false);
            builder.ConfigureString(g => g.Position, maxLength: 255, isRequired: false);
            builder.ConfigureString(g => g.AvatarUrl, isRequired: false);
            builder.ConfigureString(g => g.Bio, isRequired: false);

            builder.ConfigureJsonbObject(g => g.SocialLinks);

            builder.Property(g => g.Order)
                   .IsRequired(); // 可选加默认值：.HasDefaultValue(0)
        }
    }
}
