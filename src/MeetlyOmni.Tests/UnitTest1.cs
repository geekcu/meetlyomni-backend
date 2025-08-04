// <copyright file="UnitTest1.cs" company="PlaceholderCompany">
// Copyright (c) PlaceholderCompany. All rights reserved.
// </copyright>

namespace MeetlyOmni.Tests
{
    using MeetlyOmni.Api.Controllers;
    using MeetlyOmni.Api.Service;

    using Microsoft.AspNetCore.Mvc;

    using Moq;

    public class GreetServiceTests
    {
        [Fact]
        public void GetGreeting_Returns_Custom_Message()
        {
            var service = new GreetService();
            var result = service.GetGreeting("Alice");

            Assert.Equal("Hello, Alice!", result);
        }

        [Fact]
        public void GetFarewell_Returns_Custom_Message()
        {
            var service = new GreetService();
            var result = service.GetFarewell("Alice");

            Assert.Equal("Goodbye, Alice!", result);
        }

        [Fact]
        public void GetGreeting_Returns_Guest_When_Empty()
        {
            var service = new GreetService();
            var result = service.GetGreeting(string.Empty);

            Assert.Equal("Hello, Guest!", result);
        }
    }

    public class GreetControllerTests
    {
        [Fact]
        public void Greet_Returns_OkResult_With_Message()
        {
            var mockService = new Mock<IGreetService>();
            mockService.Setup(s => s.GetGreeting("Bob")).Returns("Hello, Bob!");

            var controller = new GreetController(mockService.Object);
            var result = controller.Greet("Bob") as OkObjectResult;

            Assert.NotNull(result);
            Assert.Equal(200, result.StatusCode);

            var value = result.Value?.ToString();
            Assert.Contains("Hello, Bob!", value);
        }
    }
}
