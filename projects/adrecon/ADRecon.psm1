function Get-ADReconUsers {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Domain
    )

    Write-Host "[*] Enumerating users in domain: $Domain"

    try {
        $users = Get-ADUser -Filter * -Server $Domain -Properties Name, SamAccountName, Enabled, LastLogonDate, Description
        Write-Host "[+] Found $($users.Count) users"

        # Export to CSV
        $users | Export-Csv -Path "adrecon_users.csv" -NoTypeInformation
        Write-Host "[+] Exported to adrecon_users.csv"

        return $users
    }
    catch {
        Write-Host "[-] Error: $_"
    }
}

function Get-ADReconPrivileged {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Domain
    )

    Write-Host "[*] Finding privileged accounts in: $Domain"

    try {
        # Find Domain Admins
        $domainAdmins = Get-ADGroupMember "Domain Admins" -Server $Domain -Recursive
        Write-Host "[+] Domain Admins: $($domainAdmins.Count)"

        # Find Enterprise Admins
        try {
            $enterpriseAdmins = Get-ADGroupMember "Enterprise Admins" -Server $Domain -Recursive
            Write-Host "[+] Enterprise Admins: $($enterpriseAdmins.Count)"
        }
        catch {
            Write-Host "[-] Could not query Enterprise Admins"
        }

        # Find local admins on domain controllers
        $domainControllers = Get-ADComputer -Filter {OperatingSystem -like "*Server*"} -Server $Domain
        Write-Host "[+] Domain Controllers: $($domainControllers.Count)"

        return @{
            DomainAdmins = $domainAdmins
            EnterpriseAdmins = $enterpriseAdmins
            DomainControllers = $domainControllers
        }
    }
    catch {
        Write-Host "[-] Error: $_"
    }
}

function Get-ADReconServiceAccounts {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Domain
    )

    Write-Host "[*] Finding service accounts with SPNs in: $Domain"

    try {
        $serviceAccounts = Get-ADUser -Filter {servicePrincipalName -ne "$null"} -Server $Domain -Properties servicePrincipalName, Name, SamAccountName
        Write-Host "[+] Found $($serviceAccounts.Count) service accounts"

        # Export for Kerberoasting
        $serviceAccounts | Select-Object SamAccountName, servicePrincipalName | Export-Csv -Path "adrecon_spns.csv" -NoTypeInformation
        Write-Host "[+] Exported SPNs to adrecon_spns.csv"

        return $serviceAccounts
    }
    catch {
        Write-Host "[-] Error: $_"
    }
}

# Export functions
Export-ModuleMember -Function Get-ADReconUsers, Get-ADReconPrivileged, Get-ADReconServiceAccounts