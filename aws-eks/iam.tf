
# #AWS EBS CSI DRIVER Role
resource "aws_iam_role" "ebs_csi_controller_role" {
  name = "ebs-csi-controller-role"

  assume_role_policy = templatefile("policies/oidc_assume_role_policy.json", {
    OIDC_ARN  = module.eks.oidc_provider_arn,
    OIDC_URL  = module.eks.oidc_provider,
    NAMESPACE = "kube-system",
    SA_NAME   = "ebs-csi-controller-sa"
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"]
}
