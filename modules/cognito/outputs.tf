output "user_pool_id" {
  value = aws_cognito_user_pool.argocd.id
}

output "issuer_url" {
  value = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.argocd.id}"
}

output "cognito_domain" {
  value = "https://${var.cognito_domain_prefix}.auth.${data.aws_region.current.name}.amazoncognito.com"
}

# Custom ArgoCD client
output "custom_client_id" {
  value = aws_cognito_user_pool_client.argocd_custom.id
}

output "custom_client_secret" {
  value     = aws_cognito_user_pool_client.argocd_custom.client_secret
  sensitive = true
}

# Managed ArgoCD client
output "managed_client_id" {
  value = var.enable_managed_argocd ? aws_cognito_user_pool_client.argocd_managed[0].id : ""
}

output "managed_client_secret" {
  value     = var.enable_managed_argocd ? aws_cognito_user_pool_client.argocd_managed[0].client_secret : ""
  sensitive = true
}

data "aws_region" "current" {}
