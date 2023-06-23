terraform {
# Require Terraform Core at exactly version 1.5.1
  required_version = "1.5.1"
  required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = var.vpc_instance_tenancy

  tags = {
    Name = "main"
  }
}

################################################################################
# Publiс Subnets
################################################################################
resource "aws_subnet" "public" {
  for_each = var.public_subnets_cidr_with_azs
  vpc_id     = aws_vpc.vpc.id
  cidr_block = each.value

  availability_zone = each.key
  map_public_ip_on_launch = true

  tags = {
    Name = "Main"
  }
}

locals {
  public_subnets_ids = values(aws_subnet.public)[*].id
  private_subnets_ids = values(aws_subnet.private)[*].id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "example"
  }
}


resource "aws_route_table_association" "public" {
  for_each = toset(local.public_subnets_ids)
  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
  depends_on                = [aws_route_table.public]
}


################################################################################
# Private Subnets
################################################################################
resource "aws_subnet" "private" {
  for_each = var.private_subnets_cidr_with_azs
  vpc_id     = aws_vpc.vpc.id
  cidr_block = each.value

  availability_zone = each.key
  map_public_ip_on_launch = false

  tags = {
    Name = "Main"
  }
}

/*
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "example"
  }
}

resource "aws_route_table_association" "private" {
  for_each = toset(local.private_subnets_ids)
  subnet_id      = each.value
  route_table_id = aws_route_table.private.id
}

resource "aws_route" "private_internet_gateway" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_internet_gateway.igw.id
  depends_on                = [aws_route_table.private]
}

*/

################################################################################
# Internet Gateway
################################################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "main"
  }
}

################################################################################
# NAT Gateway
################################################################################
