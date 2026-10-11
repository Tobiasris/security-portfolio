# Cloud Misconfigurations in AI Infrastructure: A Red Team Perspective

**Date:** January 2025  
**Environment:** AWS/GCP infrastructure hosting ML models and training pipelines  
**Techniques:** IAM abuse, data exfiltration, model poisoning

## Overview

As organizations adopt AI/ML workloads in the cloud, the attack surface expands significantly. This write-up explores common misconfigurations in AI infrastructure and how red teams can exploit them.

## Misconfiguration 1: Overly Permissive IAM Roles

AI workloads often require broad permissions for data access, leading to overly permissive IAM roles:

```json
{
    "Effect": "Allow",
    "Action": [
        "s3:*",
        "ec2:*",
        "rds:*",
        "secretsmanager:*"
    ],
    "Resource": "*"
}
```

**Exploitation:**
```bash
# Assume role and enumerate resources
aws sts assume-role --role-arn arn:aws:iam::123456789:role/AIWorkloadRole \
    --role-session-name "redteam"

# Access sensitive data
aws s3 ls s3://ml-training-data/
aws secretsmanager list-secrets
```

## Misconfiguration 2: Exposed Jupyter Notebooks

Jupyter notebooks are often exposed without authentication for developer convenience:

```bash
# Find exposed Jupyter instances
nmap -p 8888 --script http-title -T4 10.0.0.0/16

# Access without authentication
curl http://10.0.1.5:8888/api/kernels
```

## Misconfiguration 3: Public S3 Buckets for Model Artifacts

Model artifacts and training data stored in public S3 buckets:

```bash
# Enumerate S3 buckets
aws s3api list-buckets

# Check bucket policies
aws s3api get-bucket-policy --bucket ml-models-prod

# Download model artifacts
aws s3 cp s3://ml-models-prod/latest-model.pkl ./
```

## Misconfiguration 4: Insecure Model Serving Endpoints

ML model serving endpoints without proper authentication or rate limiting:

```python
# Exploit model endpoint for inference
import requests

response = requests.post("http://api.example.com/predict", json={
    "input": "test data"
})

# Fuzz endpoint for information disclosure
for payload in payloads:
    response = requests.post("http://api.example.com/predict", json=payload)
    analyze_response(response)
```

## Red Team Attack Path

1. **Reconnaissance:** Identify cloud provider and exposed services
2. **Initial Access:** Exploit misconfigured IAM or exposed endpoints
3. **Data Collection:** Access training data, model artifacts, secrets
4. **Model Manipulation:** Poison training data or modify model weights
5. **Persistence:** Create backdoor IAM roles or API keys

## Detection & Mitigation

1. **Least privilege IAM:** Use resource-specific policies
2. **Network segmentation:** Restrict access to internal services
3. **Authentication:** Require auth for all endpoints
4. **Monitoring:** Track unusual data access patterns
5. **Regular audits:** Use tools like Prowler, ScoutSuite for compliance checks

## Tools Used

- [Prowler](https://github.com/prowler-cloud/prowler) - AWS security audit
- [ScoutSuite](https://github.com/nccgroup/ScoutSuite) - Cloud security audit
- [Cloudsplaining](https://github.com/salesforce/cloudsplaining) - IAM analysis
- [AWS CLI](https://aws.amazon.com/cli/)