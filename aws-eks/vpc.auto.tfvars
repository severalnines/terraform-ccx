# VPC Variables
vpc_name = "ccx-vpc"
vpc_cidr_block = "172.35.0.0/16"
# vpc_availability_zones = ["us-east-1a", "us-east-1b"]
vpc_public_subnets = ["172.35.32.0/24", "172.35.16.0/24"]
vpc_private_subnets = ["172.35.2.0/24", "172.35.6.0/24"]
vpc_enable_nat_gateway = true
vpc_single_nat_gateway = true
