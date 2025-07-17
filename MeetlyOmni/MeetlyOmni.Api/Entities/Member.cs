using MeetlyOmni.Api.Enums;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MeetlyOmni.Api.Entities
{
    public class Member
    {
        [Key]
        [MaxLength(50)]
        public required string MemberId { get; set; } // org_code + local_member_number 

        [Required]
        [ForeignKey(nameof(Organization))]
        public Guid OrgId { get; set; }

        public int LocalMemberNumber { get; set; }

        [Required, MaxLength(255)]
        public required string Email { get; set; }

        [Required, MaxLength(255)]
        public required string PasswordHash { get; set; }

        [MaxLength(100)]
        public string? Nickname { get; set; }

        [MaxLength(20)]
        public string? Phone { get; set; }

        [MaxLength(10)]
        public string LanguagePref { get; set; } = "en";

        public List<string> Tags { get; set; } = new(); // e.g., ["developer", "designer"] a list of string

        public int Points { get; set; } = 0;

        [Required]
        public MemberStatus Status { get; set; } = MemberStatus.Active;

        public DateTime? LastLogin { get; set; }

        public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
        public DateTimeOffset UpdatedAt { get; set; } = DateTimeOffset.UtcNow;


        // Navigation
        public Organization? Organization { get; set; }
        public ICollection<MemberActivityLog> ActivityLogs { get; set; } = new List<MemberActivityLog>();
        public ICollection<RaffleTicket> RaffleTickets { get; set; } = new List<RaffleTicket>();
    }

}
