// <copyright file="GreetController.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Controllers
{
    using MeetlyOmni.Api.Service;
    using Microsoft.AspNetCore.Mvc;

    /// <summary>
    /// Controller for greeting operations.
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class GreetController : ControllerBase
    {
        private readonly IGreetService greetService;

        /// <summary>
        /// Initializes a new instance of the <see cref="GreetController"/> class.
        /// </summary>
        /// <param name="greetService">The greeting service.</param>
        public GreetController(IGreetService greetService)
        {
            this.greetService = greetService;
        }

        /// <summary>
        /// Gets a greeting message.
        /// </summary>
        /// <param name="name">The name to greet.</param>
        /// <returns>A greeting message.</returns>
        [HttpGet("hello")]
        public IActionResult GetGreeting([FromQuery] string name = "World")
        {
            var greeting = this.greetService.GetGreeting(name);
            return this.Ok(new { message = greeting });
        }

        /// <summary>
        /// Gets a farewell message.
        /// </summary>
        /// <param name="name">The name to say goodbye to.</param>
        /// <returns>A farewell message.</returns>
        [HttpGet("goodbye")]
        public IActionResult GetFarewell([FromQuery] string name = "World")
        {
            var farewell = this.greetService.GetFarewell(name);
            return this.Ok(new { message = farewell });
        }

        /// <summary>
        /// Validates a name.
        /// </summary>
        /// <param name="name">The name to validate.</param>
        /// <returns>Validation result.</returns>
        [HttpGet("validate")]
        public IActionResult ValidateName([FromQuery] string name)
        {
            var isValid = this.greetService.IsValidName(name);
            return this.Ok(new { name, isValid });
        }

        /// <summary>
        /// Gets a custom greeting with validation.
        /// </summary>
        /// <param name="name">The name to greet.</param>
        /// <returns>A custom greeting or error message.</returns>
        [HttpPost("custom")]
        public IActionResult GetCustomGreeting([FromBody] GreetRequest request)
        {
            if (!this.greetService.IsValidName(request.Name))
            {
                return this.BadRequest(new { error = "Invalid name provided" });
            }

            var greeting = this.greetService.GetGreeting(request.Name);
            return this.Ok(new { message = greeting, timestamp = DateTime.UtcNow });
        }
    }

    /// <summary>
    /// Request model for custom greeting.
    /// </summary>
    public class GreetRequest
    {
        /// <summary>
        /// Gets or sets the name.
        /// </summary>
        public string Name { get; set; } = string.Empty;
    }
}
