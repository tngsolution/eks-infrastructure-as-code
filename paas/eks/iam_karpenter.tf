# -------------------------------------------
# Trust policy for Karpenter Controller (IRSA with OIDC)
# -------------------------------------------
data "aws_iam_policy_document" "karpenter_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:karpenter:karpenter"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# -------------------------------------------
# Rôle IAM pour Karpenter Controller (IRSA)
# -------------------------------------------
resource "aws_iam_role" "karpenter_controller" {
  name               = "${var.cluster_name}-karpenter-controller"
  assume_role_policy = data.aws_iam_policy_document.karpenter_controller_assume_role_policy.json

  tags = merge(local.common_tags, var.tags)
}

resource "aws_iam_role_policy_attachment" "karpenter_controller_managed" {
  for_each   = toset(var.karpenter_managed_policy_arns)
  role       = aws_iam_role.karpenter_controller.name
  policy_arn = each.value
}

# -------------------------------------------
# Rôle IAM pour les nœuds EC2 Karpenter (instance profile)
# -------------------------------------------
resource "aws_iam_role" "karpenter_node_role" {
  name = "${var.cluster_name}-karpenter-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.common_tags, var.tags)
}

resource "aws_iam_instance_profile" "karpenter_node_profile" {
  name = "${var.cluster_name}-karpenter-node-profile"
  role = aws_iam_role.karpenter_node_role.name
}
