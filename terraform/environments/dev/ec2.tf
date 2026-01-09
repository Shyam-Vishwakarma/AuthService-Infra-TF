locals {
  instance_type         = "t3.small"
  instance_name         = "windows-auth-service"
  user_data_script_path = "${path.module}/scripts/winrm_setup.ps1"
  instance_profile_name = "auth-service-ec2-logging"
}

module "web_server" {
  source = "../../modules/ec2"

  instance_name        = local.instance_name
  project_name         = var.project_name
  environment          = var.environment
  instance_type        = local.instance_type
  ami                  = data.aws_ami.windows.id
  vpc_id               = module.vpc.outputs.vpc_id
  subnet_id            = module.vpc.outputs.public_subnet_ids[0]
  access_cidr_blocks   = var.access_cidr_blocks
  iam_instance_profile = local.instance_profile_name

  root_block_device = {
    volume_size           = 30
    delete_on_termination = true
  }

  cpu_options = {
    core_count = 1
  }

  associate_public_ip   = true
  allow_rdp             = true
  allow_winrm           = true
  allow_http            = true
  run_startup_sript     = true
  user_data_script_path = local.user_data_script_path
}
