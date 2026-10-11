<#
.SYNOPSIS
    Enumerate Azure AD users, groups, and service principals.
.DESCRIPTION
    Connects to Azure AD and enumerates all users, groups, service principals,
    and application registrations for security assessment.
.PARAMETER Tenant
    Azure AD tenant domain (e.g., company.onmicrosoft.com)
.PARAMETER Credential
    PSCredential object with Azure AD admin credentials
.EXAMPLE
    .\azuread-enumerate.ps1 -Tenant "company.onmicrosoft.com" -Credential $cred
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Tenant,

    [Parameter(Mandatory=$true)]
    [PSCredential]$Credential
)

Write-Host "[*] Connecting to Azure AD tenant: $Tenant" -ForegroundColor Cyan

try {
    Connect-AzureAD -TenantId $Tenant -Credential $Credential | Out-Null
    Write-Host "[+] Connected successfully" -ForegroundColor Green
} catch {
    Write-Host "[!] Connection failed: $_" -ForegroundColor Red
    exit 1
}

# Enumerate Users
Write-Host "`n[*] Enumerating users..." -ForegroundColor Cyan
$users = Get-AzureADUser -All $true
Write-Host "[+] Found $($users.Count) users" -ForegroundColor Green

foreach ($user in $users) {
    Write-Host "  User: $($user.UserPrincipalName) | DisplayName: $($user.DisplayName) | Enabled: $($user.AccountEnabled)"
}

# Enumerate Groups
Write-Host "`n[*] Enumerating groups..." -ForegroundColor Cyan
$groups = Get-AzureADGroup -All $true
Write-Host "[+] Found $($groups.Count) groups" -ForegroundColor Green

foreach ($group in $groups) {
    Write-Host "  Group: $($group.DisplayName) | Type: $($group.SecurityEnabled)"
}

# Enumerate Service Principals
Write-Host "`n[*] Enumerating service principals..." -ForegroundColor Cyan
$spns = Get-AzureADServicePrincipal -All $true
Write-Host "[+] Found $($spns.Count) service principals" -ForegroundColor Green

foreach ($spn in $spns) {
    Write-Host "  SPN: $($spn.DisplayName) | AppId: $($spn.AppId)"
}

# Enumerate Applications
Write-Host "`n[*] Enumerating applications..." -ForegroundColor Cyan
$apps = Get-AzureADApplication -All $true
Write-Host "[+] Found $($apps.Count) applications" -ForegroundColor Green

foreach ($app in $apps) {
    Write-Host "  App: $($app.DisplayName) | AppId: $($app.AppId)"
}

Disconnect-AzureAD | Out-Null
Write-Host "`n[*] Enumeration complete" -ForegroundColor Cyan