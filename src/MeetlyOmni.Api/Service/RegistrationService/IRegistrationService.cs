// <copyright file="IRegistrationService.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Service.RegistrationService
{
    using MeetlyOmni.Api.Models.Members;

    public interface IRegistrationService
    {
        Task<MemberDto> SignUpAdminAsync(SignUpBindingModel input);
    }
}
