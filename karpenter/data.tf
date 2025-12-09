data "aws_eks_cluster" "tngs_eks" {
  name = aws_eks_cluster.tngs_eks.name
}

data "aws_eks_cluster_auth" "tngs_eks" {
  name = aws_eks_cluster.tngs_eks.name
}
