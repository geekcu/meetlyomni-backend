using MeetlyOmni.Api.Models.Members;

namespace MeetlyOmni.Api.Service.RegistrationService
{
    public interface IRegistrationService
    {
        Task<MemberDto> SignUpAdminAsync(SignUpBindingModel input);
    }
}
