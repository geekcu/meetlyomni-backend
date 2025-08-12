// <copyright file="TestController.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

using Microsoft.AspNetCore.Mvc;

namespace MeetlyOmni.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TestController : ControllerBase
{
    [HttpGet]
    public IActionResult Get()
    {
        return this.Ok(new { message = "Hello from TestController", timestamp = DateTime.UtcNow });
    }

    [HttpGet("ping")]
    public IActionResult Ping()
    {
        return this.Ok("pong");
    }

    [HttpGet("uncovered")]
    public IActionResult Uncovered()
    {
        // 这个方法不会被测试覆盖，用来演示覆盖率检查
        return this.Ok("This method is not covered by tests");
    }
}
