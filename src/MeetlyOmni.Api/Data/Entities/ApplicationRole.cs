// <copyright file="ApplicationRole.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Data.Entities
{
    using Microsoft.AspNetCore.Identity;

    public class ApplicationRole : IdentityRole<Guid>
    {
        public ApplicationRole()
            : base()
        {
            this.CreatedAt = DateTimeOffset.UtcNow;
            this.UpdatedAt = DateTimeOffset.UtcNow;
        }

        public ApplicationRole(string roleName)
            : base(roleName)
        {
            this.CreatedAt = DateTimeOffset.UtcNow;
            this.UpdatedAt = DateTimeOffset.UtcNow;
        }

        public string? Description { get; set; }

        public DateTimeOffset CreatedAt { get; set; }

        public DateTimeOffset UpdatedAt { get; set; }
    }
}
