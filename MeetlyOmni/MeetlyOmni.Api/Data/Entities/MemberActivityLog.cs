// <copyright file="MemberActivityLog.cs" company="PlaceholderCompany">
// Copyright (c) PlaceholderCompany. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Data.Entities
{
    using System.Text.Json.Nodes;

    using MeetlyOmni.Api.Common.Enums.MemberActivityLog;

    public class MemberActivityLog
    {
        public Guid LogId { get; set; }

        public string MemberId { get; set; } = string.Empty;

        public Guid OrgId { get; set; }

        public MemberEventType EventType { get; set; }

        public JsonObject? EventDetail { get; set; }

        public DateTimeOffset CreatedAt { get; set; }

        // Navigation
        public Member? Member { get; set; }

        public Organization? Organization { get; set; }
    }
}
