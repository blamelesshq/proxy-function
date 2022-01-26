using System.Diagnostics;
using System.Runtime.InteropServices;

namespace ProxyFunctionRouteUpdater
{
    public class Function
    {
        public string Route { get; set; } = default!;
        public string Url { get; set; } = default!;
        public string AccessToken { get; set; } = default!;
        public string Type { get; set; } = default!;
        public string Login { get; set; } = default!;
        public string Password { get; set; } = default!;
    }

    public class RouteConfig
    {
        public List<Function> Functions { get; set; } = default!;
    }

    public static class Shell
    {
        public static string Bash(this string cmd, bool isEscaped = false)
        {
            var escapedArgs = isEscaped ? cmd.Replace("\"", "\\\"") : cmd;
            string? fileName;
            if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
            {
                fileName = "/bin/sh";
            }
            else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
            {
                fileName = "/bin/sh";
            }
            else
            {
                fileName = @"C:\Program Files\Git\bin\sh";
            }

            var process = new Process()
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = fileName,
                    Arguments = $"-c \"{escapedArgs}\"",
                    RedirectStandardOutput = true,
                    UseShellExecute = false,
                    CreateNoWindow = true,
                }
            };

            process.Start();
            string result = process.StandardOutput.ReadToEnd();
            process.WaitForExit();

            return result;
        }
    }
}
