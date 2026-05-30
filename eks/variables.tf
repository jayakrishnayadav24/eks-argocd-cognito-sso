variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile name"
  type        = string
  default     = "default"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.32"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
  default     = "private-nodes"
}

variable "instance_types" {
  description = "List of instance types"
  type        = list(string)
  default     = ["t3.large"]
}

variable "desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "node_labels" {
  description = "Key-value map of Kubernetes labels"
  type        = map(string)
  default = {
    role = "general"
  }
}

variable "ebs_csi_addon_version" {
  description = "Version of the EBS CSI addon"
  type        = string
  default     = "v1.19.0-eksbuild.2"
}

variable "istio_namespace" {
  description = "Kubernetes namespace for Istio"
  type        = string
  default     = "istio-system"
}

variable "istio_version" {
  description = "Version of Istio"
  type        = string
  default     = "1.17.1"
}

variable "istio_base_release_name" {
  description = "Name of the Istio base Helm release"
  type        = string
  default     = "istio-base"
}

variable "istiod_release_name" {
  description = "Name of the Istiod Helm release"
  type        = string
  default     = "istiod"
}

variable "istio_gateway_release_name" {
  description = "Name of the Istio gateway Helm release"
  type        = string
  default     = "istio-gateway"
}

variable "aws_load_balancer_controller_version" {
  description = "Version of the AWS Load Balancer Controller Helm chart"
  type        = string
  default     = "1.6.2"
}

variable "s3_csi_role_arn" {
  description = "IAM role ARN for S3 CSI driver"
  type        = string
}

variable "app_namespace" {
  description = "Kubernetes namespace for the application"
  type        = string
  default     = "production"
}

variable "app_image" {
  description = "Docker image for the application"
  type        = string
  default     = "rekhugopal/eksistiodemo:latest"
}

variable "app_replicas" {
  description = "Number of replicas per app version"
  type        = number
  default     = 1
}

variable "app_hostname" {
  description = "Hostname for the application"
  type        = string
}

variable "app2_hostname" {
  description = "Hostname for app2 (company IP restricted)"
  type        = string
  default     = ""
}

variable "ip_restricted_hostnames" {
  description = "Space-separated list of hostnames that require IP authorization at WAF level"
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
}

variable "acm_wildcard_arn" {
  description = "Wildcard ACM certificate ARN"
  type        = string
  default     = ""
}

variable "company_ip" {
  description = "Company IP routed to v2"
  type        = string
}

variable "allowed_cidrs" {
  description = "NGINX geo block: CIDR entries for allowed IPs (value 0 = allowed, default 1 = blocked)"
  type        = string
  default     = "10.0.0.0/8 0; 172.16.0.0/12 0; 192.168.0.0/16 0;"
}

variable "nginx_chart_version" {
  description = "NGINX Ingress Controller Helm chart version"
  type        = string
  default     = "4.10.1"
}

variable "maxmind_license_key" {
  description = "MaxMind GeoLite2 license key for country-based geo-blocking"
  type        = string
  sensitive   = true
  default     = ""
}

variable "allowed_countries" {
  description = "Comma-separated list of allowed country codes (e.g., 'IN,US,GB')"
  type        = string
  default     = "IN"
}

variable "grafana_hostname" {
  description = "Hostname for Grafana (IP restricted access)"
  type        = string
  default     = ""
}

variable "backend_hostname" {
  description = "Hostname for backend API (header authentication required)"
  type        = string
  default     = ""
}

variable "your_ip_address" {
  description = "Your IP address for Grafana access restriction"
  type        = string
  default     = ""
}

variable "backend_api_key" {
  description = "API key required for backend API access"
  type        = string
  sensitive   = true
  default     = ""
}

# ─── ArgoCD Variables ─────────────────────────────────────────────────────────
variable "argocd_hostname" {
  description = "Hostname for custom ArgoCD instance"
  type        = string
  default     = ""
}

variable "argocd_managed_hostname" {
  description = "Hostname for managed ArgoCD instance"
  type        = string
  default     = ""
}

variable "enable_managed_argocd" {
  description = "Enable the second (managed) ArgoCD instance"
  type        = bool
  default     = false
}

variable "cognito_domain_prefix" {
  description = "Cognito hosted UI domain prefix (globally unique)"
  type        = string
  default     = ""
}

variable "argocd_admin_email" {
  description = "Email for the initial ArgoCD admin user in Cognito"
  type        = string
  default     = ""
}

variable "argocd_admin_password" {
  description = "Password for the initial ArgoCD admin user in Cognito"
  type        = string
  sensitive   = true
  default     = ""
}

variable "argocd_chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "7.8.13"
}