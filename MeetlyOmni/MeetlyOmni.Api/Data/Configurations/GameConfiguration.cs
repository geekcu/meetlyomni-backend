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

            builder.Property(g => g.CreatedAt)
                   .HasDefaultValueSql("NOW()");
        }
    }
}
