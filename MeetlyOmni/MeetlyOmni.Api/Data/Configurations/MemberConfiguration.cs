using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MeetlyOmni.Api.Entities;
using MeetlyOmni.Api.Enums;

namespace MeetlyOmni.Api.Data.Configurations
{
    public class MemberConfiguration : IEntityTypeConfiguration<Member>
    {
        public void Configure(EntityTypeBuilder<Member> builder)
        {
            builder.Property(m => m.Tags)
                   .HasColumnType("jsonb")
                   .HasDefaultValueSql("'[]'::jsonb"); // avoid null

            builder.Property(m => m.Status)
                   .HasConversion<string>()
                   .HasMaxLength(20)
                   .HasDefaultValue(MemberStatus.Active);
        }
    }
}

