bucket         = "your-terraform-state-buckets2"
key            = "eks-argocd/dev4/terraform.tfstate"
region         = "ap-south-1"
#dynamodb_table = "terraform-state-lock"
encrypt        = true
use_lockfile =true
profile = "own"
