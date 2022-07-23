using System;
using System.Diagnostics;
using System.Text.RegularExpressions;

namespace SubSystemWin
{
    internal class Program
    {
        static void Main(string[] args)
        {
            string nl = Environment.NewLine;
            if (args.Length == 0)
            {
                System.Windows.Forms.MessageBox.Show($@"SubSystemWin invoked but no parameters provided.{nl}Canceling execution.", "SubSystemWin.exe", System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Question);
                return;
            }
            else
            {
                if (!System.IO.File.Exists(args[0]))
                {
                    System.Windows.Forms.MessageBox.Show($@"SubSystemWin invoked but the executable not exists.{nl}{args[0]}{nl}Canceling execution.", "SubSystemWin.exe", System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Question);
                    return;
                }
                else
                {
                    if (!args[0].EndsWith(".exe", StringComparison.InvariantCultureIgnoreCase))
                    {
                        System.Windows.Forms.MessageBox.Show($@"SubSystemWin invoked but the first parameter is no executable.{nl}{args[0]}{nl}Canceling execution.", "SubSystemWin.exe", System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Question);
                    }
                    else
                    {
                        string ExtractArguments = RegExRemoveFromStart(Environment.CommandLine, System.Reflection.Assembly.GetEntryAssembly().Location, @"""");
                        ExtractArguments = RegExRemoveFromStart(ExtractArguments, args[0], @"");
                        ExtractArguments = RegExRemoveFromStart(ExtractArguments, args[0], @"""");
                        ExtractArguments = RegExRemoveFromStart(ExtractArguments, args[0], @"'");

                        ProcessStartInfo nfo = new()
                        {
                            FileName = args[0],
                            Arguments = ExtractArguments,
                            UseShellExecute = false,
                            CreateNoWindow = true
                        };
                        Process process = new()
                        {
                            StartInfo = nfo
                        };
                        process.Start();
                        process.WaitForExit();
                    }
                    
                }
            }
        }

        static string RegExRemoveFromStart(string input,string pattern,string quotes)
        {
            string RegExPattern = "^"+Regex.Escape(quotes + pattern + quotes);
            string result = Regex.Replace(input, "^" + RegExPattern, "").Trim();
            return result;
        }
    }
}