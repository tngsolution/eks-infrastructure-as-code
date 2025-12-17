# Security group rules for SSH access from public subnets to worker nodes
# COMMENTED OUT - SSH access is now configured via remote_access block in node_groups.tf

# # Get the node security group created by the node group
# data "aws_security_groups" "node_sg" {
#   filter {
#     name   = "tag:aws:eks:cluster-name"
#     values = [var.cluster_name]
#   }
#   
#   filter {
#     name   = "tag-key"
#     values = ["aws:eks:nodegroup-name"]
#   }
# }

# # Allow SSH from public subnet CIDR blocks to nodes
# resource "aws_security_group_rule" "public_to_nodes_ssh" {
#   count             = length(local.public_subnet_ids) > 0 ? length(data.aws_subnet.public) : 0
#   type              = "ingress"
#   from_port         = 22
#   to_port           = 22
#   protocol          = "tcp"
#   security_group_id = tolist(data.aws_security_groups.node_sg.ids)[0]
#   cidr_blocks       = [data.aws_subnet.public[keys(data.aws_subnet.public)[count.index]].cidr_block]
#   description       = "Allow SSH from public subnet to EKS nodes"
#   
#   depends_on = [aws_eks_node_group.spot]
# }
