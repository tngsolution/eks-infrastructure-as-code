resource "aws_eks_cluster" "tngs_eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids = length(var.public_subnet_ids) > 0 ? var.public_subnet_ids : local.public_subnet_ids
    # security_group_ids = [
    #   local.eks_control_plane_sg_id
    # ]
    public_access_cidrs     = var.eks_cp_allow_cidr
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  # Active automatiquement la création de l’OIDC provider
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]


  # Tags: merge local.common_tags with var.tags
  tags = merge(local.common_tags, var.tags)
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
