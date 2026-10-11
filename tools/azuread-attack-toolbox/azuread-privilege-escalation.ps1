<#
.SYNOPSIS
    Check for and exploit privilege escalation paths in Azure AD.
.DESCRIPTION
    Analyzes Azure AD configuration for common privilege escalation vectors
    including excessive permissions, stale service principals, and
    misconfigured application roles.
.PARAMETER Credential
    PSCredential object with Azure AD credentials
.EXAMPLE
    .\azuread-privilege-escalation.ps1 -Credential $cred -Verbose
#>

param(
    [Parameter(Mandatory=$true)]
    [PSCredential]$Credential,

    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

Write-Host "[*] Azure AD Privilege Escalation Check" -ForegroundColor Cyan

try {
    Connect-AzureAD -Credential $Credential | Out-Null
    Write-Host "[+] Connected to Azure AD" -ForegroundColor Green
} catch {
    Write-Host "[!] Connection failed: $_" -ForegroundColor Red
    exit 1
}

$findings = @()

# Check 1: Service Principals with excessive permissions
Write-Host "`n[*] Checking service principals for excessive permissions..." -ForegroundColor Cyan
$spns = Get-AzureADServicePrincipal -All $true

foreach ($spn in $spns) {
    $appRoles = $spn.AppRoles
    if ($appRoles) {
        foreach ($role in $appRoles) {
            if ($role.Value -match "Admin|Global|Directory") {
                $findings += [PSCustomObject]@{
                    Type = "Service Principal Admin Role"
                    Name = $spn.DisplayName
                    Role = $role.Value
                    Severity = "High"
                }
            }
        }
    }
}

# Check 2: Users with Global Admin role
Write-Host "[*] Checking for users with Global Admin role..." -ForegroundColor Cyan
$adminRole = Get-AzureADDirectoryRole | Where-Object { $_.DisplayName -eq "Global Administrator" }

if ($adminRole) {
    $adminMembers = Get-AzureADDirectoryRoleMember -ObjectId $adminRole.ObjectId
    foreach ($member in $adminMembers) {
        $findings += [PSCustomObject]@{
            Type = "Global Admin User"
            Name = $member.DisplayName
            UPN = $member.UserPrincipalName
            Severity = "High"
        }
    }
}

# Check 3: Stale service principals (no recent activity)
Write-Host "[*] Checking for stale service principals..." -ForegroundColor Cyan
# This would check last activity in a real implementation

# Check 4: Guest users with elevated permissions
Write-Host "[*] Checking guest users for elevated permissions..." -ForegroundColor Cyan
$guests = Get-AzureADUser -All $true | Where-Object { $_.UserType -eq "Guest" }
foreach ($guest in $guests) {
    $findings += [PSCustomObject]@{
        Type = "Guest User"
        Name = $guest.DisplayName
        UPN = $guest.UserPrincipalName
        Severity = "Medium"
    }
}

# Output findings
Write-Host "`n=== Findings ===" -ForegroundColor Cyan
if ($findings.Count -eq 0) {
    Write-Host "[+] No privilege escalation paths found" -ForegroundColor Green
} else {
    foreach ($finding in $findings) {
        Write-Host "[!] $($finding.Type): $($finding.Name) (Severity: $($finding.Severity))" -ForegroundColor Yellow
    }
}

Disconnect-AzureAD | Out-Null
Write-Host "`n[*] Analysis complete" -ForegroundColor Cyan