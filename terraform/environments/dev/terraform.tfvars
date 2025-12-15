aws_region              = "us-east-1"
vpc_cidr                = "10.0.0.0/16"
desired_private_subnets = 2
desired_public_subnets  = 2
project_name            = "myproject"
environment             = "dev"
rds_port                = 1433
access_cidr_blocks      = { "JTG-Wifi-A" : "122.176.100.129/32", "JTG-Wifi-B" : "122.176.100.128/32", "Hostel" : "103.120.30.62/32" }
