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
        /// <summary>
        /// Gets a greeting message.
        /// </summary>
        /// <param name="name">The name to greet.</param>
        /// <returns>A greeting message.</returns>
        public string GetGreeting(string name)
        {
            if (!this.IsValidName(name))
            {
                return "Hello, Guest!";
            }

            return $"Hello, {name}!";
        }

        /// <summary>
        /// Gets a farewell message.
        /// </summary>
        /// <param name="name">The name to say goodbye to.</param>
        /// <returns>A farewell message.</returns>
        public string GetFarewell(string name)
        {
            if (!this.IsValidName(name))
            {
                return "Goodbye, Guest!";
            }

            return $"Goodbye, {name}!";
        }

        /// <summary>
        /// Validates if a name is valid.
        /// </summary>
        /// <param name="name">The name to validate.</param>
        /// <returns>True if the name is valid, false otherwise.</returns>
        public bool IsValidName(string name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                return false;
            }

            if (name.Length < 2 || name.Length > 50)
            {
                return false;
            }

            // Check if name contains only letters, spaces, and hyphens
            return name.All(c => char.IsLetter(c) || c == ' ' || c == '-');
        }
    }
}
