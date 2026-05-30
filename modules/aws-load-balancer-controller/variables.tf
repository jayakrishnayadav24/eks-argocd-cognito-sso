variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  type        = string
}

variable "oidc_provider" {
  description = "OIDC provider URL without https://"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the cluster is deployed"
  type        = string
}

variable "chart_version" {
  description = "Version of the AWS Load Balancer Controller Helm chart"
  type        = string
  default     = "1.6.2"
}