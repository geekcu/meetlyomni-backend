using MeetlyOmni.Api.Entities;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore;
using MeetlyOmni.Api.Enums;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

namespace MeetlyOmni.Api.Data.Configurations
{
    public class MemberActivityLogConfiguration : IEntityTypeConfiguration<MemberActivityLog>
    {
        public void Configure(EntityTypeBuilder<MemberActivityLog> builder)
        {
            var converter = new EnumToStringConverter<MemberEventType>();

            builder.Property(a => a.EventDetail)
                   .HasColumnType("jsonb");

            builder.Property(a => a.EventType)
                   .HasConversion(converter)
                   .HasMaxLength(50)
                   .HasColumnType("varchar(50)");
        }
    }

}
