using MeetlyOmni.Api.Data.Entities;

namespace MeetlyOmni.Api.Service.JwtService
{
    public interface ITokenService
    {
        Task<string> GenerateTokenAsync(Member member);
    }
}
