module "vpc" {
  source = "../../modules/vpc"

  project_name            = var.project_name
  environment             = var.environment
  vpc_name                = "main-vpc"
  vpc_cidr                = var.vpc_cidr
  desired_private_subnets = var.desired_private_subnets
  desired_public_subnets  = var.desired_public_subnets
  availability_zones      = data.aws_availability_zones.available.names
}
