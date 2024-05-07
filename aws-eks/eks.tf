
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = "${local.eks_cluster_name}"
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true
  
  node_security_group_tags = {
    "kubernetes.io/cluster/${local.eks_cluster_name}" = null
  }
  create_iam_role = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = { 
      most_recent = true
      service_account_role_arn = aws_iam_role.ebs_csi_controller_role.arn
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets

  # External encryption key
  # create_kms_key = false
  # cluster_encryption_config = {}


}


