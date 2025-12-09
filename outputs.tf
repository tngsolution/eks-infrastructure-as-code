output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.tngs_eks.name
}

output "eks_cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.tngs_eks.arn
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS cluster API server"
  value       = aws_eks_cluster.tngs_eks.endpoint
}

output "eks_cluster_version" {
  description = "Kubernetes version of the cluster"
  value       = aws_eks_cluster.tngs_eks.version
}

output "eks_control_plane_sg_id" {
  description = "Security group ID for the EKS control plane"
  value       = aws_security_group.eks_control_plane.id
}

output "eks_nodes_sg_id" {
  description = "Security group ID for EKS worker nodes"
  value       = aws_security_group.eks_nodes.id
}

output "alb_public_sg_id" {
  description = "Security group ID for public ALB"
  value       = aws_security_group.alb_public.id
}

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.tngs_eks.certificate_authority[0].data
  sensitive   = true
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = try(aws_eks_cluster.tngs_eks.identity[0].oidc[0].issuer, "")
}

output "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  value       = aws_iam_role.eks_cluster.arn
}

output "karpenter_role_arn" {
  description = "ARN of the Karpenter controller IAM role (empty if not created)"
  value       = length(aws_iam_role.karpenter_controller) > 0 ? aws_iam_role.karpenter_controller[0].arn : ""
}

output "karpenter_instance_profile_name" {
  description = "Karpenter instance profile name (empty if not created)"
  value       = length(aws_iam_instance_profile.karpenter_profile) > 0 ? aws_iam_instance_profile.karpenter_profile[0].name : ""
  sensitive   = true
}
