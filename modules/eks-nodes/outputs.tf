output "node_group_arn" {
  description = "Amazon Resource Name (ARN) of the EKS Node Group"
  value       = aws_eks_node_group.nodes.arn
}

output "node_group_status" {
  description = "Status of the EKS Node Group"
  value       = aws_eks_node_group.nodes.status
}