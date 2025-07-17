using MeetlyOmni.Api.Entities;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore;
using MeetlyOmni.Api.Enums;

namespace MeetlyOmni.Api.Data.Configurations
{
    public class RaffleTicketConfiguration : IEntityTypeConfiguration<RaffleTicket>
    {
        public void Configure(EntityTypeBuilder<RaffleTicket> builder)
        {
            builder.Property(r => r.Status)
                   .HasConversion(
                       v => v.ToString().ToLower(),
                       v => Enum.Parse<RaffleTicketStatus>(v, true))
                   .HasMaxLength(20)
                   .HasColumnType("varchar(20)");
        }
    }

}
