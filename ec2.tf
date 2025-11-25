module "web_server" {
  source = "./modules/ec2"

  instance_name          = "${var.project_name}-${var.environment}-web-server"
  instance_type          = var.instance_type
  subnet_id              = module.aws_vpc.public_subnet_ids[0]
  vpc_id                 = module.aws_vpc.vpc_id
  ami_owner_filter       = var.ami_owner_filter
  ami_name_filter        = var.ami_name_filter
  root_block_device_size = 30
  encrypted              = true
  delete_on_termination  = true
  cpu_core_count         = 1
  cpu_threads_per_core   = 2
  allow_rdp              = true
  associate_public_ip    = true
  allow_tcp              = true
  access_cidr_block      = "202.66.166.104/32"
}
