// <copyright file="GreetService.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Service
{
    /// <summary>
    /// Implementation of the greeting service.
    /// </summary>
    public class GreetService : IGreetService
    {
        public string SayHello(string name)
        {
            if (string.IsNullOrWhiteSpace(name))
                return "Hello, Guest!";
            return $"Hello, {name}!";
        }
    }
}
