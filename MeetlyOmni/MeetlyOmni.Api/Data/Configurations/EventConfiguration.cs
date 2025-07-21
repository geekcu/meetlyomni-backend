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

        builder.ConfigureString(nameof(Event.Title), maxLength: 255, isRequired: false);
        builder.ConfigureString(nameof(Event.Location), maxLength: 255, isRequired: false);
        builder.ConfigureString(nameof(Event.Language), maxLength: 10, isRequired: false);

        builder.ConfigureEnumAsString<EventStatus>(
            nameof(Event.Status),
            maxLength: 20,
            defaultValue: EventStatus.Draft);
    }
}
