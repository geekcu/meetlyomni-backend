// <copyright file="IOrganizationService.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Service.OrganizationService
{
    using MeetlyOmni.Api.Data.Entities;

    public interface IOrganizationService
    {
        Task<Organization> CreateOrganizationAsync(string orgName);
    }
}
