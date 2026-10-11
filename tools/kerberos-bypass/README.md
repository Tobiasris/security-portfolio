# Kerberos Bypass Collection

Collection of scripts and tools for Kerberos-based attacks and bypasses.

## Tools

- `kerberos-attacks.sh` - Main attack toolkit
- `extract-tickets.py` - Ticket extraction utility
- `analyze-kdc.py` - KDC configuration analyzer

## Usage

```bash
# Enumerate targets
./kerberos-attacks.sh enum -d domain.com -u user -p password

# Request tickets
./kerberos-attacks.sh ticket -d domain.com -u user -p password

# Crack tickets
./kerberos-attacks.sh crack tickets.kirbi
```

## Requirements

- Python 3
- Impacket
- Hashcat
- Rubeus (for Windows)