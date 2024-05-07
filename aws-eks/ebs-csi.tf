
#AWS EBS CSI DRIVER
resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = var.eks_addon_version_ebs_csi_driver

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn = aws_iam_role.ebs_csi_controller_role.arn
  preserve = true

  tags = {
    "eks_addon" = "aws-ebs-csi-driver"
  }
  depends_on = [
    module.self_managed_node_group
  ] 
}

resource "aws_iam_role" "ebs_csi_controller_role" {
  name = "ebs-csi-controller-role"

  assume_role_policy = templatefile("policies/oidc_assume_role_policy.json", {
    OIDC_ARN  = aws_iam_openid_connect_provider.oidc_provider.arn,
    OIDC_URL  = replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", ""),
    NAMESPACE = "kube-system",
    SA_NAME   = "ebs-csi-controller-sa"
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
}
