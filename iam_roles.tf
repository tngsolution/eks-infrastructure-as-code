# Trust policy for EKS cluster role
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
  tags = length(keys(var.tags)) > 0 ? merge(local.common_tags, var.tags) : local.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_managed" {
  for_each  = toset(var.cluster_managed_policy_arns)
  role      = aws_iam_role.eks_cluster.name
  policy_arn = each.value
}

# Trust policy for Karpenter controller role
data "aws_iam_policy_document" "karpenter_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["karpenter.k8s.aws"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "karpenter_controller" {
  count              = var.create_karpenter ? 1 : 0
  name               = "${var.cluster_name}-karpenter-controller"
  assume_role_policy = data.aws_iam_policy_document.karpenter_assume_role_policy.json
  tags = length(keys(var.tags)) > 0 ? merge(local.common_tags, var.tags) : local.common_tags
}

resource "aws_iam_role_policy_attachment" "karpenter_managed" {
  for_each  = var.create_karpenter ? toset(var.karpenter_managed_policy_arns) : toset([])
  role      = aws_iam_role.karpenter_controller[0].name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "karpenter_profile" {
  count = var.create_karpenter ? 1 : 0
  name  = "${var.cluster_name}-karpenter-instance-profile"
  role  = aws_iam_role.karpenter_controller[0].name
}
