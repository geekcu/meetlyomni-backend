using MeetlyOmni.Api.Common.Enums;
using System.ComponentModel.DataAnnotations;

namespace MeetlyOmni.Api.Data.Entities
{
    public class Organization
    {
        [Key]
        public Guid OrgId { get; set; } = Guid.NewGuid();

        [Required]
        [MaxLength(30)]
        public required string OrganizationCode { get; set; }

        [Required]
        [MaxLength(100)]
        public required string OrganizationName { get; set; }

        public string? LogoUrl { get; set; }
        public string? CoverImageUrl { get; set; }
        public string? Description { get; set; }
        [MaxLength(255)]
        public string? Location { get; set; }
        public string? WebsiteUrl { get; set; }

        public List<string>? IndustryTags { get; set; }

        public int FollowerCount { get; set; } = 0;
        public bool IsVerified { get; set; } = false;

        [MaxLength(20)]
        public PlanType PlanType { get; set; }

        public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
        public DateTimeOffset UpdatedAt { get; set; } = DateTimeOffset.UtcNow;

        // Navigation
        public ICollection<Member> Members { get; set; } = new List<Member>();
    }
}
