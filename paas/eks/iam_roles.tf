# -------------------------------------------
# Rôle pour le cluster EKS
# -------------------------------------------
data "aws_iam_policy_document" "eks_cluster_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_cluster" {
  name               = "${var.cluster_name}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role_policy.json
  tags               = merge(local.common_tags, var.tags)
}

resource "aws_iam_role_policy_attachment" "eks_cluster_managed" {
  for_each   = toset(var.cluster_managed_policy_arns)
  role       = aws_iam_role.eks_cluster.name
  policy_arn = each.value
}

# -------------------------------------------
# Rôle Karpenter IRSA (Pod Identity)
# -------------------------------------------
# data "aws_iam_openid_connect_provider" "eks" {
#   url = aws_eks_cluster.tngs_eks.identity[0].oidc[0].issuer
# }

# data "aws_iam_policy_document" "karpenter_assume_role_policy" {
#   statement {
#     effect = "Allow"
#     principals {
#       type        = "Federated"
#       identifiers = [data.aws_iam_openid_connect_provider.eks.arn]
#     }
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_eks_cluster.tngs_eks.identity[0].oidc[0].issuer, "https://", "")}:sub"
#       values   = ["system:serviceaccount:karpenter:karpenter"]
#     }
#   }
# }

# resource "aws_iam_role" "karpenter_controller" {
#   name               = "${var.cluster_name}-karpenter-controller"
#   assume_role_policy = data.aws_iam_policy_document.karpenter_assume_role_policy.json
#   tags               = merge(local.common_tags, var.tags)
# }

# resource "aws_iam_role_policy_attachment" "karpenter_managed" {
#   for_each   = toset(var.karpenter_managed_policy_arns)
#   role       = aws_iam_role.karpenter_controller.name
#   policy_arn = each.value
# }

# -------------------------------------------
# Instance profile pour les nœuds Karpenter (EC2)
# -------------------------------------------
# data "aws_iam_policy_document" "karpenter_node_assume_role" {
#   statement {
#     effect = "Allow"
#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }
#     actions = ["sts:AssumeRole"]
#   }
# }

# resource "aws_iam_role" "karpenter_node_role" {
#   name               = "${var.cluster_name}-karpenter-node-role"
#   assume_role_policy = data.aws_iam_policy_document.karpenter_node_assume_role.json
#   tags               = merge(local.common_tags, var.tags)
# }

# resource "aws_iam_instance_profile" "karpenter_node_profile" {
#   name = "${var.cluster_name}-karpenter-node-profile"
#   role = aws_iam_role.karpenter_node_role.name
# }
