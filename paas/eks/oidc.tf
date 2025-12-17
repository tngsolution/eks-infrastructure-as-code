# Get the TLS certificate from the EKS OIDC issuer
data "tls_certificate" "eks" {
  url = aws_eks_cluster.tngs_eks.identity[0].oidc[0].issuer
}

# Create the OIDC provider for the EKS cluster
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.tngs_eks.identity[0].oidc[0].issuer
  
    # Tags: merge local.common_tags with var.tags
  tags = merge(local.common_tags, var.tags, {
    Name = "${var.cluster_name}-oidc-provider"
  })
}
