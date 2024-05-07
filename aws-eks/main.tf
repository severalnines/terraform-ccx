# Terraform Settings Block
terraform {
  required_version = ">= 1.3.2"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      #version = "~> 4.4"
      version = "~> 5.0"
     }
  }
}


# Define Local Values in Terraform
locals {
  name_prefix = var.name_prefix
  environment = var.environment
  name = "${var.name_prefix}-${var.environment}"
  common_tags = {
    name_prefix = local.name_prefix
    environment = local.environment
  }
  eks_cluster_name = "${local.name}-${var.cluster_name}"  
}



