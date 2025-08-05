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
        /// <summary>
        /// Gets a greeting message.
        /// </summary>
        /// <param name="name">The name to greet.</param>
        /// <returns>A greeting message.</returns>
        string GetGreeting(string name);

        /// <summary>
        /// Gets a farewell message.
        /// </summary>
        /// <param name="name">The name to say goodbye to.</param>
        /// <returns>A farewell message.</returns>
        string GetFarewell(string name);

        /// <summary>
        /// Validates if a name is valid.
        /// </summary>
        /// <param name="name">The name to validate.</param>
        /// <returns>True if the name is valid, false otherwise.</returns>
        bool IsValidName(string name);
    }
}
