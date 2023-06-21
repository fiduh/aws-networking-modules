terraform {
  required_version = "value"
  required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "~> 4.0"
    }
  }
}

resource "aws_vpc" "vpc" {
  
}

