
module "eks_managed_node_group" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

  name            = "${local.name}-eks-mng"
  cluster_name    = module.eks.cluster_name
  cluster_version = module.eks.cluster_version

  subnet_ids = module.vpc.private_subnets
  cluster_service_cidr = module.eks.cluster_service_cidr
  // The following variables are necessary if you decide to use the module outside of the parent EKS module context.
  // Without it, the security groups of the nodes are empty and thus won't join the cluster.
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id

  vpc_security_group_ids            = [module.eks.node_security_group_id]

  min_size     = 1
  max_size     = 2
  desired_size = 1

  instance_types = [var.instance_type]
  capacity_type  = var.capacity_type

  labels = {
    Environment = var.environment
  }


  tags = {
    "Terraform Managed" = true
    Environment = var.environment
  }
}