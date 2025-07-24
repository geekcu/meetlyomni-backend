using System.Text.Json.Nodes;

public static class LaunchSettingsReader
{
    public static string GetBaseUrl(string profileName = "https")
    {
        if (string.IsNullOrWhiteSpace(profileName))
            throw new ArgumentException("Profile name cannot be null or empty", nameof(profileName));
        // Adjust path to point to your API project relative to the test project
        var apiProjectPath = Environment.GetEnvironmentVariable("API_PROJECT_PATH") ?? Path.Combine(AppContext.BaseDirectory, "../../../../MeetlyOmni.Api");
        var pathToLaunchSettings = Path.Combine(apiProjectPath, "Properties", "launchSettings.json");

        if (!File.Exists(pathToLaunchSettings))
            throw new FileNotFoundException("launchSettings.json not found", pathToLaunchSettings);

        var json = File.ReadAllText(pathToLaunchSettings);
        var root = JsonNode.Parse(json);

        var profiles = root?["profiles"]?.AsObject();
        if (profiles == null || !profiles.ContainsKey(profileName))
            throw new InvalidOperationException($"Profile '{profileName}' not found in launchSettings.json");

        var appUrls = profiles[profileName]?["applicationUrl"]?.ToString();
        if (string.IsNullOrEmpty(appUrls))
            throw new InvalidOperationException("applicationUrl is missing");

        // Return the first URL (https preferred)
        return appUrls.Split(';')
                      .FirstOrDefault(u => u.StartsWith("https")) ?? appUrls.Split(';').First();
    }
}
