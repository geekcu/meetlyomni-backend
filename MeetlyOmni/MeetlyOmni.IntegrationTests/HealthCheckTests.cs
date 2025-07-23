using System.Net.Http;
using System.Threading.Tasks;
using Xunit;

public class BackendStatusTests
{
    private readonly HttpClient _httpClient = new HttpClient();

    [Fact]
    public async Task Backend_Is_Available()
    {
        var response = await _httpClient.GetAsync("https://localhost:7011/swagger/index.html");
        response.EnsureSuccessStatusCode(); // Ensures 200-299
    }
}