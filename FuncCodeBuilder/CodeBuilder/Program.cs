using ProxyFunctionRouteUpdater;
using System.Text.Json;
using YamlDotNet.Serialization.NamingConventions;

var yamlDeserializer = new YamlDotNet.Serialization.DeserializerBuilder()
    .WithNamingConvention(CamelCaseNamingConvention.Instance)
    .Build();

var cloudProvider = args[0];

var type = args[1];
var proxyFunctionLocation = args[2];
var specFolderLocation = string.Empty;

var myConfig = yamlDeserializer.Deserialize<RouteConfig>(File.ReadAllText($"{proxyFunctionLocation}/route-config.yaml"));
string myConfigJsonFormat = JsonSerializer.Serialize(myConfig);
myConfigJsonFormat = $"\"{myConfigJsonFormat.Replace("\"", "\\\"")}\"";

if (cloudProvider.Equals("AWS"))
{
    specFolderLocation = args[3];
    var parts = File.ReadAllLines($"{specFolderLocation}/terraform.tfvars");
    var part = parts
        .Select((item, index) => new { Item = item, Index = index })
        .Where(c => c.Item.Contains("RouteConfig"))
        .First();
    parts[part.Index] = $"RouteConfig = \"{JsonSerializer.Serialize(myConfig).Replace("\"", "\\\"")}\"";

    File.WriteAllLines($"{specFolderLocation}/terraform.tfvars", parts);
    return;
}



var keyVaultName = string.Empty;
var functionAppName = string.Empty;
var funcName = string.Empty;

if (type.Equals("ApiManagement"))
{
    specFolderLocation = args[3];
    funcName = args[4];
}
else
{
    keyVaultName = args[3];
    functionAppName = args[4];
}

ApiSpec? apiSpec = default;

if (type.Equals("ApiManagement"))
{
    apiSpec = yamlDeserializer.Deserialize<ApiSpec>(File.ReadAllText($"{specFolderLocation}/api-spec.yml"));
    apiSpec.Paths.Clear();
}

var functionDirectoriesList = new List<string>();
myConfig.Functions.ForEach(f =>
{
    var functionName = f.Route.Split('/')[^1];

    if (type.Equals("ApiManagement"))
    {
        if (apiSpec != null)
        {
            apiSpec?.Paths.Add($"/{functionName}", new Fetch
            {
                Get = new Get
                {
                    OperationId = $"get-{functionName}",
                    Summary = functionName,
                    Responses = new Dictionary<string, DescriptionObj>
                                {
                                    { "200", new DescriptionObj { Description = "test" } }
                                }
                }
            });
        }
    }
    else
    {
        var functionDirExists = Directory.Exists($"{proxyFunctionLocation}/{functionName}");
        if (!functionDirExists)
        {
            functionDirectoriesList.Add(functionName);
            var createFunctionDirResult = Shell.Bash($"cd {proxyFunctionLocation}; func new --name {functionName} --template \"HTTP trigger\" --authlevel \"anonymous\" --methods \"get\" --custom", true);
        }
    }
});

if (type.Equals("ApiManagement"))
{
    var yamlSerializer = new YamlDotNet.Serialization.SerializerBuilder()
        .WithNamingConvention(CamelCaseNamingConvention.Instance)
        .Build();

    if (apiSpec != null)
    {
        apiSpec.Info.Title = funcName;
        apiSpec.Info.Description = $"Import from {funcName} Function App";
        apiSpec.Servers[0].Url = $"https://{funcName}.azurewebsites.net/api";
        foreach(var item in apiSpec.Security)
        {
            foreach(var i in item)
            {
                if(i.Value == null)
                {
                    item.Remove(i.Key);
                }
            }
        }
        var newApiSpec = yamlSerializer.Serialize(apiSpec);
        newApiSpec = newApiSpec.Replace("1.0", "'1.0'");
        newApiSpec = newApiSpec.Replace("200", "'200'");

        File.Delete($"{specFolderLocation}/api-spec.yml");
        File.WriteAllText($"{specFolderLocation}/api-spec.yml", newApiSpec);
    }
    return;
}

var updateKeyVaultResult = Shell.Bash($"az keyvault secret set --vault-name \"{keyVaultName}\" --name \"RouteConfig\" --value='{myConfigJsonFormat}'");
Console.WriteLine(updateKeyVaultResult);

var buildMainResult = Shell.Bash($"cd {proxyFunctionLocation}; env GOOS=linux GOARCH=amd64 go build ./main.go");
Console.WriteLine(buildMainResult);

var functionPublishResult = Shell.Bash($"cd {proxyFunctionLocation}; func azure functionapp publish {functionAppName} --custom");
Console.WriteLine(functionPublishResult);

functionDirectoriesList.ForEach(newFunctionDirectory =>
{
    Directory.Delete($"{proxyFunctionLocation}/{newFunctionDirectory}", true);
});