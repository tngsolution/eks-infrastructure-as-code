// Public subnets from vpc_scan_output JSON
data "aws_subnet" "public" {
  for_each = {
    for s in try(local.vpc_config.subnets, []) : s.subnet_id => s
    if try(strcontains(s.tags.Name, "public"), false)
  }
  id = each.key
}

// Private subnets from vpc_scan_output JSON
data "aws_subnet" "private" {
  for_each = {
    for s in try(local.vpc_config.subnets, []) : s.subnet_id => s
    if try(strcontains(s.tags.Name, "private"), false)
  }
  id = each.key
}

data "aws_eks_cluster_auth" "tngs_eks" {
  name = aws_eks_cluster.tngs_eks.name
}

# data "aws_security_groups" "eks_control_plane" {
#   filter {
#     name   = "group-name"
#     values = ["eks-${var.cluster_name}-cluster-sg*"]
#   }
# }

