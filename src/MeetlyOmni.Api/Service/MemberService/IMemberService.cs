// <copyright file="IMemberService.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Service.MemberService
{
    using MeetlyOmni.Api.Data.Entities;
    using MeetlyOmni.Api.Models.Members;

    public interface IMemberService
    {
        Task<Member> CreateAdminAsync(Guid orgId, string email, string password, string phone, string fullName);
    }
}
