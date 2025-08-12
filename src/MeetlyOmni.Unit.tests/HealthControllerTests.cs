using MeetlyOmni.Api.Controllers;

using Microsoft.AspNetCore.Mvc;

namespace MeetlyOmni.Unit.tests;

public class HealthControllerTests
{
    private readonly HealthController _controller;

    public HealthControllerTests()
    {
        _controller = new HealthController();
    }

    [Fact]
    public void Get_ShouldReturnOkResult()
    {
        // Act
        var result = _controller.Get();

        // Assert
        Assert.IsType<OkObjectResult>(result);
        var okResult = result as OkObjectResult;
        Assert.NotNull(okResult);
        Assert.Equal(200, okResult.StatusCode);
    }

    [Fact]
    public void Get_ShouldReturnHealthStatus()
    {
        // Act
        var result = _controller.Get();

        // Assert
        var okResult = result as OkObjectResult;
        Assert.NotNull(okResult);
        Assert.NotNull(okResult.Value);
    }

    [Fact]
    public void Ping_ShouldReturnOkResult()
    {
        // Act
        var result = _controller.Ping();

        // Assert
        Assert.IsType<OkObjectResult>(result);
        var okResult = result as OkObjectResult;
        Assert.NotNull(okResult);
        Assert.Equal(200, okResult.StatusCode);
    }

    [Fact]
    public void Ping_ShouldReturnPong()
    {
        // Act
        var result = _controller.Ping();

        // Assert
        var okResult = result as OkObjectResult;
        Assert.NotNull(okResult);
        Assert.Equal("pong", okResult.Value);
    }
}
