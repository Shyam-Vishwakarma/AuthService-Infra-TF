locals {
  db_engine              = "sqlserver-ex"
  parameter_group_family = "sqlserver-ex-16.0"
  instance_class         = "db.t3.micro"
  db_major_version       = "16.00"
  database_name          = "main-db"
}

module "sqlserver" {
  source = "../../modules/rds"

  database_name                 = local.database_name
  project_name                  = var.project_name
  environment                   = var.environment
  engine                        = local.db_engine
  instance_class                = local.instance_class
  performance_insights_enabled  = true
  subnet_ids                    = module.vpc.outputs.private_subnet_ids
  port                          = var.rds_port
  vpc_id                        = module.vpc.outputs.vpc_id
  referenced_security_group_ids = [module.web_server.outputs.security_group_id]
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

  create_db_option_group               = true
  db_option_group_major_engine_version = local.db_major_version
}
