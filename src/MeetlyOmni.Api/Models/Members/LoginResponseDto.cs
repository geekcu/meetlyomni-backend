namespace MeetlyOmni.Api.Models.Members
{
    public class LoginResponseDto
    {
        public string AccessToken { get; set; }

        public DateTimeOffset ExpiresAt { get; set; }

        public string TokenType { get; set; } = "Bearer";
    }
}
