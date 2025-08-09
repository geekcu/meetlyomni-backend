using MeetlyOmni.Api.Data.Entities;

namespace MeetlyOmni.Api.Service.OrganizationService
{
    public interface IOrganizationService
    {
        Task<Organization> CreateOrganizationAsync(string orgName);
    }
}
