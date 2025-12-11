variable "region" {
  description = "AWS region to create resources in"
  type        = string
  default     = "eu-west-3"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes control plane version"
  type        = string
  default     = "1.34"
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
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
  ]
}

variable "karpenter_managed_policy_arns" {
  description = "List of managed policy ARNs to attach to the Karpenter controller role"
  type        = list(string)
  default = [
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

variable "spot_instance_types" {
  description = "Instance types to use for Spot managed node group (cheap/spot-capable) - adjust according to availability in the target region"
  type        = list(string)
  default     = ["t3.small", "t3a.small"]
}

variable "create_ecr" {
  description = "Whether to create an ECR repository for application images"
  type        = bool
  default     = true
}

variable "ecr_repository_name" {
  description = "Name for the ECR repository (if empty a default name using cluster_name will be used)"
  type        = string
  default     = "tngs-eks-repo"
}

variable "create_vpc_endpoints" {
  description = "Whether to create VPC endpoints for ECR/STS and S3"
  type        = bool
  default     = true
}

variable "s3_route_table_ids" {
  description = "Optional list of route table ids to attach a Gateway endpoint for S3. If empty the module will try to read route table ids from vpc_scan_output JSON."
  type        = list(string)
  default     = []
}
variable "eks_cp_allow_cidr" {
  description = "Allow IP to access EKS control plane"
  type        = list(string)
  default     = []
}
