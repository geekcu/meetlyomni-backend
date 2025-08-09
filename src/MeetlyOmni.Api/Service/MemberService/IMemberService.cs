using MeetlyOmni.Api.Data.Entities;
using MeetlyOmni.Api.Models.Members;

namespace MeetlyOmni.Api.Service.MemberService
{
    public interface IMemberService
    {
        Task<Member> CreateAdminAsync(Guid orgId, string email, string password, string phone, string fullName);
    }
}
