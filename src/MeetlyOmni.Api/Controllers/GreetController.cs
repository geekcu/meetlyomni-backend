namespace MeetlyOmni.Api.Controllers
{
    using MeetlyOmni.Api.Service;

    using Microsoft.AspNetCore.Mvc;

    [ApiController]
    [Route("[controller]")]
    public class GreetController : ControllerBase
    {
        private readonly IGreetService _greetService;

        public GreetController(IGreetService greetService)
        {
            _greetService = greetService;
        }

        [HttpGet("{name}")]
        public IActionResult Greet(string name)
        {
            var message = _greetService.GetGreeting(name);
            return Ok(new { message });
        }
    }

}
