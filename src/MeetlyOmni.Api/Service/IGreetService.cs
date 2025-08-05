// <copyright file="IGreetService.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Service
{
    /// <summary>
    /// Interface for greeting service.
    /// </summary>
    public interface IGreetService
    {
        string SayHello(string name);
    }
}
