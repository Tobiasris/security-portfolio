# PhishKit - Modern Phishing Infrastructure

A complete phishing campaign toolkit for red team operations. Supports credential harvesting, payload delivery, and campaign analytics.

## Features

- Multi-target campaign management
- Credential harvesting with real-time collection
- Payload delivery (DLL sideloading, Office macros, HTA)
- Campaign analytics and dashboard
- Template system for professional-looking pages
- SSL/TLS support with automated certificate generation
- Domain rotation and failover
- Integration with C2 frameworks

## Architecture

```
phishkit/
├── server/           # Flask web server for landing pages
├── templates/        # HTML templates for phishing pages
├── payloads/         # Payload generation and staging
├── analytics/        # Campaign tracking and reporting
├── ssl/              # SSL certificate management
└── phishkit.py       # Main entry point
```

## Installation

```bash
git clone https://github.com/Tobiasris/phishkit.git
cd phishkit
pip install -r requirements.txt
```

## Quick Start

### Create a Campaign
```bash
python3 phishkit.py create-campaign --name "Q4-Finance" --target finance.company.com
```

### Add Targets
```bash
python3 phishkit.py add-targets --campaign "Q4-Finance" --file targets.csv
```

### Generate Payloads
```bash
python3 phishkit.py generate-payload --campaign "Q4-Finance" --type dll-sideloading
```

### Start Campaign
```bash
python3 phishkit.py start --campaign "Q4-Finance" --port 443
```

### View Analytics
```bash
python3 phishkit.py analytics --campaign "Q4-Finance"
```

## Payload Types

- **DLL Sideloading** - Legitimate executable with malicious DLL
- **Office Macros** - Excel/Word documents with embedded macros
- **HTA Files** - HTML Application files
- **LNK Files** - Malicious shortcuts
- **ZIP Archives** - Self-extracting archives

## License

MIT License