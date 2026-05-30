# ─── Namespace ────────────────────────────────────────────────────────────────
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# ─── ArgoCD Helm Release ─────────────────────────────────────────────────────
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [yamlencode({
    global = {
      domain = var.argocd_hostname
    }

    dex = {
      enabled = false
    }

    configs = {
      params = {
        "server.insecure" = true
      }
      cm = {
        "url" = "https://${var.argocd_hostname}"
        "oidc.config" = yamlencode({
          name            = "Cognito"
          issuer          = var.cognito_issuer_url
          clientID        = var.cognito_client_id
          clientSecret    = "$oidc.cognito.clientSecret"
          requestedScopes = ["openid", "email", "profile"]
          logoutURL       = "${var.cognito_domain}/logout?client_id=${var.cognito_client_id}&logout_uri=https://${var.argocd_hostname}"
        })
      }
      secret = {
        extra = {
          "oidc.cognito.clientSecret" = var.cognito_client_secret
        }
      }
      rbac = {
        "policy.csv"     = "g, ArgoCDAdmins, role:admin"
        "policy.default" = "role:readonly"
        "scopes"         = "[cognito:groups, email]"
      }
    }

    server = {
      ingress = {
        enabled          = true
        controller       = "aws"
        ingressClassName = "alb"
        annotations = {
          "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
          "alb.ingress.kubernetes.io/target-type"      = "ip"
          "alb.ingress.kubernetes.io/certificate-arn"  = var.acm_certificate_arn
          "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTPS\":443}]"
          "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
          "alb.ingress.kubernetes.io/healthcheck-path" = "/healthz"
          "alb.ingress.kubernetes.io/group.name"       = "argocd"
        }
        hosts = [var.argocd_hostname]
        tls = [{
          hosts = [var.argocd_hostname]
        }]
      }
    }
  })]
}
