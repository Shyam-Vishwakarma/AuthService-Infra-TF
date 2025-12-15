locals {
  name_prefix = "${var.project_name}-${var.environment}-${var.vpc_name}"

  total_subnets = var.desired_public_subnets + var.desired_private_subnets

  vpc_mask_length    = split("/", var.vpc_cidr)[1]
  subnet_mask_length = 24

  newbits               = local.subnet_mask_length - tonumber(local.vpc_mask_length)
  total_available_zones = length(var.availability_zones)

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}


resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  instance_tenancy     = var.tenancy

  tags = merge(
    local.tags,
    var.tags, {
      Name = "${local.name_prefix}"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    local.tags, {
      Name = "${local.name_prefix}-igw"
  })
}

resource "aws_subnet" "public" {
  count                   = var.desired_public_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, local.newbits, count.index)
  availability_zone       = var.availability_zones[count.index % local.total_available_zones]
  map_public_ip_on_launch = var.public_subnet_map_public_ip_on_launch

  tags = merge(
    local.tags, {
      Name = "${local.name_prefix}-public-subnet-${count.index + 1}"
  })
}

resource "aws_subnet" "private" {
  count             = var.desired_private_subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, local.newbits, count.index + var.desired_public_subnets)
  availability_zone = var.availability_zones[count.index % local.total_available_zones]

  tags = merge(
    local.tags, {
      Name = "${local.name_prefix}-private-subnet-${count.index + 1}"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    local.tags, {
      Name = "${local.name_prefix}-public-rt"
  })
}


resource "aws_route_table_association" "public" {
  count = var.desired_public_subnets

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
