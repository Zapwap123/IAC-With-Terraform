variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "sg_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "github_app_repo_url" {
  type = string
}

variable "rds_endpoint" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type = string
  sensitive = true
}
