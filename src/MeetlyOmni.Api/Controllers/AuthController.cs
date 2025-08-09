using MeetlyOmni.Api.Models.Members;
using MeetlyOmni.Api.Service.RegistrationService;

using Microsoft.AspNetCore.Mvc;

namespace MeetlyOmni.Api.Controllers
{
    [ApiController]
    [Route("api/auth")]
    public class AuthController : ControllerBase
    {
        private readonly IRegistrationService _registration;

        public AuthController(IRegistrationService registration)
        {
            _registration = registration;
        }

        [HttpPost("signup")]
        public async Task<IActionResult> SignUp([FromBody] SignUpBindingModel model)
        {
            if (!ModelState.IsValid) return ValidationProblem(ModelState);

            var dto = await _registration.SignUpAdminAsync(model);

            return Ok(dto);
        }
    }
}
