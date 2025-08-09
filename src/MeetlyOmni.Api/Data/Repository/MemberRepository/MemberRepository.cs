
using MeetlyOmni.Api.Data.Entities;

namespace MeetlyOmni.Api.Data.Repository.MemberRepository
{
    public class MemberRepository : IMemberRepository
    {
        private readonly ApplicationDbContext _context;

        public MemberRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task UpdateMemberAsync(Member member)
        {
            _context.Update(member);
            await _context.SaveChangesAsync();
        }
    }
}
