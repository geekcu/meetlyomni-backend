// <copyright file="ITokenService.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Service.JwtService
{
    using MeetlyOmni.Api.Data.Entities;

    public interface ITokenService
    {
        Task<string> GenerateTokenAsync(Member member);
    }
}
