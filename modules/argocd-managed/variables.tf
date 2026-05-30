variable "argocd_hostname" {
  description = "Hostname for managed ArgoCD (e.g., argocd2.jayakrishnayadav.cloud)"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS on ALB"
  type        = string
}

variable "cognito_issuer_url" {
  description = "Cognito OIDC issuer URL"
  type        = string
}

variable "cognito_client_id" {
  description = "Cognito app client ID"
  type        = string
}

variable "cognito_client_secret" {
  description = "Cognito app client secret"
  type        = string
  sensitive   = true
}

variable "cognito_domain" {
  description = "Cognito hosted UI domain URL"
  type        = string
}

variable "argocd_chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "7.8.13"
}
