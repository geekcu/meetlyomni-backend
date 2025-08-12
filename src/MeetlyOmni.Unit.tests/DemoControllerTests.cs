using MeetlyOmni.Api.Controllers;

using Microsoft.AspNetCore.Mvc;

namespace MeetlyOmni.Unit.tests;

public class DemoControllerTests
{
    private readonly DemoController _controller;

    public DemoControllerTests()
    {
        _controller = new DemoController();
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
    public void Covered_ShouldReturnOkResult()
    {
        // Act
        var result = _controller.Covered();

        // Assert
        Assert.IsType<OkObjectResult>(result);
        var okResult = result as OkObjectResult;
        Assert.NotNull(okResult);
        Assert.Equal(200, okResult.StatusCode);
    }

    [Fact]
    public void Covered_ShouldReturnCorrectMessage()
    {
        // Act
        var result = _controller.Covered();

        // Assert
        var okResult = result as OkObjectResult;
        Assert.NotNull(okResult);
        Assert.Equal("This method is covered by tests", okResult.Value);
    }

    // 注意：我们没有测试 Uncovered 方法，这样覆盖率会低于80%
}
