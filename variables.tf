variable "region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes control plane version"
  type        = string
  default     = "1.27"
}

variable "vpc_id" {
  description = "VPC id where the cluster will be created"
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for worker nodes"
  type        = list(string)
  default     = []
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs (for load balancers)"
  type        = list(string)
  default     = []
}

variable "node_group_instance_types" {
  description = "Instance types for node group(s)"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_group_desired_capacity" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 2
}

variable "node_group_min_capacity" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "node_group_max_capacity" {
  description = "Maximum number of nodes"
  type        = number
  default     = 3
}

variable "tags" {
  description = "Map of tags to apply to AWS resources"
  type        = map(string)
  default     = {}
}

variable "cluster_managed_policy_arns" {
  description = "List of managed policy ARNs to attach to the EKS cluster role"
  type        = list(string)
  default     = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
  ]
}

variable "karpenter_managed_policy_arns" {
  description = "List of managed policy ARNs to attach to the Karpenter controller role"
  type        = list(string)
  default     = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ]
}

variable "create_karpenter" {
  description = "Whether to create Karpenter IAM role and instance profile"
  type        = bool
  default     = true
}

variable "vpc_scan_file" {
  description = "Path to VPC scan output JSON file (generated locally via scan-account.py); .gitignored"
  type        = string
  default     = ""
}
