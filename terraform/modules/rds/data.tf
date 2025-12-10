data "aws_rds_orderable_db_instance" "db" {
  engine                     = var.engine
  engine_latest_version      = var.create_latest_version
  storage_type               = var.storage_type
  preferred_instance_classes = [var.instance_class]
}
