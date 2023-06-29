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

variable "one_nat_gateway_per_az" {
  type        = bool
  description = "Enable NAT in all AZs, This achieves fault tolerance"
  default     = false
}
