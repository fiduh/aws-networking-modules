## Basic Microservice Network Topology consists of:


* VPC-Microservices: Launch a VPC meant to house public-facing and stateless applications. The VPC includes 2 tiers of subnets (Public, Private), Internet Gateway, Route Table, Network Access Control List, security groups, NAT gateways.

* VPC-Datastores: Launch a VPC meant to house persistent data. the VPC includes a single tier of Private subnet, across multiple availability zones, routing rules, network ACLs, Security Groups.
  
* VPC Peering: By default, VPCs are completely isolated from each other, this allows communication between VPC-Microservices and VPC-Datastores
  
* VPN Client: This enables remote secure access to resources on the VPCs


## Usage

```
module "vpc" {
  source = "git::git@github.com:/osemiduh/aws-networking-modules/modules/vpc-microservices?ref=v1.0.8"
  name = "vpc-app"
  vpc_cidr_block = "10.0.0.0/21"

  public_subnets_cidr_with_azs = {
  "us-east-1a" = "10.0.0.0/24"
  "us-east-1b" = "10.0.1.0/24"
  }

  private_subnets_cidr_with_azs = {
  "us-east-1a" = "10.0.2.0/24"
  "us-east-1b" = "10.0.3.0/24"
  }
  
  enable_single_nat = true

  tags = {
    ManagedBy : "Terraform" 
  }

```

## NAT Gateway Scenarios
This example implementation supports two scenarios for creating NAT gateways
* Single NAT Gateway
   `enable_single_nat = true`

* One NAT Gateway per availability zone (if enabled)
   `one_nat_gateway_per_az = true`
