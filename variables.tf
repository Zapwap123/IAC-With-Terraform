variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "db_username" {
  type        = string
  description = "RDS master username"
}

variable "db_password" {
  type        = string
  description = "RDS master password"
  sensitive   = true
}

variable "github_app_repo_url" {
  type        = string
  description = "GitHub repo URL for the PHP app"
}
variable "my_ip" {
  description = "Your public IP in CIDR notation (e.g. 1.2.3.4/32)"
  type        = string
}