// <copyright file="DemoController.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

using Microsoft.AspNetCore.Mvc;

namespace MeetlyOmni.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DemoController : ControllerBase
{
    [HttpGet]
    public IActionResult Get()
    {
        return this.Ok(new { message = "Hello from DemoController" });
    }

    [HttpGet("covered")]
    public IActionResult Covered()
    {
        return this.Ok("This method is covered by tests");
    }

    [HttpGet("uncovered")]
    public IActionResult Uncovered()
    {
        // 这个方法不会被测试覆盖
        return this.Ok("This method is not covered by tests");
    }
}
