// <copyright file="IOrganizationRepository.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Data.Repository.OrganizationRepository
{
    using MeetlyOmni.Api.Data.Entities;

    public interface IOrganizationRepository
    {
        Task AddOrganizationAsync(Organization organization);

        Task<bool> OrganizationCodeExistsAsync(string organizationCode);
    }
}
