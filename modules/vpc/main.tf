locals {
  public_subnets_ids  = values(aws_subnet.public)[*].id
  private_subnets_ids = values(aws_subnet.private)[*].id
}

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
    Name = "Public-${each.key}"
  }
}


# Public Route Table
resource "aws_route_table" "public" {
  # Create this public route table, only if public subnets are created
  count  = length(var.public_subnets_cidr_with_azs) != 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Public-rt"
  }
}

# Public Route Table Subnet association
resource "aws_route_table_association" "public" {
  count          = length(local.public_subnets_ids)
  subnet_id      = local.public_subnets_ids[count.index]
  route_table_id = aws_route_table.public[0].id

  depends_on = [aws_subnet.public]
}

# Public Route Table Route entries
resource "aws_route" "public_igw_rt_entry" {
  count                  = length(var.public_subnets_cidr_with_azs) != 0 ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
  depends_on             = [aws_route_table.public]
}

################################################################################
# Public Network ACLs
################################################################################
resource "aws_network_acl" "public_nacl" {
  count = length(var.public_subnets_cidr_with_azs) != 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Public NACL-traffic"
  }
}

# Public subnet NACL Association
resource "aws_network_acl_association" "public_nacl_association" {
  count = length(var.public_subnets_cidr_with_azs) != 0 ? length(local.public_subnets_ids) : 0
  network_acl_id = aws_network_acl.public_nacl[0].id
  subnet_id      = local.public_subnets_ids[count.index]
}

# Public NACL inbound entry rules

resource "aws_network_acl_rule" "public_nacl_inbound" {
  count = length(var.public_subnets_cidr_with_azs) != 0 ? length(var.public_inbound_acl_rules) : 0
  network_acl_id = aws_network_acl.public_nacl[0].id

  rule_number    = var.public_inbound_acl_rules[count.index]["rule_number"]
  egress         = false
  protocol       = var.public_inbound_acl_rules[count.index]["protocol"]
  rule_action    = var.public_inbound_acl_rules[count.index]["rule_action"]
  cidr_block     = lookup(var.public_inbound_acl_rules[count.index], "cidr_block", null)
  from_port      = lookup(var.public_inbound_acl_rules[count.index], "from_port", null)
  to_port        = lookup(var.public_inbound_acl_rules[count.index], "to_port", null)
}


# Public NACL outbound entry rules
resource "aws_network_acl_rule" "public_nacl_outbound" {
  count = length(var.public_subnets_cidr_with_azs) != 0 ? length(var.public_outbound_acl_rules) : 0
  network_acl_id = aws_network_acl.public_nacl[0].id

  rule_number    = var.public_outbound_acl_rules[count.index]["rule_number"]
  egress         = true
  protocol       = var.public_outbound_acl_rules[count.index]["protocol"]
  rule_action    = var.public_outbound_acl_rules[count.index]["rule_action"]
  cidr_block     = lookup(var.public_outbound_acl_rules[count.index], "cidr_block", null)
  from_port      = lookup(var.public_outbound_acl_rules[count.index], "from_port", null)
  to_port        = lookup(var.public_outbound_acl_rules[count.index], "to_port", null)
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
    Name = "Private-${each.key}"
  }
}


# Private Route Tables for NATs per subnet on each AZ
resource "aws_route_table" "rt_for_nat_per_az" {
  for_each = var.one_nat_gateway_per_az ? var.private_subnets_cidr_with_azs : {}
  vpc_id   = aws_vpc.vpc.id
  tags = {
    Name = "private-rt-${each.key}"
  }
}



# Private Route Tables Subnet association for NATs per AZs
resource "aws_route_table_association" "rt_per_private_subnet" {
  for_each       = var.one_nat_gateway_per_az ? var.private_subnets_cidr_with_azs : {}
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.rt_for_nat_per_az[each.key].id

  depends_on = [aws_subnet.private]
}



locals {
  nat_rt_ids = values(aws_route_table.rt_for_nat_per_az)[*].id
}

# Private Route Table Route entries for NATs per AZs
resource "aws_route" "private_rt_nat_entry_per_az" {
  count                  = var.one_nat_gateway_per_az ? length(var.private_subnets_cidr_with_azs) : 0
  route_table_id         = local.nat_rt_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_per_az[count.index].id
  depends_on             = [aws_route_table.rt_for_nat_per_az]

}

# Private Route Table for single NAT 
resource "aws_route_table" "rt_for_single_nat" {
  count  = var.enable_single_nat ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "single-private-rt"
  }
}

# Private Route Table Route entry for single NAT
resource "aws_route" "nat_single_route" {
  count                  = var.enable_single_nat ? 1 : 0
  route_table_id         = aws_route_table.rt_for_single_nat[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.single_nat[0].id
  depends_on             = [aws_route_table.rt_for_single_nat]
}

# Private Route Table Subnets association for single NAT
resource "aws_route_table_association" "nat_single_subnet" {
  count          = var.enable_single_nat ? length(var.private_subnets_cidr_with_azs) : 0
  subnet_id      = local.private_subnets_ids[count.index]
  route_table_id = aws_route_table.rt_for_single_nat[0].id

  depends_on = [aws_subnet.private]
}

################################################################################
# Private Network ACLs
################################################################################
resource "aws_network_acl" "private_nacl" {
  count = length(var.private_subnets_cidr_with_azs) != 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Private NACL-traffic"
  }
}

# Private subnet NACL Association
resource "aws_network_acl_association" "private_nacl_association" {
  count = length(var.private_subnets_cidr_with_azs) != 0 ? length(local.private_subnets_ids) : 0
  network_acl_id = aws_network_acl.private_nacl[0].id
  subnet_id      = local.private_subnets_ids[count.index]
}

# Private NACL inbound entry rules
resource "aws_network_acl_rule" "private_inbound" {
   count = length(var.private_subnets_cidr_with_azs) != 0 ? length(var.private_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.private_nacl[0].id

  egress          = false
  rule_number     = var.private_inbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.private_inbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.private_inbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.private_inbound_acl_rules[count.index], "to_port", null)
  protocol        = var.private_inbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.private_inbound_acl_rules[count.index], "cidr_block", null)
}

# Private NACL outbound entry rules
resource "aws_network_acl_rule" "private_outbound" {
  count = length(var.private_subnets_cidr_with_azs) != 0 ? length(var.private_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.private_nacl[0].id

  egress          = true
  rule_number     = var.private_outbound_acl_rules[count.index]["rule_number"]
  rule_action     = var.private_outbound_acl_rules[count.index]["rule_action"]
  from_port       = lookup(var.private_outbound_acl_rules[count.index], "from_port", null)
  to_port         = lookup(var.private_outbound_acl_rules[count.index], "to_port", null)
  protocol        = var.private_outbound_acl_rules[count.index]["protocol"]
  cidr_block      = lookup(var.private_outbound_acl_rules[count.index], "cidr_block", null)
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

# Single NAT Gateway
resource "aws_nat_gateway" "single_nat" {
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

# Elastic IP for Single NAT Gateway
resource "aws_eip" "nat" {
  count  = var.enable_single_nat ? 1 : 0
  domain = "vpc"
}

# Elastic IPs for NAT Gateway Per AZs
resource "aws_eip" "eip_nat_per_az" {
  count  = var.one_nat_gateway_per_az ? length(var.public_subnets_cidr_with_azs) : 0
  domain = "vpc"
}

# NAT Gateways for each Public Subnet per AZ
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


