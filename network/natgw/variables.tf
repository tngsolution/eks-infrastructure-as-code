variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "eks"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-3"
}

variable "environment" {
  description = "Environment name (dev, stg, prd, etc.)"
  type        = string
  default     = "dev"
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways to create (typically 1 for dev, 3 for prod across AZs)"
  type        = number
  default     = 1

  validation {
    condition     = var.nat_gateway_count > 0 && var.nat_gateway_count <= 3
    error_message = "NAT Gateway count must be between 1 and 3"
  }
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs where NAT Gateways will be deployed (optional if using auto-discovery)"
  type        = list(string)
  default     = []
}

variable "private_route_table_ids" {
  description = "List of private route table IDs to update with NAT Gateway routes (optional if using auto-discovery)"
  type        = list(string)
  default     = []
}

variable "subnet_filter_tags" {
  description = "Tags to filter public subnets for auto-discovery (e.g., {Tier = 'Public'})"
  type        = map(string)
  default     = {
    Tier = "Public"
  }
}

variable "route_table_filter_tags" {
  description = "Tags to filter private route tables for auto-discovery (e.g., {Tier = 'Private'})"
  type        = map(string)
  default     = {
    Tier = "Private"
  }
}

variable "internet_gateway_id" {
  description = "ID of the Internet Gateway (for dependency management)"
  type        = string
  default     = null
}

variable "create_routes" {
  description = "Whether to create routes in private route tables"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID where NAT Gateway will be deployed"
  type        = string
  default     = ""
}

variable "vpc_scan_file" {
  description = "Path to VPC scan output JSON file"
  type        = string
  default     = "../../vpc_scan_output/data.json"
}
