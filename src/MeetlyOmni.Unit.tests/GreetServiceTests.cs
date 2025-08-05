// <copyright file="GreetServiceTests.cs" company="PlaceholderCompany">
// Copyright (c) PlaceholderCompany. All rights reserved.
// </copyright>

namespace MeetlyOmni.Unit.Tests
{
    using MeetlyOmni.Api.Service;

    /// <summary>
    /// Tests for the GreetService.
    /// </summary>
    public class GreetServiceTests
    {
        private readonly IGreetService greetService;

        /// <summary>
        /// Initializes a new instance of the <see cref="GreetServiceTests"/> class.
        /// </summary>
        public GreetServiceTests()
        {
            this.greetService = new GreetService();
        }

        /// <summary>
        /// Tests GetGreeting with valid name.
        /// </summary>
        [Fact]
        [Trait("Category", "Unit")]
        public void GetGreeting_WithValidName_ReturnsGreeting()
        {
            // Arrange
            var name = "John";

            // Act
            var result = this.greetService.GetGreeting(name);

            // Assert
            Assert.Equal("Hello, John!", result);
        }

        /// <summary>
        /// Tests GetGreeting with invalid name.
        /// </summary>
        [Fact]
        [Trait("Category", "Unit")]
        public void GetGreeting_WithInvalidName_ReturnsGuestGreeting()
        {
            // Arrange
            var name = string.Empty;

            // Act
            var result = this.greetService.GetGreeting(name);

            // Assert
            Assert.Equal("Hello, Guest!", result);
        }

        /// <summary>
        /// Tests GetFarewell with valid name.
        /// </summary>
        [Fact]
        [Trait("Category", "Unit")]
        public void GetFarewell_WithValidName_ReturnsFarewell()
        {
            // Arrange
            var name = "Alice";

            // Act
            var result = this.greetService.GetFarewell(name);

            // Assert
            Assert.Equal("Goodbye, Alice!", result);
        }

        /// <summary>
        /// Tests GetFarewell with invalid name.
        /// </summary>
        [Fact]
        [Trait("Category", "Unit")]
        public void GetFarewell_WithInvalidName_ReturnsGuestFarewell()
        {
            // Arrange
            var name = "   ";

            // Act
            var result = this.greetService.GetFarewell(name);

            // Assert
            Assert.Equal("Goodbye, Guest!", result);
        }

        /// <summary>
        /// Tests IsValidName with valid names.
        /// </summary>
        [Theory]
        [InlineData("John")]
        [InlineData("Mary Jane")]
        [InlineData("Jean-Pierre")]
        [Trait("Category", "Unit")]
        public void IsValidName_WithValidNames_ReturnsTrue(string name)
        {
            // Act
            var result = this.greetService.IsValidName(name);

            // Assert
            Assert.True(result);
        }

        /// <summary>
        /// Tests IsValidName with invalid names.
        /// </summary>
        [Theory]
        [InlineData("")]
        [InlineData("   ")]
        [InlineData(null)]
        [InlineData("A")]
        [InlineData("This is a very long name that exceeds the maximum allowed length of fifty characters")]
        [InlineData("John123")]
        [InlineData("Mary@Jane")]
        [Trait("Category", "Unit")]
        public void IsValidName_WithInvalidNames_ReturnsFalse(string name)
        {
            // Act
            var result = this.greetService.IsValidName(name);

            // Assert
            Assert.False(result);
        }
    }
}
