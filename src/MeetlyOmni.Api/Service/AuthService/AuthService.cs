using MeetlyOmni.Api.Data.Entities;
using MeetlyOmni.Api.Models.Members;
using MeetlyOmni.Api.Service.JwtService;
using Microsoft.AspNetCore.Identity;

namespace MeetlyOmni.Api.Service.AuthService
{
    public class AuthService: IAuthService
    {
        private readonly SignInManager<Member> _signInManager;
        private readonly UserManager<Member> _userManager;
        private readonly ITokenService _tokenService;

        public AuthService(
            SignInManager<Member> signInManager,
            UserManager<Member> userManager,
            ITokenService tokenService)
        {
            _signInManager = signInManager;
            _userManager = userManager;
            _tokenService = tokenService;
        }

        public async Task<LoginResponseDto> LoginAsync(LoginBindingModel input)
        {
            var user = await _userManager.FindByEmailAsync(input.Email.Trim());
            if (user is null)
            {
                throw new UnauthorizedAccessException("Invalid email or password.");
            }

            // 验证密码（不启用锁定策略可换成 CheckPasswordAsync）
            var result = await _signInManager.CheckPasswordSignInAsync(user, input.Password, lockoutOnFailure: true);
            if (!result.Succeeded)
            {
                throw new UnauthorizedAccessException("Invalid email or password.");
            }

            // 可更新最后登录时间
            user.LastLogin = DateTimeOffset.UtcNow;
            await _userManager.UpdateAsync(user);

            // 生成访问令牌（你的 ITokenService 里提供）
            var token = await _tokenService.GenerateTokenAsync(user);

            return new LoginResponseDto
            {
                AccessToken = token.Token,
                ExpiresAt = token.ExpiresAt,
                TokenType = "Bearer",
            };
        }
    }
}
