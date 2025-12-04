module "web_server" {
  source = "../../modules/ec2"

  project_name           = var.project_name
  environment            = var.environment
  instance_type          = var.instance_type
  subnet_id              = module.aws_vpc.public_subnet_ids[0]
  vpc_id                 = module.aws_vpc.vpc_id
  ami_owner_filter       = var.ami_owner_filter
  ami_name_filter        = var.ami_name_filter
  root_block_device_size = 40
  encrypted              = true
  delete_on_termination  = true
  cpu_core_count         = 1
  cpu_threads_per_core   = 2
  allow_rdp              = true
  associate_public_ip    = true
  allow_winrm            = true
  access_cidr_block      = var.access_cidr_block
  get_password_data      = true
  instance_tenancy       = "default"
  run_startup_sript      = true
  user_data_script_path  = "${path.module}/scripts/winrm_setup.ps1"
}

resource "aws_ssm_parameter" "instance_public_ip" {
  name  = "/${var.project_name}/${var.environment}/instance_public_ip"
  type  = "String"
  value = module.web_server.instance_public_ip
}

resource "aws_ssm_parameter" "instance_admin_password" {
  name  = "/${var.project_name}/${var.environment}/instance_password"
  type  = "SecureString"
  value = module.web_server.admin_password
}
