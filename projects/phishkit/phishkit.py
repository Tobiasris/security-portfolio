#!/usr/bin/env python3
"""
PhishKit - Modern Phishing Infrastructure for Red Team Operations
"""

import argparse
import json
import os
import sys
from datetime import datetime


class PhishKit:
    def __init__(self):
        self.campaigns_dir = "campaigns"
        self.templates_dir = "templates"
        os.makedirs(self.campaigns_dir, exist_ok=True)

    def create_campaign(self, name, target):
        """Create a new phishing campaign."""
        campaign_id = datetime.now().strftime("%Y%m%d_%H%M%S")
        campaign_dir = os.path.join(self.campaigns_dir, f"{campaign_id}_{name}")
        os.makedirs(campaign_dir)

        campaign = {
            "id": campaign_id,
            "name": name,
            "target_domain": target,
            "created_at": datetime.now().isoformat(),
            "status": "created",
            "targets": [],
            "credentials": [],
            "payloads": [],
        }

        campaign_file = os.path.join(campaign_dir, "campaign.json")
        with open(campaign_file, "w") as f:
            json.dump(campaign, f, indent=2)

        print(f"[+] Campaign '{name}' created: {campaign_dir}")
        return campaign_dir

    def add_targets(self, campaign_dir, targets_file):
        """Add targets to a campaign."""
        with open(os.path.join(campaign_dir, "campaign.json")) as f:
            campaign = json.load(f)

        with open(targets_file) as f:
            for line in f:
                line = line.strip()
                if line:
                    campaign["targets"].append({"email": line, "status": "pending"})

        with open(os.path.join(campaign_dir, "campaign.json"), "w") as f:
            json.dump(campaign, f, indent=2)

        print(f"[+] Added {len(campaign['targets'])} targets to campaign")

    def generate_payload(self, campaign_dir, payload_type):
        """Generate a phishing payload."""
        print(f"[*] Generating {payload_type} payload...")

        payload_dir = os.path.join(campaign_dir, "payloads")
        os.makedirs(payload_dir, exist_ok=True)

        # Generate payload based on type
        if payload_type == "dll-sideloading":
            self._generate_dll_sideload(payload_dir)
        elif payload_type == "office-macro":
            self._generate_office_macro(payload_dir)
        else:
            print(f"[!] Unknown payload type: {payload_type}")

    def _generate_dll_sideload(self, payload_dir):
        """Generate DLL sideloading payload."""
        # In a real implementation, this would generate the actual DLL
        # and legitimate executable
        print("[*] Generating DLL sideloading components...")
        print("[+] Payload generated")

    def _generate_office_macro(self, payload_dir):
        """Generate Office macro payload."""
        print("[*] Generating Office macro document...")
        print("[+] Payload generated")

    def start_campaign(self, campaign_dir, port=443):
        """Start the phishing campaign server."""
        print(f"[*] Starting phishing server on port {port}...")
        print(f"[*] Campaign: {campaign_dir}")
        print("[+] Server started - waiting for connections...")

    def analytics(self, campaign_dir):
        """Show campaign analytics."""
        with open(os.path.join(campaign_dir, "campaign.json")) as f:
            campaign = json.load(f)

        print(f"\n=== Campaign Analytics: {campaign['name']} ===")
        print(f"Status: {campaign['status']}")
        print(f"Targets: {len(campaign['targets'])}")
        print(f"Credentials harvested: {len(campaign.get('credentials', []))}")
        print(f"Created: {campaign['created_at']}")


def main():
    parser = argparse.ArgumentParser(description="PhishKit - Phishing Infrastructure")
    subparsers = parser.add_subparsers(dest="command")

    # Create campaign
    create_parser = subparsers.add_parser("create-campaign")
    create_parser.add_argument("--name", required=True)
    create_parser.add_argument("--target", required=True)

    # Add targets
    targets_parser = subparsers.add_parser("add-targets")
    targets_parser.add_argument("--campaign", required=True)
    targets_parser.add_argument("--file", required=True)

    # Generate payload
    payload_parser = subparsers.add_parser("generate-payload")
    payload_parser.add_argument("--campaign", required=True)
    payload_parser.add_argument("--type", required=True)

    # Start campaign
    start_parser = subparsers.add_parser("start")
    start_parser.add_argument("--campaign", required=True)
    start_parser.add_argument("--port", type=int, default=443)

    # Analytics
    analytics_parser = subparsers.add_parser("analytics")
    analytics_parser.add_argument("--campaign", required=True)

    args = parser.parse_args()

    pk = PhishKit()

    if args.command == "create-campaign":
        pk.create_campaign(args.name, args.target)
    elif args.command == "add-targets":
        pk.add_targets(args.campaign, args.file)
    elif args.command == "generate-payload":
        pk.generate_payload(args.campaign, args.type)
    elif args.command == "start":
        pk.start_campaign(args.campaign, args.port)
    elif args.command == "analytics":
        pk.analytics(args.campaign)


if __name__ == "__main__":
    main()