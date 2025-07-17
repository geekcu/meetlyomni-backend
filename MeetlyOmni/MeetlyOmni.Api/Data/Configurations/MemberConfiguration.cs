using MeetlyOmni.Api.Entities;
using MeetlyOmni.Api.Enums;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore;

namespace MeetlyOmni.Api.Data.Configurations
{
    public class MemberConfiguration : IEntityTypeConfiguration<Member>
    {
        public void Configure(EntityTypeBuilder<Member> builder)
        {
            builder.Property(m => m.Tags)
                   .HasColumnType("jsonb");

            builder.Property(m => m.Status)
                   .HasConversion<string>()
                   .HasMaxLength(20)
                   .HasDefaultValue(MemberStatus.Active);
        }
    }
}
