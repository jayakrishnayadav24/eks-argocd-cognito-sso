variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "ebs_csi_role_arn" {
  description = "IAM role ARN for EBS CSI driver"
  type        = string
}

variable "s3_csi_role_arn" {
  description = "IAM role ARN for S3 CSI driver"
  type        = string
}

variable "node_group_dependency" {
  description = "Node group dependency to ensure nodes exist first"
  type        = any
}
