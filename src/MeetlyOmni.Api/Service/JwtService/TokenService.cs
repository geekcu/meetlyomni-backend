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

        public async Task<TokenResult> GenerateTokenAsync(Member member)
        {
            var now = DateTimeOffset.UtcNow;
            var expires = now.AddMinutes(_opt.AccessTokenMinutes);

            var claims = new List<Claim>
        {
            new (JwtRegisteredClaimNames.Sub, member.Id.ToString()),
            new (JwtRegisteredClaimNames.Email, member.Email ?? string.Empty),
            new (JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString("N")),
            new (JwtRegisteredClaimNames.Iat, now.ToUnixTimeSeconds().ToString(), ClaimValueTypes.Integer64),
            new ("org_id", member.OrgId.ToString()),
        };

            // 追加 full_name（如果你注册时存了这个 claim）
            var userClaims = await _userManager.GetClaimsAsync(member);
            var fullName = userClaims.FirstOrDefault(c => c.Type == "full_name")?.Value;
            if (!string.IsNullOrWhiteSpace(fullName))
            {
                claims.Add(new Claim("full_name", fullName));
            }

            // 角色写入 "role"（与你的 JwtBearerOptions.RoleClaimType = "role" 对齐）
            var roles = await _userManager.GetRolesAsync(member);
            foreach (var role in roles)
            {
                claims.Add(new Claim("role", role));
            }

            var jwt = new JwtSecurityToken(
                issuer: _opt.Issuer,
                audience: _opt.Audience,
                claims: claims,
                notBefore: now.UtcDateTime,
                expires: expires.UtcDateTime,
                signingCredentials: _creds);

            var tokenString = new JwtSecurityTokenHandler().WriteToken(jwt);
            return new TokenResult(tokenString, expires);
        }
    }
}
