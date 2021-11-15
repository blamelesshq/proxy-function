using ProxyFunctionRouteUpdater;
using YamlDotNet.Serialization.NamingConventions;

var yamlDeserializer = new YamlDotNet.Serialization.DeserializerBuilder()
    .WithNamingConvention(CamelCaseNamingConvention.Instance)
    .Build();

var myConfig = yamlDeserializer.Deserialize<RouteConfig>(File.ReadAllText("route-config.yaml"));


try
{
    var myConfigJsonFormat = System.Text.Json.JsonSerializer.Serialize(myConfig);

    Console.WriteLine("Before escape: " + myConfigJsonFormat);
    

    myConfigJsonFormat = $"\"{myConfigJsonFormat.Replace("\"", "\\\"")}\"";
    Console.WriteLine("After escape 1: " + myConfigJsonFormat);
    myConfigJsonFormat = myConfigJsonFormat.Replace("\"", "\\\\\"");
    myConfigJsonFormat = $"\"{myConfigJsonFormat.Substring(1, myConfigJsonFormat.Length - 3)}\"{myConfigJsonFormat[myConfigJsonFormat.Length - 1]}";
    Console.WriteLine("After escape 2: " + myConfigJsonFormat);


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

    Console.WriteLine("Before key vault");
    Console.WriteLine("Args: " + args.Length);
    var updateKeyVaultResult = Shell.Bash($"az keyvault secret set --vault-name \"{args[0]}\" --name \"RouteConfig\" --value \"{myConfigJsonFormat}\"");
    Console.WriteLine("After key vault");
    Console.WriteLine(updateKeyVaultResult);

    var buildMainResult = Shell.Bash($"go build ./main.go");
    Console.WriteLine(buildMainResult);

    var functionPublishResult = Shell.Bash($"func azure functionapp publish {args[1]} --custom");
    Console.WriteLine(functionPublishResult);

    functionDirectoriesList.ForEach(newFunctionDirectory =>
    {
        Directory.Delete(newFunctionDirectory, true);
    });
}
catch (Exception e)
{
    Console.WriteLine(e.Message);
    Console.WriteLine(e.StackTrace);
}
