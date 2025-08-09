using MeetlyOmni.Api.Data.Entities;

namespace MeetlyOmni.Api.Data.Repository.OrganizationRepository
{
    public interface IOrganizationRepository
    {
        Task AddOrganizationAsync(Organization organization);

        Task<bool> OrganizationCodeExistsAsync(string organizationCode);
    }
}
