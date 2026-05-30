resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = var.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = var.ebs_csi_role_arn

  depends_on = [var.node_group_dependency]
}

resource "aws_eks_addon" "s3_csi" {
  cluster_name             = var.cluster_name
  addon_name               = "aws-mountpoint-s3-csi-driver"
  service_account_role_arn = var.s3_csi_role_arn

  depends_on = [var.node_group_dependency]
}
