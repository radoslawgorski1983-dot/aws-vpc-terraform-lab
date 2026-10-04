
# AWS Cloud Network Lab – Terraform
**Author:** Radoslaw Gorski – Senior Network Engineer | EVPN/VXLAN & Automation
**Purpose:** Portfolio for 2026 job market – shows Terraform + AWS networking skills

## Architecture
- VPC 10.10.0.0/16 with 3 subnets across 3 AZs (simulates Leaf switches)
- Internet Gateway (Edge/WAN – Juniper MX simulation)
- Transit Gateway (BGP MPLS Core in Cloud)
- Security Group with BGP 179 and VXLAN 4789 allowed (Palo Alto NGFW simulation)

## Why this lab?
In my roles at Three Ireland and Mars I worked on EVPN/VXLAN + MPLS/BGP fabrics (Nexus 9k). This lab translates that knowledge to cloud:
- TGW = MPLS core
- VPC subnets = Leafs / Compute Racks
- SG = Firewall inspection

## How to run
```bash
terraform init
terraform plan
terraform apply
```

## Next
- Add VPN attachment (IPsec SD-WAN)
- Add Direct Connect Gateway
- Automate with Ansible + Python (netmiko)


