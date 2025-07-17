using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using MeetlyOmni.Api.Common.Enums;
using MeetlyOmni.Api.Data.Entities;

namespace MeetlyOmni.Api.Data.Configurations
{
    public class RaffleTicketConfiguration : IEntityTypeConfiguration<RaffleTicket>
    {
        public void Configure(EntityTypeBuilder<RaffleTicket> builder)
        {
            var statusConverter = new EnumToStringConverter<RaffleTicketStatus>();
            var issuedSource = new EnumToStringConverter<RaffleIssuedSource>();

            builder.Property(r => r.Status)
                   .HasConversion(statusConverter)
                   .HasMaxLength(20)
                   .HasColumnType("varchar(20)");

            builder.Property(r => r.IssuedBy)
                   .HasConversion(issuedSource)
                   .HasMaxLength(20);
        }
    }

}
