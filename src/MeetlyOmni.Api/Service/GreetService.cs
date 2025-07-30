namespace MeetlyOmni.Api.Service
{
    public class GreetService : IGreetService
    {
        public string GetGreeting(string name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                return "Hello, Guest!";
            }

            return $"Hello, {name}!";
        }
    }
}
