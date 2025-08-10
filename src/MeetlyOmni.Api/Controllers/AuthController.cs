// <copyright file="AuthController.cs" company="MeetlyOmni">
// Copyright (c) MeetlyOmni. All rights reserved.
// </copyright>

namespace MeetlyOmni.Api.Controllers
{
    using MeetlyOmni.Api.Models.Members;
    using MeetlyOmni.Api.Service.AuthService;
    using MeetlyOmni.Api.Service.RegistrationService;
    using Microsoft.AspNetCore.Mvc;

    [ApiController]
    [Route("api/auth")]
    public class AuthController : ControllerBase
    {
        private readonly IRegistrationService _registration;
        private readonly IAuthService _auth;

        public AuthController(IRegistrationService registration, IAuthService auth)
        {
            _registration = registration;
            _auth = auth;

        }

        [HttpPost("signup")]
        public async Task<IActionResult> SignUp([FromBody] SignUpBindingModel model)
        {
            if (!ModelState.IsValid) return ValidationProblem(ModelState);

            var dto = await _registration.SignUpAdminAsync(model);

            return Ok(dto);
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginBindingModel model)
        {
            if (!ModelState.IsValid) return ValidationProblem(ModelState);

            try
            {
                var dto = await _auth.LoginAsync(model);
                return Ok(dto);
            }
            catch (UnauthorizedAccessException)
            {
                return Unauthorized();
            }
        }
    }
}
