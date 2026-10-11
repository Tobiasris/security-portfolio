# ADRecon - Active Directory Reconnaissance Framework

A PowerShell-based Active Directory reconnaissance tool for security assessments and red team operations.

## Features

- User and group enumeration
- Privileged account identification
- Trust relationship mapping
- Service account discovery
- Password policy analysis

## Installation

```powershell
# Clone repository
git clone https://github.com/securityresearcher/adrecon.git

# Import module
Import-Module .\ADRecon.psm1
```

## Usage

### Basic Enumeration

```powershell
# Enumerate all users
Get-ADReconUsers -Domain "corp.local"

# Find privileged users
Get-ADReconPrivileged -Domain "corp.local"
```

### Trust Mapping

```powershell
# Map trust relationships
Get-ADReconTrusts -Domain "corp.local" -Verbose
```

### Service Account Discovery

```powershell
# Find service accounts with SPNs
Get-ADReconServiceAccounts -Domain "corp.local"
```

## Output

Results are exported to JSON and CSV formats for further analysis.

## Requirements

- PowerShell 5.1+
- Active Directory module
- Domain user credentials

## License

MIT