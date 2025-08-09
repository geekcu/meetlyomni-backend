// <copyright file="OrganizationService.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Service.OrganizationService
{
    using System.Security.Cryptography;
    using MeetlyOmni.Api.Common.Enums.Organization;
    using MeetlyOmni.Api.Data;
    using MeetlyOmni.Api.Data.Entities;
    using MeetlyOmni.Api.Data.Repository.OrganizationRepository;

    public class OrganizationService : IOrganizationService
    {
        public readonly ApplicationDbContext _context;
        public readonly IOrganizationRepository _orgRepo;

        public OrganizationService(ApplicationDbContext context, IOrganizationRepository orgRepo)
        {
            _context = context;
            _orgRepo = orgRepo;
        }

        private async Task<string> GenerateUniqueOrgCodeAsync(string name)
        {
            string BaseSlug(string s) =>
                new string(s.Trim().ToLowerInvariant().Where(ch => char.IsLetterOrDigit(ch) || ch == ' ').ToArray())
                .Replace(' ', '-');

            var baseSlug = BaseSlug(name);
            for (int i = 0; i < 5; i++)
            {
                var suffix = Convert.ToHexString(RandomNumberGenerator.GetBytes(3)).ToLowerInvariant();
                var code = $"{baseSlug}-{suffix}";
                if (!await _orgRepo.OrganizationCodeExistsAsync(code))
                {
                    return code;
                }
            }

            return $"{baseSlug}-{Guid.NewGuid():N}";
        }

        public async Task<Organization> CreateOrganizationAsync(string orgName)
        {
            var org = new Organization
            {
                OrgId = Guid.NewGuid(),
                OrganizationName = orgName.Trim(),
                OrganizationCode = await GenerateUniqueOrgCodeAsync(orgName),
                PlanType = PlanType.Free,
                CreatedAt = DateTimeOffset.UtcNow,
                UpdatedAt = DateTimeOffset.UtcNow,
            };
            await _orgRepo.AddOrganizationAsync(org);
            return org;
        }
    }
}
