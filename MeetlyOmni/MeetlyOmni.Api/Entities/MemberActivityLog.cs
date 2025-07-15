using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MeetlyOmni.Api.Entities
{
    public class MemberActivityLog
    {
        [Key]
        public Guid LogId { get; set; } = Guid.NewGuid();

        [Required]
        [MaxLength(50)]
        public required string MemberId { get; set; }

        [Required]
        [ForeignKey(nameof(Organization))]
        public Guid OrgId { get; set; }

        [MaxLength(50)]
        public required string EventType { get; set; }

        public string? EventDetail { get; set; } // JSONB → string

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation
        public Member? Member { get; set; }
        public Organization? Organization { get; set; }
    }

}
