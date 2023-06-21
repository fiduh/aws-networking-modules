
 backend "s3" {
    bucket = "mybucket"
    key    = "path/to/my/key"
    region = "us-east-1"
  }

  provider "aws" {
    region = "us-east-1"
  }

  module "vpc-app-mgmt-datastore" {
    source = "../../modules/vpc"
  }