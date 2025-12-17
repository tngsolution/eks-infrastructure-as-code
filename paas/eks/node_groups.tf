/*
  Managed Spot Node Group
  - Uses Spot capacity_type for cheaper instances
  - Uses IAM role with recommended policies for worker nodes
  - Subnet selection falls back to local.private_subnet_ids
*/

data "aws_iam_policy_document" "node_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node_group_spot" {
  name               = "${var.cluster_name}-spot-node-role"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.node_group_spot.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.node_group_spot.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ECRReadOnly" {
  role       = aws_iam_role.node_group_spot.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.node_group_spot.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_eks_node_group" "spot" {
  cluster_name    = aws_eks_cluster.tngs_eks.name
  node_group_name = "${var.cluster_name}-spot-ng"
  node_role_arn   = aws_iam_role.node_group_spot.arn

  # Use private subnets for nodes (they will access Internet via NAT instance)
  subnet_ids = length(var.private_subnet_ids) > 0 ? var.private_subnet_ids : local.private_subnet_ids

  scaling_config {
    desired_size = var.node_group_desired_capacity
    max_size     = var.node_group_max_capacity
    min_size     = var.node_group_min_capacity
  }

  # Use Spot capacity type to save costs
  capacity_type = "SPOT"

  # Prefer small/cheap instance types by default (override via var.spot_instance_types)
  instance_types = var.spot_instance_types

  tags = merge(local.common_tags, var.tags, { "Name" = "${var.cluster_name}-spot" })

  # Enable SSH access to nodes
  remote_access {
    ec2_ssh_key               = var.ssh_key_name
    source_security_group_ids = compact([local.private_sg_id, local.nat_instance_sg_id])
  }

  # Ensure all dependencies are ready before creating the node group
  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_ECRReadOnly,
    aws_iam_role_policy_attachment.ssm,
    aws_eks_cluster.tngs_eks,
  ]
}
