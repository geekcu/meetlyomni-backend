using MeetlyOmni.Api.Entities;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore;
using MeetlyOmni.Api.Enums;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

namespace MeetlyOmni.Api.Data.Configurations
{
    public class OrganizationConfiguration : IEntityTypeConfiguration<Organization>
    {
        public void Configure(EntityTypeBuilder<Organization> builder)
        {
            var converter = new EnumToStringConverter<PlanType>();

            builder.Property(o => o.IndustryTags)
                   .HasColumnType("jsonb");

            builder.Property(u => u.PlanType)
                   .HasConversion(converter)
                   .HasMaxLength(20)
                   .HasDefaultValue(PlanType.Free);

        }
    }

}
