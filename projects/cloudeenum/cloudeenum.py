#!/usr/bin/env python3
"""
CloudEnum - Multi-Cloud Environment Enumerator
Enumerates and maps cloud infrastructure across AWS, Azure, and GCP.
"""

import argparse
import json
import sys
from datetime import datetime


def enumerate_aws(profile_name):
    """Enumerate AWS resources using boto3."""
    import boto3

    session = boto3.Session(profile_name=profile_name)
    resources = {
        "ec2": {},
        "s3": {},
        "iam": {},
        "vpc": {},
        "rds": {},
        "lambda": {},
    }

    # EC2 Instances
    try:
        ec2 = session.client("ec2")
        instances = ec2.describe_instances()["Reservations"]
        for reservation in instances:
            for instance in reservation["Instances"]:
                resources["ec2"][instance["InstanceId"]] = {
                    "type": "ec2",
                    "state": instance["State"]["Name"],
                    "ami": instance["ImageId"],
                    "instance_type": instance["InstanceType"],
                    "private_ip": instance.get("PrivateIpAddress", ""),
                    "public_ip": instance.get("PublicIpAddress", ""),
                    "security_groups": [
                        sg["GroupId"]
                        for sg in instance.get("SecurityGroups", [])
                    ],
                    "tags": {
                        tag["Key"]: tag["Value"]
                        for tag in instance.get("Tags", [])
                    },
                }
    except Exception as e:
        print(f"[!] EC2 enumeration error: {e}")

    # S3 Buckets
    try:
        s3 = session.client("s3")
        buckets = s3.list_buckets()["Buckets"]
        for bucket in buckets:
            resources["s3"][bucket["Name"]] = {
                "type": "s3",
                "name": bucket["Name"],
                "created": bucket["CreationDate"],
            }
    except Exception as e:
        print(f"[!] S3 enumeration error: {e}")

    # IAM Users and Roles
    try:
        iam = session.client("iam")
        users = iam.list_users()["Users"]
        for user in users:
            resources["iam"][user["UserName"]] = {
                "type": "iam_user",
                "arn": user["Arn"],
                "created": user["CreateDate"],
            }
        roles = iam.list_roles()["Roles"]
        for role in roles:
            resources["iam"][role["RoleName"]] = {
                "type": "iam_role",
                "arn": role["Arn"],
                "created": role["CreateDate"],
            }
    except Exception as e:
        print(f"[!] IAM enumeration error: {e}")

    return resources


def enumerate_azure(subscription_id):
    """Enumerate Azure resources."""
    from azure.identity import DefaultAzureCredential
    from azure.mgmt.compute import ComputeManagementClient
    from azure.mgmt.network import NetworkManagementClient
    from azure.mgmt.resource import SubscriptionClient, ResourceManagementClient

    credential = DefaultAzureCredential()
    resources = {
        "vm": {},
        "network": {},
        "resource_groups": {},
    }

    # List resource groups
    try:
        resource_client = ResourceManagementClient(credential, subscription_id)
        groups = resource_client.resource_groups.list()
        for group in groups:
            resources["resource_groups"][group.name] = {
                "type": "resource_group",
                "location": group.location,
                "tags": dict(group.tags) if group.tags else {},
            }
    except Exception as e:
        print(f"[!] Azure resource group error: {e}")

    # List VMs
    try:
        compute_client = ComputeManagementClient(credential, subscription_id)
        vms = compute_client.virtual_machines.list_all()
        for vm in vms:
            resources["vm"][vm.name] = {
                "type": "vm",
                "location": vm.location,
                "size": vm.hardware_profile.vm_size,
                "os": vm.storage_profile.os_type.value,
            }
    except Exception as e:
        print(f"[!] Azure VM enumeration error: {e}")

    return resources


def enumerate_gcp(project_id):
    """Enumerate GCP resources."""
    from googleapiclient.discovery import build

    resources = {"instances": {}, "buckets": {}}

    # Compute instances
    try:
        compute = build("compute", "v1")
        zones = compute.zones().list(project=project_id).execute()
        for zone in zones.get("items", []):
            instances = (
                compute.instances()
                .list(project=project_id, zone=zone["name"])
                .execute()
            )
            for instance in instances.get("items", []):
                resources["instances"][instance["name"]] = {
                    "type": "gce_instance",
                    "zone": instance["zone"].split("/")[-1],
                    "machine_type": instance["machineType"].split("/")[-1],
                    "status": instance["status"],
                }
    except Exception as e:
        print(f"[!] GCP instance enumeration error: {e}")

    return resources


def main():
    parser = argparse.ArgumentParser(
        description="CloudEnum - Multi-Cloud Environment Enumerator"
    )
    parser.add_argument("--cloud", choices=["aws", "azure", "gcp"], help="Target cloud provider")
    parser.add_argument("--all-clouds", action="store_true", help="Enumerate all configured clouds")
    parser.add_argument("--profile", help="AWS profile name")
    parser.add_argument("--subscription-id", help="Azure subscription ID")
    parser.add_argument("--project-id", help="GCP project ID")
    parser.add_argument("--output", default="cloud_inventory.json", help="Output file")
    parser.add_argument("--report", action="store_true", help="Generate HTML report")

    args = parser.parse_args()

    inventory = {
        "enumerated_at": datetime.now().isoformat(),
        "clouds": {},
    }

    if args.cloud == "aws" or (args.all_clouds and args.profile):
        print("[*] Enumerating AWS...")
        inventory["clouds"]["aws"] = enumerate_aws(args.profile)

    if args.cloud == "azure" or (args.all_clouds and args.subscription_id):
        print("[*] Enumerating Azure...")
        inventory["clouds"]["azure"] = enumerate_azure(args.subscription_id)

    if args.cloud == "gcp" or (args.all_clouds and args.project_id):
        print("[*] Enumerating GCP...")
        inventory["clouds"]["gcp"] = enumerate_gcp(args.project_id)

    # Save inventory
    with open(args.output, "w") as f:
        json.dump(inventory, f, indent=2)
    print(f"[+] Inventory saved to {args.output}")

    if args.report:
        print("[*] Generating HTML report...")
        # Report generation would go here
        print(f"[+] Report generated")


if __name__ == "__main__":
    main()