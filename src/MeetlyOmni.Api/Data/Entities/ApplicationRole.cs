// <copyright file="ApplicationRole.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

using Microsoft.AspNetCore.Identity;

namespace MeetlyOmni.Api.Data.Entities;
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