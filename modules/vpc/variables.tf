variable "vpc_cidr_block" {
  description = "Private CIDR Block"
  type        = string
}

variable "vpc_instance_tenancy" {
  description = "instance tenancy"
  type        = string
  default     = "default"
}


variable "public_subnets_cidr_with_azs" {
  description = "A list of public subnets inside the VPC"
  type        = map(string)
  default     = {}
}

variable "private_subnets_cidr_with_azs" {
  description = "A list of public subnets inside the VPC"
  type        = map(string)
  default     = {}
}

variable "enable_single_nat" {
  type        = bool
  description = "Enable single a single NAT gateway"
  default     = false
}

variable "one_nat_gateway_per_az" {
  type        = bool
  description = "Enable NAT in all AZs"
  default     = false
}
