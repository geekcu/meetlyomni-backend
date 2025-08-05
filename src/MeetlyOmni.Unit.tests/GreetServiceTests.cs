// <copyright file="GreetServiceTests.cs" company="PlaceholderCompany">
// Copyright (c) PlaceholderCompany. All rights reserved.
// </copyright>

using MeetlyOmni.Api.Service;

namespace MeetlyOmni.Unit.Tests
{
    public class GreetServiceTests
    {
        private readonly GreetService _service = new();

        [Fact]
        public void SayHello_WithName_ReturnsPersonalizedGreeting()
        {
            var result = _service.SayHello("Alice");
            Assert.Equal("Hello, Alice!", result);
        }

        [Fact]
        public void SayHello_EmptyName_ReturnsGuestGreeting()
        {
            var result = _service.SayHello("");
            Assert.Equal("Hello, Guest!", result);
        }
    }
}
