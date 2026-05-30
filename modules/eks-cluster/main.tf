resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = var.cluster_role_arn

  vpc_config {
    #subnet_ids = concat(var.private_subnet_ids, var.public_subnet_ids)
    subnet_ids = var.private_subnet_ids
  }

  # Enable API authentication mode for EKS 1.33+
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [var.cluster_role_arn]
}

data "tls_certificate" "cluster" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer

  tags = {
    Name = "${var.cluster_name}-oidc"
  }
}
