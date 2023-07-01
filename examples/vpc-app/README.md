## Basic Microservices Application Network Topology. This architecture consists of:


* Microservices VPC: Launch a VPC meant to house public-facing and stateless applications. The VPC includes 2 tiers of subnets (Public, Private), Internet Gateway, Route Tables, Network Access Control List, Security Groups, NAT Gateways.

* Datastores VPC: Launch a VPC meant to house persistent data. the VPC includes a single tier of Private subnet, across multiple availability zones, Route Tables, Network ACLs, and Security Groups.
  
* VPC Peering: By default, VPCs are completely isolated from each other, this allows communication between Microservices VPC and Datastores VPC
  
* VPN Client: This enables remote secure access to resources on the VPCs
  
## Prerequisites 
To manage your terraform state remotely and securely:
First set up an S3 bucket and DynamoDB table - refer to the example/global/terraform_remote_state folder.
Configure terraform backend to use the S3 bucket to store your .tfstate file and use DynamoDB table for State locking.

Make sure your backend key is the same as the folder path `examples/vpc-app/terraform.tfstate`, this gives you a 1:1 mapping between the layout of your terraform code in version control and your Terraform state files in S3. 


```

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


```
module "vpc" {
  source = "github.com/osemiduh/aws-networking-modules//modules/vpc?ref=v0.1.0"
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
  one_nat_gateway_per_az = false

  tags = {
    ManagedBy : "Terraform" 
  }

```

To run this example you need to execute:
```
terraform init
terraform plan
terraform apply
```
Note: this example may create resources that can cost money (AWS Elastic IP, for example). Run terraform destroy when you don't need these resources or you can disable them.


## NAT Gateway Scenarios
This example implementation supports two scenarios for creating NAT gateways
* Single NAT Gateway
   `enable_single_nat = true`

* One NAT Gateway per availability zone (if enabled)
   `one_nat_gateway_per_az = true`
