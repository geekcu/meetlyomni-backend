// <copyright file="GreetController.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Controllers
{
    using MeetlyOmni.Api.Service;

    using Microsoft.AspNetCore.Mvc;

    [ApiController]
    [Route("[controller]")]
    public class GreetController : ControllerBase
    {
        private readonly IGreetService greetService;

        public GreetController(IGreetService greetService)
        {
            this.greetService = greetService;
        }

        [HttpGet("{name}")]
        public IActionResult Greet(string name)
        {
            var message = this.greetService.GetGreeting(name);
            return this.Ok(new { message });
        }
    }
}
