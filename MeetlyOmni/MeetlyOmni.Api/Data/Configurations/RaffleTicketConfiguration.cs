using MeetlyOmni.Api.Entities;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore;
using MeetlyOmni.Api.Enums;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

namespace MeetlyOmni.Api.Data.Configurations
{
    public class RaffleTicketConfiguration : IEntityTypeConfiguration<RaffleTicket>
    {
        public void Configure(EntityTypeBuilder<RaffleTicket> builder)
        {
            var statusConverter = new EnumToStringConverter<RaffleTicketStatus>();
            builder.Property(r => r.Status)
                   .HasConversion(statusConverter)
                   .HasMaxLength(20)
                   .HasColumnType("varchar(20)");
        }
    }

}
