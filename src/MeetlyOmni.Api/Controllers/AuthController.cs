using System.Net.Http.Headers;
using System.Text.Json;
using Google.Apis.Auth;
using MeetlyOmni.Api.Data;
using MeetlyOmni.Api.Data.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace MeetlyOmni.Api.Controllers
{
    // 说明：此控制器包含与 Google OAuth2.0 + PKCE 相关的最小实现（MVF）。
    // 前端会将授权码（code）与 PKCE 的 code_verifier 发送到 /api/auth/google/exchange，
    // 后端携带这些信息向 Google token 端点交换 id_token/refresh_token；
    // 然后验证 id_token 的签名与受众（audience），并在本地创建/更新用户（以邮箱为键的 MVF 实现）。
    // 注意：生产最佳实践应存储 Google 的 sub 作为外部身份主键，并检查 email_verified。
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly ApplicationDbContext dbContext;
        private readonly IHttpClientFactory httpClientFactory;
        private readonly IConfiguration configuration;

        public AuthController(ApplicationDbContext dbContext, IHttpClientFactory httpClientFactory, IConfiguration configuration)
        {
            this.dbContext = dbContext;
            this.httpClientFactory = httpClientFactory;
            this.configuration = configuration;
        }

        // 输入模型：前端携带授权码与 PKCE 的 code_verifier
        public record GoogleExchangeRequest(string code, string codeVerifier);

        // 输出模型：当前 MVF 返回 Google 的 id_token。长期建议改为返回“自家应用的短时 JWT”。
        public record ExchangeResponse(bool success, string idToken, string message);

        [HttpPost("google/exchange")]
        public async Task<IActionResult> ExchangeGoogleCode([FromBody] GoogleExchangeRequest request, CancellationToken cancellationToken)
        {
            // 基本校验
            if (string.IsNullOrWhiteSpace(request.code) || string.IsNullOrWhiteSpace(request.codeVerifier))
            {
                return BadRequest(new { success = false, message = "Invalid code or code_verifier" });
            }

            // 从配置读取 Google OAuth 参数
            var clientId = configuration["Google:ClientId"];
            var clientSecret = configuration["Google:ClientSecret"]; // optional for PKCE in confidential clients
            var redirectUri = configuration["Google:RedirectUri"]; // http://localhost:3000/auth/google/callback

            var httpClient = httpClientFactory.CreateClient();
            var tokenEndpoint = "https://oauth2.googleapis.com/token";

            // 使用授权码 + code_verifier 交换令牌（PKCE）
            var form = new Dictionary<string, string>
            {
                ["client_id"] = clientId!,
                ["code"] = request.code,
                ["code_verifier"] = request.codeVerifier,
                ["redirect_uri"] = redirectUri!,
                ["grant_type"] = "authorization_code"
            };

            if (!string.IsNullOrEmpty(clientSecret))
            {
                form["client_secret"] = clientSecret;
            }

            using var httpRequest = new HttpRequestMessage(HttpMethod.Post, tokenEndpoint)
            {
                Content = new FormUrlEncodedContent(form)
            };
            httpRequest.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            using var httpResponse = await httpClient.SendAsync(httpRequest, cancellationToken);
            var json = await httpResponse.Content.ReadAsStringAsync(cancellationToken);
            if (!httpResponse.IsSuccessStatusCode)
            {
                return StatusCode((int)httpResponse.StatusCode, new { success = false, message = json });
            }

            using var doc = JsonDocument.Parse(json);
            var root = doc.RootElement;
            var idToken = root.GetProperty("id_token").GetString();
            var refreshToken = root.TryGetProperty("refresh_token", out var rt) ? rt.GetString() : null;

            if (string.IsNullOrEmpty(idToken))
            {
                return BadRequest(new { success = false, message = "id_token missing in token response" });
            }

            // 验证 id_token 的签名与受众（audience 必须等于本应用的 client_id）
            GoogleJsonWebSignature.Payload payload;
            try
            {
                payload = await GoogleJsonWebSignature.ValidateAsync(idToken, new GoogleJsonWebSignature.ValidationSettings
                {
                    Audience = new[] { clientId }
                });
            }
            catch (Exception ex)
            {
                return Unauthorized(new { success = false, message = $"Invalid id_token: {ex.Message}" });
            }

            // MVF：以邮箱为键在默认组织下查找/创建成员
            // 建议后续：存储 payload.Subject (sub) 作为外部身份主键，并检查 payload.EmailVerified。
            var email = payload.Email;
            if (string.IsNullOrWhiteSpace(email))
            {
                return BadRequest(new { success = false, message = "Email not present in id_token" });
            }

            // Ensure a default organization exists for MVF
            var defaultOrgCode = "default";
            var defaultOrg = await dbContext.Organizations.FirstOrDefaultAsync(o => o.OrganizationCode == defaultOrgCode, cancellationToken);
            if (defaultOrg == null)
            {
                defaultOrg = new Organization
                {
                    OrgId = Guid.NewGuid(),
                    OrganizationCode = defaultOrgCode,
                    OrganizationName = "Default Organization",
                    CreatedAt = DateTimeOffset.UtcNow,
                    UpdatedAt = DateTimeOffset.UtcNow
                };
                dbContext.Organizations.Add(defaultOrg);
                await dbContext.SaveChangesAsync(cancellationToken);
            }

            var orgId = defaultOrg.OrgId;
            var member = await dbContext.Members.FirstOrDefaultAsync(m => m.OrgId == orgId && m.Email == email, cancellationToken);
            if (member == null)
            {
                member = new Member
                {
                    OrgId = orgId,
                    LocalMemberNumber = 0,
                    Email = email,
                    Nickname = payload.Name,
                    CreatedAt = DateTimeOffset.UtcNow,
                    UpdatedAt = DateTimeOffset.UtcNow,
                    LastLogin = DateTimeOffset.UtcNow
                };
                dbContext.Members.Add(member);
            }
            else
            {
                member.Nickname ??= payload.Name;
                member.LastLogin = DateTimeOffset.UtcNow;
                member.UpdatedAt = DateTimeOffset.UtcNow;
            }
            await dbContext.SaveChangesAsync(cancellationToken);

            // 如果 Google 返回了 refresh_token，则写入 HttpOnly Cookie，便于后续刷新 id_token
            if (!string.IsNullOrEmpty(refreshToken))
            {
                Response.Cookies.Append(
                    "refresh_token",
                    refreshToken!,
                    new CookieOptions
                    {
                        HttpOnly = true,
                        Secure = Request.IsHttps,
                        SameSite = SameSiteMode.Lax,
                        Expires = DateTimeOffset.UtcNow.AddDays(30)
                    });
            }

            return Ok(new ExchangeResponse(true, idToken!, "ok"));
        }

        [HttpPost("refresh")]
        public async Task<IActionResult> RefreshIdToken(CancellationToken cancellationToken)
        {
            // 从 HttpOnly Cookie 读取 refresh_token，去 Google 刷新 id_token
            if (!Request.Cookies.TryGetValue("refresh_token", out var refreshToken) || string.IsNullOrEmpty(refreshToken))
            {
                return Unauthorized(new { success = false, message = "refresh_token cookie missing" });
            }

            var clientId = configuration["Google:ClientId"];
            var clientSecret = configuration["Google:ClientSecret"]; // optional with web server client

            var httpClient = httpClientFactory.CreateClient();
            var tokenEndpoint = "https://oauth2.googleapis.com/token";

            var form = new Dictionary<string, string>
            {
                ["client_id"] = clientId!,
                ["grant_type"] = "refresh_token",
                ["refresh_token"] = refreshToken
            };
            if (!string.IsNullOrEmpty(clientSecret))
            {
                form["client_secret"] = clientSecret;
            }

            using var httpRequest = new HttpRequestMessage(HttpMethod.Post, tokenEndpoint)
            {
                Content = new FormUrlEncodedContent(form)
            };
            httpRequest.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            using var httpResponse = await httpClient.SendAsync(httpRequest, cancellationToken);
            var json = await httpResponse.Content.ReadAsStringAsync(cancellationToken);
            if (!httpResponse.IsSuccessStatusCode)
            {
                return StatusCode((int)httpResponse.StatusCode, new { success = false, message = json });
            }

            using var doc = JsonDocument.Parse(json);
            var root = doc.RootElement;
            var idToken = root.GetProperty("id_token").GetString();
            if (string.IsNullOrEmpty(idToken))
            {
                return BadRequest(new { success = false, message = "id_token missing in refresh response" });
            }

            return Ok(new ExchangeResponse(true, idToken!, "ok"));
        }

        public record ProfileResponse(string name, string email);

        [HttpGet("profile")]
        public async Task<IActionResult> GetProfile(CancellationToken cancellationToken)
        {
            // 从 Authorization: Bearer <token> 头读取前端携带的 id_token（MVF：直接使用 Google id_token）
            var authHeader = Request.Headers["Authorization"].ToString();
            if (string.IsNullOrWhiteSpace(authHeader) || !authHeader.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
            {
                return Unauthorized(new { success = false, message = "Missing Bearer token" });
            }

            var idToken = authHeader.Substring("Bearer ".Length).Trim();
            if (string.IsNullOrWhiteSpace(idToken))
            {
                return Unauthorized(new { success = false, message = "Invalid Bearer token" });
            }

            var clientId = configuration["Google:ClientId"];
            try
            {
                var payload = await GoogleJsonWebSignature.ValidateAsync(idToken, new GoogleJsonWebSignature.ValidationSettings
                {
                    Audience = new[] { clientId }
                });

                var name = payload.Name ?? string.Empty;
                var email = payload.Email ?? string.Empty;
                return Ok(new ProfileResponse(name, email));
            }
            catch (Exception ex)
            {
                return Unauthorized(new { success = false, message = $"Invalid id_token: {ex.Message}" });
            }
        }
    }
}


