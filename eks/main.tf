module "vpc" {
  source = "../modules/vpc"

  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  cluster_name         = var.cluster_name
}

module "eks_cluster" {
  source = "../modules/eks-cluster"

  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  cluster_role_arn   = module.iam.eks_cluster_role_arn
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
}

module "iam" {
  source = "../modules/iam"

  cluster_name      = var.cluster_name
  oidc_provider_arn = module.eks_cluster.oidc_provider_arn
  oidc_provider     = module.eks_cluster.oidc_provider
}

module "eks_nodes" {
  source = "../modules/eks-nodes"

  cluster_name    = module.eks_cluster.cluster_id
  node_group_name = var.node_group_name
  node_role_arn   = module.iam.eks_nodes_role_arn
  subnet_ids      = module.vpc.private_subnet_ids
  instance_types  = var.instance_types
  desired_size    = var.desired_size
  max_size        = var.max_size
  min_size        = var.min_size
  labels          = var.node_labels

  depends_on = [module.eks_cluster]
}

module "csi_driver" {
  source = "../modules/csi-driver"

  cluster_name          = module.eks_cluster.cluster_id
  ebs_csi_role_arn      = module.iam.ebs_csi_driver_role_arn
  s3_csi_role_arn       = var.s3_csi_role_arn
  node_group_dependency = module.eks_nodes
}

# vpc-cni versions tried:
# v1.18.1-eksbuild.1 — original, not supported on k8s 1.35
# v1.21.1-eksbuild.5 — latest from describe-addon-versions, still rejected
# v1.21.1-eksbuild.1 — default version, still rejected
resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = module.eks_cluster.cluster_id
  addon_name                  = "vpc-cni"
  addon_version               = "v1.21.1-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [module.eks_nodes]
}

# coredns versions tried:
# v1.11.1-eksbuild.8 — original, not supported on k8s 1.35
# v1.13.2-eksbuild.3 — default from describe-addon-versions, still rejected
resource "aws_eks_addon" "coredns" {
  cluster_name                = module.eks_cluster.cluster_id
  addon_name                  = "coredns"
  addon_version               = "v1.13.2-eksbuild.3"
  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [module.eks_nodes]
}

# kube-proxy versions tried:
# v1.33.5-eksbuild.2 — original, not supported on k8s 1.35
# v1.35.2-eksbuild.4 — latest from describe-addon-versions
# v1.35.0-eksbuild.2 — default from describe-addon-versions
resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = module.eks_cluster.cluster_id
  addon_name                  = "kube-proxy"
  addon_version               = "v1.35.2-eksbuild.4"
  resolve_conflicts_on_create = "OVERWRITE"

  depends_on = [module.eks_nodes]
}


module "aws_load_balancer_controller" {
  source = "../modules/aws-load-balancer-controller"

  cluster_name      = var.cluster_name
  oidc_provider_arn = module.eks_cluster.oidc_provider_arn
  oidc_provider     = module.eks_cluster.oidc_provider
  aws_region        = var.aws_region
  vpc_id            = module.vpc.vpc_id
  chart_version     = var.aws_load_balancer_controller_version

  depends_on = [module.eks_nodes]
}


# Get current AWS identity
data "aws_caller_identity" "current" {}

# ─── Cognito (shared by both ArgoCD instances) ──────────────────────────────
module "cognito" {
  source = "../modules/cognito"

  count = var.argocd_hostname != "" ? 1 : 0

  user_pool_name          = "argocd-sso"
  argocd_hostname         = var.argocd_hostname
  argocd_managed_hostname = var.argocd_managed_hostname
  enable_managed_argocd   = var.enable_managed_argocd
  cognito_domain_prefix   = var.cognito_domain_prefix
  admin_email             = var.argocd_admin_email
  admin_password          = var.argocd_admin_password
}

# ─── Custom ArgoCD (always deployed when hostname is set) ────────────────
module "argocd" {
  source = "../modules/argocd"

  count = var.argocd_hostname != "" ? 1 : 0

  argocd_hostname       = var.argocd_hostname
  acm_certificate_arn   = var.acm_certificate_arn
  cognito_issuer_url    = module.cognito[0].issuer_url
  cognito_client_id     = module.cognito[0].custom_client_id
  cognito_client_secret = module.cognito[0].custom_client_secret
  cognito_domain        = module.cognito[0].cognito_domain
  argocd_chart_version  = var.argocd_chart_version

  depends_on = [module.aws_load_balancer_controller, module.cognito]
}

# ─── Managed ArgoCD (deployed only when enabled) ───────────────────────
module "argocd_managed" {
  source = "../modules/argocd-managed"

  count = var.enable_managed_argocd ? 1 : 0

  argocd_hostname       = var.argocd_managed_hostname
  acm_certificate_arn   = var.acm_certificate_arn
  cognito_issuer_url    = module.cognito[0].issuer_url
  cognito_client_id     = module.cognito[0].managed_client_id
  cognito_client_secret = module.cognito[0].managed_client_secret
  cognito_domain        = module.cognito[0].cognito_domain
  argocd_chart_version  = var.argocd_chart_version

  depends_on = [module.aws_load_balancer_controller, module.cognito, module.argocd]
}