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
    Name = var.vpc_name
  }
}

################################################################################
# Publiс Subnets
################################################################################
resource "aws_subnet" "public" {
  for_each   = var.public_subnets_cidr_with_azs
  vpc_id     = aws_vpc.vpc.id
  cidr_block = each.value

  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = {
    Name = "Main"
  }
}

locals {
  public_subnets_ids  = values(aws_subnet.public)[*].id
  private_subnets_ids = values(aws_subnet.private)[*].id
}

resource "aws_route_table" "public" {
  count  = length(var.public_subnets_cidr_with_azs) != 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "example"
  }
}


resource "aws_route_table_association" "public" {
  count          = length(local.public_subnets_ids)
  subnet_id      = local.public_subnets_ids[count.index]
  route_table_id = aws_route_table.public[0].id

  depends_on = [aws_subnet.public]
}

resource "aws_route" "public_igw_rt_entry" {
  count                  = length(var.public_subnets_cidr_with_azs) != 0 ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
  depends_on             = [aws_route_table.public]
}




################################################################################
# Private Subnets
################################################################################
resource "aws_subnet" "private" {
  for_each   = var.private_subnets_cidr_with_azs
  vpc_id     = aws_vpc.vpc.id
  cidr_block = each.value

  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = {
    Name = "Main"
  }
}


resource "aws_route_table" "rt_for_nat_per_az" {
  for_each = var.one_nat_gateway_per_az ? var.private_subnets_cidr_with_azs : {}
  vpc_id   = aws_vpc.vpc.id
  tags = {
    Name = "private-rt-${each.key}"
  }
}


resource "aws_route_table_association" "rt_per_private_subnet" {
  for_each       = var.one_nat_gateway_per_az ? var.private_subnets_cidr_with_azs : {}
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.rt_for_nat_per_az[each.key].id

  depends_on = [aws_subnet.private]
}



locals {
  nat_rt_ids = values(aws_route_table.rt_for_nat_per_az)[*].id
}

resource "aws_route" "private_rt_nat_entry_per_az" {
  count                  = var.one_nat_gateway_per_az ? length(var.private_subnets_cidr_with_azs) : 0
  route_table_id         = local.nat_rt_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_per_az[count.index].id
  depends_on             = [aws_route_table.rt_for_nat_per_az]

}


resource "aws_route_table" "rt_for_single_nat" {
  count  = var.enable_single_nat ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "single-private-rt"
  }
}

resource "aws_route" "nat_single_route" {
  count                  = var.enable_single_nat ? 1 : 0
  route_table_id         = aws_route_table.rt_for_single_nat[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.example[0].id
  depends_on             = [aws_route_table.rt_for_single_nat]
}

resource "aws_route_table_association" "nat_single_subnet" {
  count          = var.enable_single_nat ? length(var.private_subnets_cidr_with_azs) : 0
  subnet_id      = local.private_subnets_ids[count.index]
  route_table_id = aws_route_table.rt_for_single_nat[0].id

  depends_on = [aws_subnet.private]
}



################################################################################
# Internet Gateway
################################################################################
resource "aws_internet_gateway" "igw" {
  count  = length(var.public_subnets_cidr_with_azs) != 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "main"
  }
}


################################################################################
# NAT Gateway
################################################################################


resource "aws_nat_gateway" "example" {
  count = var.enable_single_nat ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = local.public_subnets_ids[0]

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}


resource "aws_eip" "nat" {
  count  = var.enable_single_nat ? 1 : 0
  domain = "vpc"
}

resource "aws_eip" "eip_nat_per_az" {
  count  = var.one_nat_gateway_per_az ? length(var.public_subnets_cidr_with_azs) : 0
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_per_az" {
  count         = var.one_nat_gateway_per_az ? length(local.public_subnets_ids) : 0
  allocation_id = aws_eip.eip_nat_per_az[count.index].id
  subnet_id     = local.public_subnets_ids[count.index]

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}
/*
*/

