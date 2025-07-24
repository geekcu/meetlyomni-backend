using System.Text.Json.Nodes;

public static class LaunchSettingsReader
{
    public static string GetBaseUrl(string profileName = "https")
    {
        // Adjust path to point to your API project relative to the test project
        var pathToLaunchSettings = Path.Combine(
            AppContext.BaseDirectory, // bin/Debug/net8.0
            "../../../../MeetlyOmni.Api/Properties/launchSettings.json");

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
