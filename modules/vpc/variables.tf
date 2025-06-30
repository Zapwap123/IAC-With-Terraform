variable "vpc_cidr" {
  default = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.20.101.0/24", "10.20.102.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b"]
}
