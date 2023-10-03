## Terraform module which creates VPC resources on AWS

## Main Module

* VPC: Customizable, versioned, and immutable VPC meant to house public-facing and stateless applications or persistent data. The VPC includes Subnets (public, private), Internet gateway (IGW), Route Tables and routing rules, Network Access Control List (NACL), Security Groups, NAT Gateways.



### Supporting Modules
---
There are several supporting modules that add extra functionality on top of the Main Module:

* **VPC-Peering** : By default, VPCs are completely isolated from each other, but sometimes, you want to allow them to communicate, such as allowing the apps in a  VPC housing public-facing applications to communicate with the database VPC. This module creates peering connections and route table entries that allow private communication between VPCs
* **VPN client**: This module enables remote secure access to resources on the VPCs
* **VPC-Flow-Logs**: Create VPC flow logs to log network traffic in VPCs, subnets, and Elastic Network Interfaces.

Click on each module above to see its documentation. *Head over to the example folder, for example, implementations*.



## NAT Gateway Scenarios
This module supports two scenarios for creating NAT gateways.
### Single NAT Gateway
If `enable_single_nat = true`, then all private subnets will route their Internet traffic through this single NAT gateway. The NAT gateway will be placed in the first public subnet in your public_subnets block.
   `enable_single_nat = true`
  `one_nat_gateway_per_az = false`

## One NAT Gateway per Public Subnet per Availability Zone (if enabled)
If `one_nat_gateway_per_az = true` and `enable_single_nat = false`, then the module will place one NAT gateway in each Public Subnet per Availability Zone you specify in public_subnets_cidr_with_azs.
   `one_nat_gateway_per_az = true`
   `enable_single_nat = false`



#### What's a VPC?

AWS VPC is your logically isolated virtual network on Amazon’s public cloud, where you can deploy your own resources. It spans a single region (Max. 5 VPCs per region - soft limit), made up of several Availability Zones. You can further divide your network into multiple smaller networks called subnets (Max. 200 subnets per VPC - soft limit), where you can create AWS resources, such as EC2 instances.

To allow communication between resources in your VPC and the internet, you need an internet gateway attached to the VPC, route table containing routes directing local traffic to the IGW has to be associated with the subnets that need access to the internet

To secure this network, NACLs determine which traffic is allowed in and out of your subnets, Security groups control which traffic is allowed to reach the resources you deployed in your network

Because VPC is Private, only [Private IPv4 Network Ranges RFC1918](https://datatracker.ietf.org/doc/html/rfc1918) of Internet Engineering Task Force (IETF) are allowed as VPC CIDRs.
```
10.0.0.0 - 10.255.255.255 (10.0.0.0/8)
172.16.0.0 - 172.31.255.255 (172.16.0.0/12)
192.168.0.0 - 192.168.255.255 (192.168.0.0/16)

```



When in doubt use [IP address Guide](www.ipaddressguide.com/cidr) to calculate the number of IP addresses in your CIDR
Max CIDR per VPC 5, for each CIDR
```
  Min. size is /28 (16 IP addresses)
  Max. size is /16 (65536 IP addresses)
```
Two private VPCs can communicate with each other using VPC Peering



## Basic Microservices Application Network Topology. This architecture consists of:


* Microservices VPC: Launch a VPC meant to house public-facing and stateless applications. The VPC includes 2 tiers of subnets (Public and private), Internet Gateway, Route Tables, Network Access Control List, Security Groups, NAT Gateways.

* Datastores VPC: Launch a VPC meant to house persistent data. the VPC includes a single tier of Private subnet, across multiple availability zones, Route Tables, Network ACLs, and Security Groups.
  
* VPC Peering: By default, VPCs are completely isolated from each other, this allows communication between Microservices VPC and Datastores VPC
  
* VPN Client: This enables remote secure access to resources on the VPCs
  
## Prerequisites 
To manage your terraform state remotely and securely:
First set up an S3 bucket and DynamoDB table - refer to the example/global/terraform_remote_state folder.
Configure terraform backend to use the S3 bucket to store your .tfstate file and use DynamoDB table for State locking.

Make sure your backend key is the same as the folder path `examples/vpc-app/terraform.tfstate`, this gives you a 1:1 mapping between the layout of your terraform code in version control and your Terraform state files in S3. 


```hcl

terraform {
  backend "s3" {
    bucket         = "S3-bucket-name"
    key            = "examples/vpc-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "dynamodb-table-name"
    encrypt        = true
  }
}

```

## Quick Start
Your development environment or CI/CD Server should have Terraform > 1.0.0 installed



## Usage


```hcl

data "aws_availability_zones" "available_azs" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available_azs.names, 0, 2)
  vpc_cidr = "10.0.0.0/21"
}

module "vpc" {
  source = "github.com/osemiduh/aws-networking-modules//modules/vpc?ref=v0.1.0"
  name = "vpc-app"
  azs = local.azs
  vpc_cidr_block = local.vpc_cidr

  public_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 3, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 3, k + 3)]
  
  enable_single_nat = true
  one_nat_gateway_per_subnet = false

  tags = {
    ManagedBy : "Terraform" 
  }
}

```

To run this example you need to execute:
```bash
terraform init
terraform plan
terraform apply
```
Note: this example may create resources that can cost money (AWS Elastic IP, for example). Run terraform destroy when you don't need these resources or you can disable them.

