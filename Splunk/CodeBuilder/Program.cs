using Newtonsoft.Json;
using BlamelessCodeBuilder;
using YamlDotNet.Serialization.NamingConventions;

var yamlDeserializer = new YamlDotNet.Serialization.DeserializerBuilder()
    .WithNamingConvention(CamelCaseNamingConvention.Instance)
    .Build();

var myConfig = yamlDeserializer.Deserialize<RouteConfig>(File.ReadAllText("route-config.yaml"));

var myConfigJsonFormat = JsonConvert.SerializeObject(myConfig);
myConfigJsonFormat = JsonConvert.ToString(myConfigJsonFormat);
myConfigJsonFormat = JsonConvert.ToString(myConfigJsonFormat);

var functionDirectoriesList = new List<string>();
myConfig.Functions.ForEach(f =>
{
    var functionName = f.Route.Split('/')[^1];
    var functionDirExists = Directory.Exists(functionName);
    if (!functionDirExists)
    {
        functionDirectoriesList.Add(functionName);
        var createFunctionDirResult = Shell.Bash($"func new --name {functionName} --template \"HTTP trigger\" --authlevel \"anonymous\" --methods \"get\"", true);
    }
});

var updateKeyVaultResult = Shell.Bash($"az keyvault secret set --vault-name \"{args[0]}\" --name \"RouteConfig\" --value \"{myConfigJsonFormat}\"");
Console.WriteLine(updateKeyVaultResult);

var buildMainResult = Shell.Bash($"go build ./main.go");
Console.WriteLine(buildMainResult);

var functionPublishResult = Shell.Bash($"func azure functionapp publish {args[1]} --custom");
Console.WriteLine(functionPublishResult);

functionDirectoriesList.ForEach(newFunctionDirectory =>
{
    Directory.Delete(newFunctionDirectory, true);
});