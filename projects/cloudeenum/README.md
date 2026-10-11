# CloudEnum - Cloud Environment Enumerator

A comprehensive enumeration tool for identifying and mapping cloud infrastructure across AWS, Azure, and GCP.

## Features

- Multi-cloud support (AWS, Azure, GCP)
- Service discovery and mapping
- IAM/Role enumeration
- Security group and network configuration analysis
- Asset inventory generation
- Output formats: JSON, CSV, HTML report

## Installation

```bash
git clone https://github.com/Tobiasris/cloudeenum.git
cd cloudeenum
pip install -r requirements.txt
```

## Usage

### AWS Enumeration
```bash
python3 cloudeenum.py --cloud aws --profile myprofile --output aws_inventory.json
```

### Azure Enumeration
```bash
python3 cloudeenum.py --cloud azure --subscription-id SUB_ID --output azure_inventory.json
```

### GCP Enumeration
```bash
python3 cloudeenum.py --cloud gcp --project-id PROJECT_ID --output gcp_inventory.json
```

### Full Multi-Cloud
```bash
python3 cloudeenum.py --all-clouds --output full_inventory.json --report
```

## Modules

- `discover.py` - Service discovery across cloud providers
- `iam_enum.py` - IAM roles, users, and policy enumeration
- `network.py` - Security groups, subnets, and network ACLs
- `assets.py` - Instance and storage asset inventory
- `report.py` - HTML and JSON report generation

## License

MIT License