// <copyright file="GreetController.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

using MeetlyOmni.Api.Service;

using Microsoft.AspNetCore.Mvc;

namespace MeetlyOmni.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class GreetController : ControllerBase
    {
        private readonly IGreetService _greetService;

        public GreetController(IGreetService greetService)
        {
            _greetService = greetService;
        }

        [HttpGet("hello")]
        public IActionResult Hello([FromQuery] string name)
        {
            var message = _greetService.SayHello(name);
            return Ok(new { message });
        }
    }
}
