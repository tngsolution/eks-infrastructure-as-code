resource "aws_eks_cluster" "tngs_eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids = length(var.private_subnet_ids) > 0 ? var.private_subnet_ids : local.private_subnet_ids
    security_group_ids = [
      aws_security_group.eks_control_plane.id
    ]
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  # Optionnel : tags (merge des tags locaux et des tags fournis via variables)
  tags = length(keys(var.tags)) > 0 ? merge(local.common_tags, var.tags) : local.common_tags
}

# IAM role pour le cluster
# resource "aws_iam_role" "eks_cluster" {
#   name = "eks-cluster-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "eks.amazonaws.com"
#         }
#       }
#     ]
#   })
#   tags = local.common_tags
# }

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSVPCResourceController" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}
