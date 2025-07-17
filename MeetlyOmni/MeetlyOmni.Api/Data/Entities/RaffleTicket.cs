using MeetlyOmni.Api.Common.Enums;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MeetlyOmni.Api.Data.Entities
{
    public class RaffleTicket
    {
        [Key]
        public Guid TicketId { get; set; } = Guid.NewGuid();

        [Required]
        [ForeignKey(nameof(Organization))]
        public Guid OrgId { get; set; }

        [Required]
        [MaxLength(50)]
        public required string MemberId { get; set; }

        [MaxLength(30)]
        public RaffleIssuedSource? IssuedBy { get; set; }
        public RaffleTicketStatus Status { get; set; } = RaffleTicketStatus.Unused;

        public DateTimeOffset IssueTime { get; set; } = DateTimeOffset.UtcNow;

        // Navigation
        public Member? Member { get; set; }
        public Organization? Organization { get; set; }
    }

}
