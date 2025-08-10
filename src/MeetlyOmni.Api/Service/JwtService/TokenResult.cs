namespace MeetlyOmni.Api.Service.JwtService
{
    public record TokenResult(string Token, DateTimeOffset ExpiresAt);
}
