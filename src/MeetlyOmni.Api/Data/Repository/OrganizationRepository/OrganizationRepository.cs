using MeetlyOmni.Api.Data.Entities;

using Microsoft.EntityFrameworkCore;

namespace MeetlyOmni.Api.Data.Repository.OrganizationRepository
{
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
