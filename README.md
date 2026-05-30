# EKS + Dual ArgoCD with Cognito SSO (Shared ALB)

Deploy two isolated ArgoCD instances on EKS with AWS Cognito OIDC SSO — fully automated via Terraform.

![Architecture](https://jaya-devto-blog-assets.s3.us-east-1.amazonaws.com/argocd-cognito-sso/cover-argocd-cognito-architecture.png)

## What This Does

- **Custom ArgoCD** → `argocd.jayakrishnayadav.cloud` (namespace: `argocd`)
- **Managed ArgoCD** → `argocd2.jayakrishnayadav.cloud` (namespace: `argocd-managed`)
- **Shared ALB** — both instances behind one ALB with host-based routing
- **Cognito SSO** — single login for both instances, no shared admin passwords
- **Toggle** — `enable_managed_argocd = true/false` to control second instance
- **Zero manual steps** — user, password, group, OIDC config all via Terraform

## Architecture

```
Developer → ALB (shared, HTTPS) → ArgoCD 1 (argocd ns)
                                → ArgoCD 2 (argocd-managed ns)

Both ←── OIDC ──→ Cognito User Pool (ArgoCDAdmins group → role:admin)
```

## Screenshots

### Cognito User Pool with App Clients
![Cognito User Pool](https://jaya-devto-blog-assets.s3.us-east-1.amazonaws.com/argocd-cognito-sso/cognito-user-pool-overview.png)

### ArgoCD Login Page with Cognito SSO Button
![ArgoCD Login](https://jaya-devto-blog-assets.s3.us-east-1.amazonaws.com/argocd-cognito-sso/argocd-login-page.png)

### Cognito Hosted UI Login
![Cognito Login](https://jaya-devto-blog-assets.s3.us-east-1.amazonaws.com/argocd-cognito-sso/cognito-hosted-ui-login.png)

### ArgoCD Dashboard After SSO Login
![Dashboard](https://jaya-devto-blog-assets.s3.us-east-1.amazonaws.com/argocd-cognito-sso/argocd-dashboard-logged-in.png)

![Dashboard](https://jaya-devto-blog-assets.s3.us-east-1.amazonaws.com/argocd-cognito-sso/argocd-dashboard-logged-in2.png)

### ALB Listener Rules (Host-Based Routing)
![ALB Rules](https://jaya-devto-blog-assets.s3.us-east-1.amazonaws.com/argocd-cognito-sso/alb-listener-rules.png)

### kubectl Showing Shared ALB for Both Ingresses
![kubectl ingress](https://jaya-devto-blog-assets.s3.us-east-1.amazonaws.com/argocd-cognito-sso/kubectl-ingress-shared-alb.png)

## Project Structure

```
├── eks/
│   ├── main.tf              # Root module wiring
│   ├── variables.tf         # All variable declarations
│   ├── providers.tf         # AWS, Helm, Kubernetes providers
│   └── backend.tf           # State backend config
├── modules/
│   ├── vpc/                 # VPC + subnets
│   ├── iam/                 # IAM roles (EKS, nodes, CSI)
│   ├── eks-cluster/         # EKS control plane
│   ├── eks-nodes/           # Managed node group
│   ├── csi-driver/          # EBS + S3 CSI drivers
│   ├── aws-load-balancer-controller/  # ALB controller
│   ├── cognito/             # Cognito User Pool + clients + admin user
│   ├── argocd/              # Custom ArgoCD (Helm + ALB + OIDC)
│   └── argocd-managed/      # Managed ArgoCD (CRDs skipped)
└── environments/
    └── dev/
        ├── terraform.tfvars.example  # Example values (safe to commit)
        └── backend.hcl              # Backend config
```

## Quick Start

```bash
cd eks/

# Copy and fill in your values
cp ../environments/dev/terraform.tfvars.example ../environments/dev/terraform.tfvars

terraform init -backend-config=../environments/dev/backend.hcl
terraform apply -var-file=../environments/dev/terraform.tfvars
```

## Configuration

```hcl
# ArgoCD settings
argocd_hostname         = "argocd.example.com"
argocd_managed_hostname = "argocd2.example.com"
enable_managed_argocd   = true
cognito_domain_prefix   = "your-unique-prefix"
argocd_admin_email      = "admin@example.com"
argocd_admin_password   = "YourSecurePass1"
argocd_chart_version    = "7.8.13"
```

## After Deployment

1. Get the ALB hostname:
   ```bash
   kubectl get ingress -A | grep argocd
   ```

2. Point your DNS (CNAME) to the ALB hostname:
   - `argocd.example.com` → ALB
   - `argocd2.example.com` → ALB

3. Login via Cognito SSO with the email/password you set in tfvars.

## Key Decisions

| Decision | Why |
|----------|-----|
| Cognito over Identity Center | 100% Terraform-automatable |
| Shared ALB via ingress group | Cost optimization — one ALB, host-based routing |
| `crds.install = false` on 2nd instance | CRDs are cluster-scoped, can't install twice |
| Dex disabled | Direct OIDC to Cognito, no broker needed |
| `server.insecure = true` | ALB handles TLS, internal traffic is HTTP |

## RBAC

Users in `ArgoCDAdmins` Cognito group get `role:admin`. Everyone else gets `role:readonly`.

```
policy.csv:     "g, ArgoCDAdmins, role:admin"
policy.default: "role:readonly"
scopes:         "[cognito:groups, email]"
```

## Blog Post

Full writeup with explanations: [Running Two ArgoCD Instances on EKS with Cognito SSO](https://dev.to/jayakrishnayadav)

## License

MIT
