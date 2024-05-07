

# Datasource: 
data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.eks_cluster.id
}

# Terraform Kubernetes Provider
provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token 
}

data "aws_caller_identity" "current" {}

locals {
  configmap_roles = [
    {
      rolearn = "${aws_iam_role.eks_nodegroup_role.arn}"
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = ["system:bootstrappers", "system:nodes"]
    }
  ]
  configmap_users = [
    {
      userarn = data.aws_caller_identity.current.arn
      username = data.aws_caller_identity.current.user_id
      groups = ["system:masters"]
    }
  ]
}

# Resource: Kubernetes Config Map
resource "kubernetes_config_map_v1" "aws_auth" {
  depends_on = [aws_eks_cluster.eks_cluster]
  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(local.configmap_roles)
    mapUsers = yamlencode(local.configmap_users)
  }

}