variable "user_pool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
  default     = "argocd-sso"
}

variable "argocd_hostname" {
  description = "ArgoCD custom instance hostname"
  type        = string
}

variable "argocd_managed_hostname" {
  description = "ArgoCD managed instance hostname"
  type        = string
  default     = ""
}

variable "enable_managed_argocd" {
  description = "Whether to create a client for managed ArgoCD"
  type        = bool
  default     = false
}

variable "cognito_domain_prefix" {
  description = "Cognito hosted UI domain prefix (must be globally unique)"
  type        = string
}

variable "admin_email" {
  description = "Email for the initial ArgoCD admin user"
  type        = string
}

variable "admin_name" {
  description = "Display name for the initial admin user"
  type        = string
  default     = "Admin"
}

variable "admin_password" {
  description = "Password for the initial ArgoCD admin user"
  type        = string
  sensitive   = true
}
