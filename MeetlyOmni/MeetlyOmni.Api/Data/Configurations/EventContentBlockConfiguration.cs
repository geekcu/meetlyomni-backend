// <copyright file="EventContentBlockConfiguration.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Data.Configurations
{
    using MeetlyOmni.Api.Common.Enums.EventContentBlock;
    using MeetlyOmni.Api.Common.Extensions;
    using MeetlyOmni.Api.Data.Entities;

    using Microsoft.EntityFrameworkCore;
    using Microsoft.EntityFrameworkCore.Metadata.Builders;

    public class EventContentBlockConfiguration : IEntityTypeConfiguration<EventContentBlock>
    {
        public void Configure(EntityTypeBuilder<EventContentBlock> builder)
        {
            builder.HasKey(b => b.BlockId);
            builder.Property(b => b.EventId).IsRequired();

            builder.ConfigureEnumAsString<BlockType>(
                nameof(EventContentBlock.BlockType),
                maxLength: 30,
                isRequired: true);

            builder.ConfigureString(nameof(EventContentBlock.Title), maxLength: 255, isRequired: false);

            builder.ConfigureJsonbObject(nameof(EventContentBlock.Content));
        }
    }
}
