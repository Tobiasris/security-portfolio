# AzureAD Attack Toolbox

A collection of PowerShell scripts and tools for attacking and testing Azure Active Directory security.

## Tools

### azurad-enumerate.ps1
Enumerate Azure AD users, groups, and service principals.

```powershell
.\azuread-enumerate.ps1 -Tenant "company.onmicrosoft.com" -Credential $cred
```

### azuread-token-abuse.ps1
Exploit Azure AD token misconfigurations and stale tokens.

```powershell
.\azuread-token-abuse.ps1 -AccessToken $token -TargetUser "admin@company.com"
```

### azuread-pwdspray.ps1
Password spraying attack against Azure AD with lockout detection.

```powershell
.\azuread-pwdspray.ps1 -UsernameList users.txt -Password "Winter2024!" -Throttle 3
```

### azuread-privilege-escalation.ps1
Check for and exploit privilege escalation paths in Azure AD.

```powershell
.\azuread-privilege-escalation.ps1 -Credential $cred -Verbose
```

### azuread-guest-enum.ps1
Enumerate guest users and identify potential attack paths.

```powershell
.\azuread-guest-enum.ps1 -Tenant "company.onmicrosoft.com" -Credential $cred
```

## Requirements

- PowerShell 5.1+
- AzureAD or Microsoft.Graph PowerShell modules
- Active Directory module (for hybrid scenarios)

## Installation

```powershell
Install-Module AzureAD -Scope CurrentUser
Install-Module Microsoft.Graph -Scope CurrentUser
```

## License

MIT License