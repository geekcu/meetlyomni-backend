// <copyright file="MemberDto.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Models.Members
{
    public class MemberDto
    {
        public Guid Id { get; set; }

        public Guid OrganizationId { get; set; }

        public string OrganizationCode { get; set; }

        public string FullName { get; set; }

        public string Email { get; set; }

        public string PhoneNumber { get; set; }

        public string Role { get; set; }
    }
}
