variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "subnet_count" {
  description = "Number of public subnets to create"
  type        = number
  default     = 2
}

variable "public_cidrs" {
  type = list(string)
  description = "Public Subnet CIDR values"
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
/*
variable "private_cidrs" {
  type = list(string)
  description = "Private Subnet CIDR values"
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}
