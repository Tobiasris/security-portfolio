# Active Directory ACL Abuse: From Helpdesk to Domain Admin

**Date:** September 2024  
**Environment:** Corporate Active Directory (Windows Server 2019)  
**Technique:** ACL enumeration and exploitation via BloodHound, SharpHound, and manual LDAP manipulation

## Scenario

During a red team engagement for a mid-sized financial services firm, we were tasked with assessing the attack surface of their Active Directory environment. The goal was to demonstrate how a low-privileged helpdesk account could escalate to Domain Admin through ACL misconfigurations.

## Initial Reconnaissance

After gaining initial foothold on a helpdesk workstation, we collected AD data using SharpHound:

```bash
SharpHound.exe -c All -o bloodhound_output.zip
```

Importing the data into BloodHound revealed several interesting paths. The most promising was a chain involving `GenericAll` permissions on a service account.

## The Attack Chain

### Step 1: Identifying the Misconfiguration

BloodHound showed that the `Helpdesk` group had `GenericAll` permissions on the `svc_backup` computer account. This is a classic misconfiguration — service accounts often have excessive permissions granted for "convenience."

### Step 2: Taking Over the Computer Account

Using the `GenericAll` permission, we modified the `msDS-AllowedToActOnBehalfOfOtherIdentity` attribute of `svc_backup` to include our helpdesk user:

```powershell
# Using PowerView to set the ACL
Set-DomainObjectAcl -TargetIdentity "svc_backup$" -PrincipalIdentity "helpdesk_user" -Rights All
```

### Step 3: Resource-Based Constrained Delegation (RBCD)

With the ACL set, we could now impersonate any user to `svc_backup`. We targeted the Domain Admin account:

```bash
# Get TGT for the computer account
kinit -k -t /etc/krb5.keytab svc_backup$@CORP.LOCAL

# Impersonate Domain Admin to the computer
kinit -S cifs/svc_backup.corp.local@CORP.LOCAL -U helpdesk_user
```

### Step 4: Moving Laterally

Using the impersonated session, we accessed `svc_backup`'s administrative shares and found credentials stored in a backup script. These credentials belonged to a Domain Admin account.

## Technical Details

### Why This Works

Active Directory ACLs are complex and often misunderstood. The `GenericAll` permission grants:
- Read all properties
- Write all properties
- Delete the object
- Take ownership
- Read/write ACLs

This is essentially full control. When applied to a computer account, it allows an attacker to:
1. Change the computer's password
2. Modify delegation settings
3. Add the attacker to privileged groups

### Common Misconfigurations

During our assessment, we found these recurring issues:

| Permission | Target | Risk |
|------------|--------|------|
| GenericAll | Computer accounts | RBCD attacks |
| WriteDACL | Groups | Add self to group |
| GenericWrite | User objects | Password reset |
| WriteOwner | Any object | Take ownership |

## Detection and Mitigation

### Detection

Monitor for unusual ACL changes using Windows Event Log:
- Event ID 4662 (Object accessed) with `msDS-AllowedToActOnBehalfOfOtherIdentity`
- Event ID 5136 (Directory object modified) on computer accounts
- BloodHound periodic scans to identify new attack paths

### Mitigation

1. **Least Privilege:** Audit and remove unnecessary ACLs
2. **Regular Scans:** Use BloodHound monthly to detect new misconfigurations
3. **Monitor ACL Changes:** Alert on modifications to security descriptors
4. **Use Protected Groups:** Add critical groups to the Protected Users group

## Lessons Learned

This engagement demonstrated how quickly a low-privileged user can reach Domain Admin through ACL misconfigurations. The key takeaways:

- ACLs are often granted for convenience and forgotten
- Computer accounts are frequently overlooked in security reviews
- RBCD attacks are powerful but under-detectable
- Regular BloodHound scans are essential for maintaining AD security

## Tools Used

- [SharpHound](https://github.com/BloodHoundAD/SharpHound) - AD data collection
- [BloodHound](https://github.com/BloodHoundAD/BloodHound) - Attack path analysis
- [PowerView](https://github.com/PowerShellMafia/PowerSploit) - AD enumeration
- [Impacket](https://github.com/SecureAuthCorp/impacket) - Kerberos attacks