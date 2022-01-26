#Prerequisites:
- .NET 6 Runtime installed (go to this [link](https://dotnet.microsoft.com/download/dotnet/6.0) to download if don't have it)

#Commands:
**(Linux)** ```dotnet publish --framework net6.0 --runtime linux-x64 --self-contained true --configuration Release```
Default Publish directory: ```bin\Release\net6.0\linux-x64\publish\BlamelessCodeBuilder``` (Need to be putted in ./Splunk folder)

**(OSX)** ```dotnet publish --framework net6.0 --runtime osx-x64 --self-contained true --configuration Release```
Default Publish directory: ```bin\Release\net6.0\osx-x64\publish\BlamelessCodeBuilder``` (Need to be putted in ./Splunk folder)

**(Windows)** ```dotnet publish --framework net6.0 --runtime win-x64 --self-contained true --configuration Release```
Default Publish directory: ```bin\Release\net6.0\win-x64\publish\BlamelessCodeBuilder``` (Need to be putted in ./Splunk folder)



#Description (functionality):
- Entry file: Program.cs
- Processes route-config.yaml file. Convert the file in escaped json format and pushes that to keyvault.
- Creates additonal functions specified in route-config.yaml file
- Publish the function app with all functions to azure.