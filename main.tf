
# ============================================
# Radoslaw Gorski - Terraform AWS Lab
# Cloud Network Lab: VPC + Transit Gateway
# Use for GitHub portfolio & LinkedIn Featured
# ============================================

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1" # Dublin - close to Three Ireland / UK
  # Use AWS CLI profile or env vars for credentials
}

# --- VPC Production ---
resource "aws_vpc" "prod_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "prod-vpc-eu-west-1"
    Environment = "Production"
    Owner       = "Radoslaw Gorski - Network Lab"
    Purpose     = "EVPN/VXLAN to AWS hybrid lab"
  }
}

# --- Subnets (simulate Leafs) ---
resource "aws_subnet" "prod_subnets" {
  count = 3
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.10.${count.index + 1}.0/24"
  availability_zone = "eu-west-1${element(["a", "b", "c"], count.index)}"

  tags = {
    Name = "prod-subnet-${count.index + 1}-leaf-0${count.index + 1}"
    Type = "Compute / Leaf"
  }
}

# --- Internet Gateway (Edge / WAN) ---
resource "aws_internet_gateway" "prod_igw" {
  vpc_id = aws_vpc.prod_vpc.id
  tags = { Name = "prod-igw-edge-wan" }
}

# --- Transit Gateway (BGP/MPLS Core replacement in Cloud) ---
resource "aws_ec2_transit_gateway" "tgw" {
  description                     = "TGW for hybrid connectivity - Juniper MX Edge simulation"
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = {
    Name = "tgw-core-eu-west-1"
    Role = "BGP MPLS Core - Cloud"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "prod_attach" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.prod_vpc.id
  subnet_ids         = aws_subnet.prod_subnets[*].id

  tags = { Name = "tgw-attach-prod-vpc" }
}

# --- Security Groups (Palo Alto simulation) ---
resource "aws_security_group" "prod_sg" {
  name        = "prod-sg-next-gen-fw"
  description = "Simulates Palo Alto NGFW rules - North-South inspection"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    description = "Allow BGP (TCP 179) for EVPN peering"
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    description = "Allow VXLAN UDP 4789"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "sg-palo-alto-sim" }
}

# --- Outputs for documentation ---
output "vpc_id" {
  value = aws_vpc.prod_vpc.id
}
output "tgw_id" {
  value = aws_ec2_transit_gateway.tgw.id
}
output "subnet_ids" {
  value = aws_subnet.prod_subnets[*].id
}

# --- README for GitHub ---
# This lab demonstrates:
# 1. IaC for Cloud Networking (Terraform)
# 2. Hybrid Cloud connectivity concept (TGW = MPLS core in cloud)
# 3. Security groups as NGFW simulation (BGP 179, VXLAN 4789)
# 4. Multi-AZ resilient design (like Spine-Leaf HA)
# Next steps: Add VPN attachment (IPsec SD-WAN simulation) and Direct Connect gateway
