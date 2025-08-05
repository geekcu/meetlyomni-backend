// <copyright file="GreetController.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Controllers
{
    using MeetlyOmni.Api.Service;

    using Microsoft.AspNetCore.Mvc;

    [ApiController]
    [Route("api/[controller]")]
    public class GreetController : ControllerBase
    {
        private readonly IGreetService greetService;

        public GreetController(IGreetService greetService)
        {
            this.greetService = greetService;
        }

        [HttpGet("hello")]
        public IActionResult Hello([FromQuery] string name)
        {
            var message = this.greetService.SayHello(name);
            return this.Ok(new { message });
        }
    }
}
