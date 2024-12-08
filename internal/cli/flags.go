package cli

import (
	"flag"
	"os"
)

type Config struct {
	ID          string
	EnvPath     string
	Verbose     bool
	InputFile   string
	OutputFile  string
	Emails      string
	IPs         string
	URLs        string
	Webpages    string
	Combine     bool
	ActiveRecon bool
	Timeout     int
	MaxDepth    int
	Command     string
}

func ParseFlags() *Config {
	cfg := &Config{}

	// Create a new FlagSet
	fs := flag.NewFlagSet("blobphish", flag.ExitOnError)

	// Define flags
	fs.StringVar(&cfg.ID, "id", "", "Analysis ID (default: YYMMDD_HM)")
	fs.StringVar(&cfg.EnvPath, "env", "./.env", "Path to .env file")
	fs.BoolVar(&cfg.Verbose, "verbose", false, "Enable verbose output")
	fs.StringVar(&cfg.InputFile, "input", "", "Input file path")
	fs.StringVar(&cfg.OutputFile, "output", "", "Output file path")
	fs.StringVar(&cfg.Emails, "emails", "", "Comma-separated email addresses")
	fs.StringVar(&cfg.IPs, "ips", "", "Comma-separated IP addresses")
	fs.StringVar(&cfg.URLs, "urls", "", "Comma-separated URLs")
	fs.StringVar(&cfg.Webpages, "webpages", "", "Comma-separated webpage URLs")
	fs.BoolVar(&cfg.Combine, "combine", false, "Combine multiple threats")
	fs.BoolVar(&cfg.ActiveRecon, "active_recon", false, "Use active reconnaissance")
	fs.IntVar(&cfg.Timeout, "timeout", 300, "Scan timeout in seconds")
	fs.IntVar(&cfg.MaxDepth, "max-depth", 3, "Maximum scan depth")

	// Parse command line arguments
	if len(os.Args) < 2 {
		return cfg
	}

	cfg.Command = os.Args[1]
	err := fs.Parse(os.Args[2:])
	if err != nil {
		fs.PrintDefaults()
		os.Exit(1)
	}

	return cfg
}
