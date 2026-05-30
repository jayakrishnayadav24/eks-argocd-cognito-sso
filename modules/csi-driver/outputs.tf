output "ebs_csi_addon_id" {
  description = "EBS CSI addon ID"
  value       = aws_eks_addon.ebs_csi.id
}

output "s3_csi_addon_id" {
  description = "S3 CSI addon ID"
  value       = aws_eks_addon.s3_csi.id
}
