// <copyright file="JwtOption.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Service.JwtService
{
    public class JwtOptions
    {
        public string Issuer { get; set; }

        public string Audience { get; set; }

        public string KeyB64 { get; set; }

        public int AccessTokenMinutes { get; set; }
    }
}
