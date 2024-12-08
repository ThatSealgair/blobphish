Blobphish - Advanced Phishing Analysis and Reconnaissance Tool - Version: 0.0.1

Usage:
  blobphish [command] [options]

Commands:
  analyse                     Analyse specified inputs (Emails, IPs, URLs, Webpages)
  recon                       Perform reconnaissance (passive or active) on targets
  uno <id> <path>             Perform active vulnerability analysis on identified threat actors
  config                      Manage configuration settings (default scans, wordlists, whitelists)
  report <id>                 Generate analysis reports
  help                        Show this help message or detailed help for a command
  update_id <idOld> <idNew>   Give new ID to save files of previous analysis.

Blobphish:
  --id <string>               The ID for the analysis being performed (default: YYMMDD_HM)
  --env <path>                Specify path to .env file for API keys (default: ./.env)
  --verbose                   Enable verbose output

Analysis:
  --input <file>              Input file containing targets (supports .json, .yml, .toml)
  --output <file>             Save results to file (default: ID_PHASE_USER.json)
  --emails <email1,email2>    Emails for analysis (comma-separated)
  --ips <ip1,ip2>             IP addresses for analysis (comma-separated)
  --urls <url1,url2>          URLs for analysis (comma-separated)
  --webpages <url1,url2>      Webpages for analysis (comma-separated)
  --combine                   Combine multiple threats for holistic analysis

Scan:
  --active_recon              Use active reconnaissance methods
  --uno                       Perform active vulnerability analysis
  --timeout <value>           Scan timeout in seconds (default: 300)
  --max-depth <value>         Maximum scan depth (default: 3)

---

**ANALYSIS MODES**
Blobphish supports advanced analysis for Emails, IPs, URLs, and Webpages:
  Emails:
    - Content-based analysis
    - Heuristic analysis
    - Contextual analysis
  IPs:
    - Content-based analysis
    - Heuristic analysis
    - Contextual analysis
  URLs:
    - Lexical features
    - Domain reputation
    - Keyword analysis
    - Anomalous patterns
    - Contextual analysis
  Webpages:
    - HTML and JavaScript inspection
    - Visual similarity
    - Heuristic analysis
    - Contextual analysis

Use `--combine` to extend phishing attack analysis by linking threats together against specific groups.

---

**RECONNAISSANCE MODES**
Reconnaissance occurs in two phases:
  Phase 1: Information Gathering
    --passive_recon (default)
      - WHOIS Lookup
      - DNS Analysis
      - Reverse IP Lookup
      - Geolocation
      - OSINT data collection
    --active_recon
      - Port scanning
      - Packet tracing
      - Infrastructure enumeration
      - Banner grabbing

    Results are stored under "passive_recon" or "active_recon" in the output file.

  Phase 2: Threat Analysis
    - Correlates Phase 1 data with known threat intelligence databases
    - Identifies malware or campaign indicators
    - Employs threat attribution techniques such as IP history and domain relationship analysis

---

**VULNERABILITY ANALYSIS (UNO)**
  --uno
    - Perform active vulnerability analysis on threat actors
    - Webserver scanning
    - SSL/TLS scanning
    - Exploitation of common vulnerabilities
    Results are stored under "uno" in the output file.

---

**CONFIGURATION**
Configuration options include:
  - Default scans, wordlists, and whitelists
  - API key management (MISP, Shodan, Request Tracker integrations)
    - API keys are securely stored in a .env file. Use `--env` to specify an alternative location.

---

Examples:
  1. Analyse a set of emails, URLs, and IPs from a file:
     blobphish analyse --input targets.json --output results.json

  2. Perform passive and active reconnaissance on a URL:
     blobphish recon --urls example.com --active_recon --output recon.json

  3. Run a combined analysis of emails and webpages:
     blobphish analyse --emails "phish@example.com" --webpages "http://example.com" --combine --output combined.json

  4. Perform UNO vulnerability analysis on an IP address:
     blobphish uno --ips 192.168.1.1 --output vulnerabilities.json

For more information, visit: [documentation URL]
