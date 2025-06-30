module "vpc" {
  source = "./modules/vpc"
}

module "security" {
  source = "./modules/security"
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source              = "./modules/ec2"
  vpc_id              = module.vpc.vpc_id
  public_subnet_id    = module.vpc.public_subnet_ids[0]
  sg_id               = module.security.web_sg_id
  key_name            = var.key_name
  github_app_repo_url = var.github_app_repo_url

  rds_endpoint = module.rds.rds_endpoint
  db_name      = "lamp_db_main"
  db_user      = var.db_username
  db_password  = var.db_password
}

module "rds" {
  source               = "./modules/rds"
  db_subnet_ids        = module.vpc.private_subnet_ids
  vpc_id               = module.vpc.vpc_id
  db_sg_id             = module.security.db_sg_id
  db_username          = var.db_username
  db_password          = var.db_password
}
