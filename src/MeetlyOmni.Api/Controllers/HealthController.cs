// <copyright file="HealthController.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

using Microsoft.AspNetCore.Mvc;

namespace MeetlyOmni.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class HealthController : ControllerBase
{
    [HttpGet]
    public IActionResult Get()
    {
        return this.Ok(new { status = "healthy", timestamp = DateTime.UtcNow });
    }

    [HttpGet("ping")]
    public IActionResult Ping()
    {
        return this.Ok("pong");
    }
}
