provider "kubernetes" {
  host                   = data.aws_eks_cluster.tngs_eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.tngs_eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.tngs_eks.token
}