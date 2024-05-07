
# Get latest AMI ID for Amazon Linux2 OS
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name = "name"
    values = [ "amzn2-ami-hvm-*-gp2" ]
  }
  filter {
    name = "root-device-type"
    values = [ "ebs" ]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
  filter {
    name = "architecture"
    values = [ "x86_64" ]
  }
}


# Create AWS EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${local.name}-${var.cluster_name}"
  role_arn = aws_iam_role.eks_master_role.arn
  version = var.cluster_version

  vpc_config {
    subnet_ids = module.vpc.public_subnets
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs    
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }
  
  # Enable EKS Cluster Control Plane Logging
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
  ]
}

# # # Create Self managed Node group
# module "self_managed_node_group" {
#   source = "terraform-aws-modules/eks/aws//modules/self-managed-node-group"

#   name                        = "${local.name}-self-mng-ng"
#   cluster_name                = aws_eks_cluster.eks_cluster.name
#   cluster_version             = aws_eks_cluster.eks_cluster.version
#   cluster_endpoint            = aws_eks_cluster.eks_cluster.endpoint
#   cluster_auth_base64         = aws_eks_cluster.eks_cluster.certificate_authority[0].data
#   subnet_ids                  = module.vpc.private_subnets
#   create_launch_template      = true
#   create_iam_instance_profile = false
#   create_access_entry         = false
#   create                      = true
#   cluster_service_cidr        = aws_eks_cluster.eks_cluster.kubernetes_network_config[0].service_ipv4_cidr
#   iam_instance_profile_arn    = aws_iam_instance_profile.eks_nodegroup_instance_profile.arn
#   #ami_id                      = 

#   vpc_security_group_ids = [
#     aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
#   ]

#   min_size     = 1
#   max_size     = 2
#   desired_size = 1
#   launch_template_name   = "${local.name}-self-mng-template"
#   instance_type          = var.instance_type

#   tags = {
#     "k8s.io/cluster-autoscaler/enabled" = true
#     "k8s.io/cluster-autoscaler/${aws_eks_cluster.eks_cluster.name}" : "owned",
#     "Terraform Managed" = true
#   }
# }


# Create AWS EKS Node Group - Private

resource "aws_eks_node_group" "eks_ng_private" {
  cluster_name    = aws_eks_cluster.eks_cluster.name

  node_group_name = "${local.name}-eks-ng-private"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = module.vpc.private_subnets
  #version = var.cluster_version #(Optional: Defaults to EKS Cluster Kubernetes version)    
  
  ami_type = "AL2_x86_64"  
  capacity_type = "ON_DEMAND"
  disk_size = 100
  instance_types = [var.instance_type]
  
  
  scaling_config {
    desired_size = 1
    min_size     = 1    
    max_size     = 2
  }

  # Desired max percentage of unavailable worker nodes during node group update.
  update_config {
    max_unavailable = 1    
    #max_unavailable_percentage = 50    # ANY ONE TO USE
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
    kubernetes_config_map_v1.aws_auth 
  ] 
  tags = {
    Name = "Private-Node-Group"
  }
}
