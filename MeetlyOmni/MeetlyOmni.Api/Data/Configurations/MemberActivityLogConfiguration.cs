using MeetlyOmni.Api.Entities;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore;

namespace MeetlyOmni.Api.Data.Configurations
{
    public class MemberActivityLogConfiguration : IEntityTypeConfiguration<MemberActivityLog>
    {
        public void Configure(EntityTypeBuilder<MemberActivityLog> builder)
        {
            builder.Property(a => a.EventDetail)
                   .HasColumnType("jsonb");
        }
    }

}
