using ProxyFunctionRouteUpdater;
using System.Text.Json;
using YamlDotNet.Serialization.NamingConventions;

var yamlDeserializer = new YamlDotNet.Serialization.DeserializerBuilder()
    .WithNamingConvention(CamelCaseNamingConvention.Instance)
    .Build();

var myConfig = yamlDeserializer.Deserialize<RouteConfig>(File.ReadAllText("../../Splunk/route-config.yaml"));

string myConfigJsonFormat = JsonSerializer.Serialize(myConfig);
myConfigJsonFormat = $"\"{myConfigJsonFormat.Replace("\"", "\\\"")}\"";

//var myConfigJsonFormat = JsonConvert.SerializeObject(myConfig);
//myConfigJsonFormat = JsonConvert.ToString(myConfigJsonFormat);

var functionDirectoriesList = new List<string>();
myConfig.Functions.ForEach(f =>
{
    var functionName = f.Route.Split('/')[^1];
    var functionDirExists = Directory.Exists($"../../Splunk/{functionName}");
    if (!functionDirExists)
    {
        functionDirectoriesList.Add(functionName);
        var createFunctionDirResult = Shell.Bash($"cd ../../Splunk; func new --name {functionName} --template \"HTTP trigger\" --authlevel \"anonymous\" --methods \"get\" --custom", true);
    }
});

var updateKeyVaultResult = Shell.Bash($"az keyvault secret set --vault-name \"{args[0]}\" --name \"RouteConfig\" --value='{myConfigJsonFormat}'");
Console.WriteLine(updateKeyVaultResult);

var buildMainResult = Shell.Bash($"cd ../../Splunk; env GOOS=linux GOARCH=amd64 go build ./main.go");
Console.WriteLine(buildMainResult);

var functionPublishResult = Shell.Bash($"cd ../../Splunk; func azure functionapp publish {args[1]} --custom");
Console.WriteLine(functionPublishResult);

functionDirectoriesList.ForEach(newFunctionDirectory =>
{
    Directory.Delete($"../../Splunk/{newFunctionDirectory}", true);
});