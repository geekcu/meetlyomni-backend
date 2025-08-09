// <copyright file="IMemberRepository.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Data.Repository.MemberRepository
{
    using MeetlyOmni.Api.Data.Entities;

    public interface IMemberRepository
    {
        Task UpdateMemberAsync(Member member);
    }
}
