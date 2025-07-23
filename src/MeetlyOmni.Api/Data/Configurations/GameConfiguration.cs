// <copyright file="GameConfiguration.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Data.Configurations
{
    using MeetlyOmni.Api.Common.Enums.Game;
    using MeetlyOmni.Api.Common.Extensions;
    using MeetlyOmni.Api.Data.Entities;

    using Microsoft.EntityFrameworkCore;
    using Microsoft.EntityFrameworkCore.Metadata.Builders;

    public class GameConfiguration : IEntityTypeConfiguration<Game>
    {
        public void Configure(EntityTypeBuilder<Game> builder)
        {
            builder.HasKey(g => g.GameId);

            builder.ConfigureEnumAsString(
                g => g.Type,
                maxLength: 30);

            builder.ConfigureString(g => g.Title, maxLength: 255, isRequired: false);

            builder.ConfigureJsonbObject(g => g.Config);

            builder.Property(g => g.CreatedBy)
                   .IsRequired(false);

            builder.Property(g => g.CreatedAt)
                   .HasDefaultValueSql("NOW()");

            // Foreign key relationships (CreatedBy可能指向Member或Organization，这里先留空)
            // TODO: 根据业务需求设置CreatedBy的外键关系

            // CreatedBy relationship (assuming it points to Organization)
            // Uncomment when the relationship is clarified:
            // builder.HasOne<Organization>()
            //        .WithMany()
            //        .HasForeignKey(g => g.CreatedBy)
            //        .OnDelete(DeleteBehavior.SetNull);

            // Performance indexes
            builder.HasIndex(g => g.Type)
                   .HasDatabaseName("IX_Game_Type");

            builder.HasIndex(g => g.CreatedBy)
                   .HasDatabaseName("IX_Game_CreatedBy");

            builder.HasIndex(g => g.CreatedAt)
                   .HasDatabaseName("IX_Game_CreatedAt");
        }
    }
}
