variable "vpc_id" {
  type = string
}

variable "my_ip" {
  type        = string
  description = "Your public IP with CIDR (e.g. 1.2.3.4/32)"
}
