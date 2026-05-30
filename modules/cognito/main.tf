# ─── Cognito User Pool ────────────────────────────────────────────────────────
resource "aws_cognito_user_pool" "argocd" {
  name = var.user_pool_name

  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    required            = true
    mutable             = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }
}

# ─── Cognito Domain (Hosted UI) ──────────────────────────────────────────────
resource "aws_cognito_user_pool_domain" "argocd" {
  domain       = var.cognito_domain_prefix
  user_pool_id = aws_cognito_user_pool.argocd.id
}

# ─── App Client: Custom ArgoCD ───────────────────────────────────────────────
resource "aws_cognito_user_pool_client" "argocd_custom" {
  name         = "argocd-custom"
  user_pool_id = aws_cognito_user_pool.argocd.id

  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  supported_identity_providers         = ["COGNITO"]

  callback_urls = ["https://${var.argocd_hostname}/auth/callback", "https://${var.argocd_hostname}/api/dex/callback"]
  logout_urls   = ["https://${var.argocd_hostname}"]

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]
}

# ─── App Client: Managed ArgoCD ──────────────────────────────────────────────
resource "aws_cognito_user_pool_client" "argocd_managed" {
  count = var.enable_managed_argocd ? 1 : 0

  name         = "argocd-managed"
  user_pool_id = aws_cognito_user_pool.argocd.id

  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  supported_identity_providers         = ["COGNITO"]

  callback_urls = ["https://${var.argocd_managed_hostname}/auth/callback", "https://${var.argocd_managed_hostname}/api/dex/callback"]
  logout_urls   = ["https://${var.argocd_managed_hostname}"]

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]
}

# ─── Admin Group ─────────────────────────────────────────────────────────────
resource "aws_cognito_user_group" "admins" {
  name         = "ArgoCDAdmins"
  user_pool_id = aws_cognito_user_pool.argocd.id
  description  = "ArgoCD admin users"
}

# ─── Initial Admin User ──────────────────────────────────────────────────────
resource "aws_cognito_user" "admin" {
  user_pool_id = aws_cognito_user_pool.argocd.id
  username     = var.admin_email
  password     = var.admin_password

  attributes = {
    email          = var.admin_email
    name           = var.admin_name
    email_verified = true
  }

  lifecycle {
    ignore_changes = [attributes]
  }
}

# ─── Add Admin to Group ──────────────────────────────────────────────────────
resource "aws_cognito_user_in_group" "admin" {
  user_pool_id = aws_cognito_user_pool.argocd.id
  group_name   = aws_cognito_user_group.admins.name
  username     = aws_cognito_user.admin.username
}
