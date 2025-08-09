// <copyright file="TokenService.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Service.JwtService
{
    using System.IdentityModel.Tokens.Jwt;
    using System.Security.Claims;
    using MeetlyOmni.Api.Data.Entities;
    using Microsoft.AspNetCore.Identity;
    using Microsoft.Extensions.Options;
    using Microsoft.IdentityModel.Tokens;

    public class TokenService : ITokenService
    {
        private readonly UserManager<Member> _userManager;
        private readonly JwtOptions _opt;
        private readonly SigningCredentials _creds;

        public TokenService(IOptions<JwtOptions> opt, UserManager<Member> userManager)
        {
            _userManager = userManager;
            _opt = opt.Value;
            var key = new SymmetricSecurityKey(Convert.FromBase64String(_opt.KeyB64));
            _creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        }

        public async Task<string> GenerateTokenAsync(Member member)
        {
            var now = DateTime.UtcNow;
            var claims = new List<Claim>
        {
            new (JwtRegisteredClaimNames.Sub, member.Id.ToString()),
            new (JwtRegisteredClaimNames.Email, member.Email ?? string.Empty),
            new (JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new (JwtRegisteredClaimNames.Iat,
            new DateTimeOffset(now).ToUnixTimeSeconds().ToString(), ClaimValueTypes.Integer64),
        };

            var roles = await _userManager.GetRolesAsync(member);
            foreach (var role in roles)
            {
                claims.Add(new Claim("role", role));
            }

            var token = new JwtSecurityToken(
                issuer: _opt.Issuer,
                audience: _opt.Audience,
                claims: claims,
                notBefore: now,
                expires: now.AddMinutes(_opt.AccessTokenMinutes),
                signingCredentials: _creds);

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
