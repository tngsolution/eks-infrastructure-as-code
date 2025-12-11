# -------------------------------------------
# Rôle IAM pour Karpenter Controller (IRSA)
# -------------------------------------------
resource "aws_iam_role" "karpenter_controller" {
  name = "${var.cluster_name}-karpenter-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

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
