using MeetlyOmni.Api.Entities;
using MeetlyOmni.Api.Enums;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Reflection.Emit;

namespace MeetlyOmni.Api.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }

        public DbSet<Member> Members { get; set; }
        public DbSet<Organization> Organizations { get; set; }
        public DbSet<RaffleTicket> RaffleTickets { get; set; }
        public DbSet<MemberActivityLog> MemberActivityLogs { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // JSONB List<string> mapping to PostgreSQL jsonb type
            modelBuilder.Entity<Member>()
                .Property(m => m.Tags)
                .HasColumnType("jsonb");

            modelBuilder.Entity<Organization>()
                .Property(o => o.IndustryTags)
                .HasColumnType("jsonb");

            modelBuilder.Entity<MemberActivityLog>()
                .Property(a => a.EventDetail)
                .HasColumnType("jsonb");

            modelBuilder.Entity<RaffleTicket>()
                .Property(r => r.Status)
                .HasConversion(
                    v => v.ToString().ToLower(),     // convert enum to string to database
                    v => Enum.Parse<RaffleTicketStatus>(v, true) // ignore case when reading from database
                )
                .HasMaxLength(20)
                .HasColumnType("varchar(20)");

            modelBuilder.Entity<Member>()
                .Property(m => m.Status)
                .HasConversion<string>() // convert enum to string to database
                .HasMaxLength(20)
                .HasDefaultValue(MemberStatus.Active);

            base.OnModelCreating(modelBuilder);
        }
    }
}
