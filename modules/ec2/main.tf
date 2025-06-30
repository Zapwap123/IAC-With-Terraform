data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.sg_id]
  key_name               = var.key_name
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.sh", {
    rds_endpoint = var.rds_endpoint,
    db_name      = var.db_name,
    db_user      = var.db_user,
    db_password  = var.db_password,
    github_url   = var.github_app_repo_url
  })

  tags = {
    Name = "terraform-lamp-web-instance"
yes
  }
}
