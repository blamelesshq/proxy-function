namespace ProxyFunctionRouteUpdater
{
    public class ApiSpec
    {
        public string Openapi { get; set; } = default!;
        public Info Info { get; set; } = default!;
        public List<Server> Servers { get; set; } = default!;
        public Dictionary<string, Fetch> Paths { get; set; } = default!;
        public Components Components { get; set; } = default!;
        public List<Security> Security { get; set; } = default!;
    }

    public class Components
    {
        public SecuritySchemes SecuritySchemes { get; set; } = default!;
    }

    public partial class SecuritySchemes
    {
        public ApiKey ApiKeyHeader { get; set; } = default!;
        public ApiKey ApiKeyQuery { get; set; } = default!;
    }

    public class ApiKey
    {
        public string Type { get; set; } = default!;
        public string Name { get; set; } = default!;
        public string In { get; set; } = default!;
    }

    public class Info
    {
        public string Title { get; set; } = default!;
        public string Description { get; set; } = default!;
        public string Version { get; set; } = default!;
    }

    public class Fetch
    {
        public Get Get { get; set; } = default!;
    }

    public class Get
    {
        public string Summary { get; set; } = default!;
        public string OperationId { get; set; } = default!;
        public Dictionary<string, DescriptionObj> Responses { get; set; } = default!;
    }

    public class DescriptionObj
    {
        public string Description { get; set; } = default!;
    }

    public class Security
    {
        public object[] ApiKeyHeader { get; set; } = default!;
        public object[] ApiKeyQuery { get; set; } = default!;
    }

    public class Server
    {
        public string Url { get; set; } = default!;
    }
}
