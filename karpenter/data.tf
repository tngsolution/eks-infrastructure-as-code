data "aws_eks_cluster" "tngs_eks" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "tngs_eks" {
  name = var.cluster_name
}
