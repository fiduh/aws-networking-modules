
  provider "aws" {
    region = "us-east-1"
  }

  module "vpc-app-mgmt-datastore" {
    source = "../../modules/vpc"

    vpc_cidr_block = "10.0.0.0/23"
    public_subnets_cidr_with_azs = {
    "us-west-1a" = "10.0.0.0/24"
    "us-west-1b" = "10.0.1.0/24"
    }
    private_subnets_cidr_with_azs = {
    "us-west-1a" = "10.0.2.0/24"
    "us-west-1b" = "10.0.3.0/24"
    }
  }