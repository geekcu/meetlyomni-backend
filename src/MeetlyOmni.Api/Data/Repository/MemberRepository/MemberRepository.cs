// <copyright file="MemberRepository.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Data.Repository.MemberRepository
{
    using MeetlyOmni.Api.Data.Entities;

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
