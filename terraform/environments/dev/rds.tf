locals {
  db_engine              = "sqlserver-ex"
  parameter_group_family = "sqlserver-ex-16.0"
  instance_class         = "db.t3.micro"
  db_major_version       = "16"
}

module "sqlserver" {
  source = "../../modules/rds"

  allocated_storage             = 20
  auto_minor_version_upgrade    = false
  backup_retention_period       = 0
  engine                        = local.db_engine
  instance_class                = local.instance_class
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
  create_before_destroy         = true
  skip_final_snapshot           = true

  create_db_parameter_group = true
  db_parameter_group_family = local.parameter_group_family
  db_parameter_group_parameters = [
    {
      name         = "max degree of parallelism"
      value        = "2"
      apply_method = "immediate"
    },
    {
      name         = "cost threshold for parallelism"
      value        = "50"
      apply_method = "immediate"
    },
    {
      name         = "optimize for ad hoc workloads"
      value        = "1"
      apply_method = "immediate"
    },
    {
      name         = "max server memory (MB)"
      value        = "2048"
      apply_method = "immediate"
    }
  ]

  create_db_option_group = false

  enable_blue_green_update = false
}

resource "aws_ssm_parameter" "database_endpoint" {
  name  = "/${var.project_name}/${var.environment}/database_endpoint"
  type  = "String"
  value = module.sqlserver.database_endpoint
}
