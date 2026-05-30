output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = aws_iam_role.eks_cluster.arn
}

output "eks_nodes_role_arn" {
  description = "ARN of the EKS node group IAM role"
  value       = aws_iam_role.eks_nodes.arn
}

output "ebs_csi_driver_role_arn" {
  description = "ARN of the EBS CSI driver IAM role"
  value       = aws_iam_role.ebs_csi_driver.arn
}