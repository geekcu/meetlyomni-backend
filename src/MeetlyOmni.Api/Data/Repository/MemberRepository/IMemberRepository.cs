using MeetlyOmni.Api.Data.Entities;

namespace MeetlyOmni.Api.Data.Repository.MemberRepository
{
    public interface IMemberRepository
    {
        Task UpdateMemberAsync(Member member);
    }
}
