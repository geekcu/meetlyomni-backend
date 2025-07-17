using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using MeetlyOmni.Api.Common.Enums;
using MeetlyOmni.Api.Data.Entities;

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
