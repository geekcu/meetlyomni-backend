// <copyright file="MappingProfile.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Mapping
{
    using AutoMapper;

    using MeetlyOmni.Api.Data.Entities;
    using MeetlyOmni.Api.Models.Members;

    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            // TODO: map your DTOs, for example:
            // CreateMap<CreateUserDto, User>();
            CreateMap<Member, MemberDto>();
        }
    }
}
