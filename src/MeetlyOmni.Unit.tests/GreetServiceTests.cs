// <copyright file="GreetServiceTests.cs" company="PlaceholderCompany">
// Copyright (c) PlaceholderCompany. All rights reserved.
// </copyright>

namespace MeetlyOmni.Unit.Tests
{
    using MeetlyOmni.Api.Service;

    public class GreetServiceTests
    {
        private readonly GreetService service = new ();

        [Fact]
        [Trait("Category", "Unit")]
        public void SayHello_WithName_ReturnsPersonalizedGreeting()
        {
            var result = this.service.SayHello("Alice");
            Assert.Equal("Hello, Alice!", result);
        }

        [Fact]
        [Trait("Category", "Unit")]
        public void SayHello_EmptyName_ReturnsGuestGreeting()
        {
            var result = this.service.SayHello(string.Empty);
            Assert.Equal("Hello, Guest!", result);
        }
    }
}
