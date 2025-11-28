module "aws_vpc" {
  source = "../../modules/aws-vpc"

  project_name                          = var.project_name
  environment                           = var.environment
  vpc_cidr                              = var.vpc_cidr
  desired_private_subnets               = var.desired_private_subnets
  desired_public_subnets                = var.desired_public_subnets
  public_subnet_map_public_ip_on_launch = true
  enable_dns_hostnames                  = true
  enable_dns_support                    = true
  tenancy                               = "default"
}
