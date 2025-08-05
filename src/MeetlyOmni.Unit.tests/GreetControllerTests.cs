// <copyright file="GreetControllerTests.cs" company="PlaceholderCompany">
// Copyright (c) PlaceholderCompany. All rights reserved.
// </copyright>

namespace MeetlyOmni.Unit.Tests
{
    using MeetlyOmni.Api.Controllers;
    using MeetlyOmni.Api.Service;
    using Microsoft.AspNetCore.Mvc;
    using Moq;
    using Newtonsoft.Json;

    /// <summary>
    /// Tests for the GreetController.
    /// </summary>
    public class GreetControllerTests
    {
        private readonly Mock<IGreetService> mockGreetService;
        private readonly GreetController controller;

        /// <summary>
        /// Initializes a new instance of the <see cref="GreetControllerTests"/> class.
        /// </summary>
        public GreetControllerTests()
        {
            this.mockGreetService = new Mock<IGreetService>();
            this.controller = new GreetController(this.mockGreetService.Object);
        }

        /// <summary>
        /// Tests GetGreeting with valid name.
        /// </summary>
        [Fact]
        [Trait("Category", "Unit")]
        public void GetGreeting_WithValidName_ReturnsOkResult()
        {
            // Arrange
            var name = "John";
            this.mockGreetService.Setup(x => x.GetGreeting(name)).Returns("Hello, John!");

            // Act
            var result = this.controller.GetGreeting(name);

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            Assert.NotNull(okResult.Value);
            var json = JsonConvert.SerializeObject(okResult.Value);
            Assert.Contains("Hello, John!", json);
        }

        /// <summary>
        /// Tests GetGreeting with default name.
        /// </summary>
        [Fact]
        [Trait("Category", "Unit")]
        public void GetGreeting_WithDefaultName_ReturnsOkResult()
        {
            // Arrange
            this.mockGreetService.Setup(x => x.GetGreeting("World")).Returns("Hello, World!");

            // Act
            var result = this.controller.GetGreeting();

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            Assert.NotNull(okResult.Value);
            var json = JsonConvert.SerializeObject(okResult.Value);
            Assert.Contains("Hello, World!", json);
        }

        /// <summary>
        /// Tests GetFarewell with valid name.
        /// </summary>
        [Fact]
        [Trait("Category", "Unit")]
        public void GetFarewell_WithValidName_ReturnsOkResult()
        {
            // Arrange
            var name = "Alice";
            this.mockGreetService.Setup(x => x.GetFarewell(name)).Returns("Goodbye, Alice!");

            // Act
            var result = this.controller.GetFarewell(name);

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            Assert.NotNull(okResult.Value);
            var json = JsonConvert.SerializeObject(okResult.Value);
            Assert.Contains("Goodbye, Alice!", json);
        }

        /// <summary>
        /// Tests ValidateName with valid name.
        /// </summary>
        [Fact]
        [Trait("Category", "Unit")]
        public void ValidateName_WithValidName_ReturnsOkResult()
        {
            // Arrange
            var name = "John";
            this.mockGreetService.Setup(x => x.IsValidName(name)).Returns(true);

            // Act
            var result = this.controller.ValidateName(name);

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            Assert.NotNull(okResult.Value);
            var json = JsonConvert.SerializeObject(okResult.Value);
            Assert.Contains(name, json);
            Assert.Contains("true", json);
        }

        /// <summary>
        /// Tests ValidateName with invalid name.
        /// </summary>
        [Fact]
        [Trait("Category", "Unit")]
        public void ValidateName_WithInvalidName_ReturnsOkResult()
        {
            // Arrange
            var name = "John123";
            this.mockGreetService.Setup(x => x.IsValidName(name)).Returns(false);

            // Act
            var result = this.controller.ValidateName(name);

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            Assert.NotNull(okResult.Value);
            var json = JsonConvert.SerializeObject(okResult.Value);
            Assert.Contains(name, json);
            Assert.Contains("false", json);
        }

        /// <summary>
        /// Tests GetCustomGreeting with valid request.
        /// </summary>
        [Fact]
        [Trait("Category", "Unit")]
        public void GetCustomGreeting_WithValidRequest_ReturnsOkResult()
        {
            // Arrange
            var request = new GreetRequest { Name = "John" };
            this.mockGreetService.Setup(x => x.IsValidName("John")).Returns(true);
            this.mockGreetService.Setup(x => x.GetGreeting("John")).Returns("Hello, John!");

            // Act
            var result = this.controller.GetCustomGreeting(request);

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            Assert.NotNull(okResult.Value);
            var json = JsonConvert.SerializeObject(okResult.Value);
            Assert.Contains("Hello, John!", json);
        }

        /// <summary>
        /// Tests GetCustomGreeting with invalid request.
        /// </summary>
        [Fact]
        [Trait("Category", "Unit")]
        public void GetCustomGreeting_WithInvalidRequest_ReturnsBadRequest()
        {
            // Arrange
            var request = new GreetRequest { Name = "John123" };
            this.mockGreetService.Setup(x => x.IsValidName("John123")).Returns(false);

            // Act
            var result = this.controller.GetCustomGreeting(request);

            // Assert
            var badRequestResult = Assert.IsType<BadRequestObjectResult>(result);
            Assert.NotNull(badRequestResult.Value);
            var json = JsonConvert.SerializeObject(badRequestResult.Value);
            Assert.Contains("Invalid name provided", json);
        }
    }
}
