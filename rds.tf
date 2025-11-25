module "sqlserver" {
  source                        = "./modules/rds"
  allocated_storage             = 20
  auto_minor_version_upgrade    = false
  backup_retention_period       = 0
  engine                        = "sqlserver-ex"
  instance_class                = "db.t3.micro"
  performance_insights_enabled  = false
  deletion_protection           = false
  multi_az                      = false
  storage_encrypted             = true
  subnet_ids                    = [module.aws_vpc.private_subnet_ids[0], module.aws_vpc.private_subnet_ids[1]]
  project_name                  = var.project_name
  environment                   = var.environment
  publicly_accessible           = false
  port                          = var.rds_port
  vpc_id                        = module.aws_vpc.vpc_id
  referenced_security_group_ids = [module.web_server.security_group_id]
}
