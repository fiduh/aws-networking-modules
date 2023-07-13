variable "vpc_name" {
  description = "VPC name"
  type = string
  default = "main"
}

variable "vpc_cidr_block" {
  description = "Private CIDR Block for VPC, example 10.0.0.0/21"
  type        = string
}

variable "vpc_instance_tenancy" {
  description = "A VPC can have a tenancy of either default or dedicated. By default, your VPCs have default tenancy"
  type        = string
  default     = "default"
}

# Availability zones
variable "azs" {
  description = "A list of availability zones"
  type = list(string)
  default = []
}

# Subnets

variable "public_subnets" {
  description = "A list of public subnets"
  type = list(string)
  default = []
}

variable "private_subnets" {
  description = "A list of private subnets"
  type = list(string)
  default = []
}


variable "public_subnets_cidr_with_azs" {
  description = "A map of public subnets CIDRs with associated Aviability Zones inside the VPC"
  type        = map(string)
  default     = {}
}

variable "private_subnets_cidr_with_azs" {
  description = "A map of private subnets CIDRs with associated Aviability Zones inside the VPC"
  type        = map(string)
  default     = {}
}

variable "enable_single_nat" {
  type        = bool
  description = "Enable a single NAT gateway, Note: This is not fault tolerant"
  default     = false
}

variable "one_nat_gateway_per_subnet" {
  type        = bool
  description = "Enable NAT in all AZs, This achieves fault tolerance"
  default     = false
}

################################################################################
# Public Network ACLs
################################################################################

variable "public_inbound_acl_rules" {
  description = "Public subnets inbound network ACLs"
  type        = list(map(string))
  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}


variable "public_outbound_acl_rules" {
  description = "Public subnets outbound network ACLs"
  type        = list(map(string))
  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}


################################################################################
# Private Network ACLs
################################################################################
variable "private_inbound_acl_rules" {
  description = "Private subnets inbound network ACLs"
  type        = list(map(string))
  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}

variable "private_outbound_acl_rules" {
  description = "Private subnets outbound network ACLs"
  type        = list(map(string))
  default = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
  ]
}