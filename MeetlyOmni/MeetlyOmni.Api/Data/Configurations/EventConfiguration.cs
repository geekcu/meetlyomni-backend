// <copyright file="EventConfiguration.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

using MeetlyOmni.Api.Common.Enums.Event;
using MeetlyOmni.Api.Common.Extensions;
using MeetlyOmni.Api.Data.Entities;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

public class EventConfiguration : IEntityTypeConfiguration<Event>
{
    public void Configure(EntityTypeBuilder<Event> builder)
    {
        builder.HasKey(e => e.EventId);

        builder.Property(e => e.OrgId).IsRequired();

        builder.ConfigureString(e => e.Title, maxLength: 255, isRequired: false);
        builder.ConfigureString(e => e.Location, maxLength: 255, isRequired: false);
        builder.ConfigureString(e => e.Language, maxLength: 10, isRequired: false);

        builder.ConfigureEnumAsString(
            e => e.Status,
            maxLength: 20,
            defaultValue: EventStatus.Draft);
    }
}
