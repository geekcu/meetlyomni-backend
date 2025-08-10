using MeetlyOmni.Api.Models.Members;

namespace MeetlyOmni.Api.Service.AuthService
{
    public interface IAuthService
    {
        Task<LoginResponseDto> LoginAsync(LoginBindingModel model);
    }
}
