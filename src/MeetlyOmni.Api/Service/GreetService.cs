// <copyright file="GreetService.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Service
{
    public class GreetService : IGreetService
    {
        public string GetGreeting(string name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                return "Hello, Guest!";
            }

            return $"Hello, {name}!";
        }

        public string GetFarewell(string name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                return "Goodbye, Guest!";
            }

            return $"Goodbye, {name}!";
        }
    }
}
