# Tag public subnets for Karpenter discovery (for load balancers)
resource "aws_ec2_tag" "public_subnet_karpenter" {
  for_each    = data.aws_subnet.public
  resource_id = each.key
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}

# Tag private subnets for Karpenter discovery (for worker nodes)
resource "aws_ec2_tag" "private_subnet_karpenter" {
  for_each    = data.aws_subnet.private
  resource_id = each.key
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}

# Tag security groups for Karpenter discovery
resource "aws_ec2_tag" "cluster_security_group_karpenter" {
  resource_id = aws_eks_cluster.tngs_eks.vpc_config[0].cluster_security_group_id
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}
