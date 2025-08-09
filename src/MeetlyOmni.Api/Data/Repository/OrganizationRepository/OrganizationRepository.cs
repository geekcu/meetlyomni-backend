// <copyright file="OrganizationRepository.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Data.Repository.OrganizationRepository
{
    using MeetlyOmni.Api.Data.Entities;
    using Microsoft.EntityFrameworkCore;

    public class OrganizationRepository : IOrganizationRepository
    {
        private readonly ApplicationDbContext _context;

        public OrganizationRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task AddOrganizationAsync(Organization organization)
        {
            _context.Organizations.Add(organization);
            await _context.SaveChangesAsync();
        }

        public async Task<bool> OrganizationCodeExistsAsync(string organizationCode)
        {
            return await _context.Organizations
                .AnyAsync(o => o.OrganizationCode == organizationCode);
        }
    }
}
