module "aws_vpc" {
  source = "./modules/aws-vpc"

  project_name                          = var.project_name
  environment                           = var.environment
  vpc_cidr                              = var.vpc_cidr
  availability_zone                     = var.availability_zone
  desired_private_subnets               = var.desired_private_subnets
  desired_public_subnets                = var.desired_public_subnets
  public_subnet_map_public_ip_on_launch = true
  enable_dns_hostnames                  = true
  enable_dns_support                    = true
  instance_tenancy                      = "default"
}

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
}
