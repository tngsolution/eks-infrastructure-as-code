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

variable "instance_type" {
  description = "EC2 instance type for NAT instance"
  type        = string
  default     = "t3.nano"
}

variable "ami_id" {
  description = "AMI ID for NAT instance (leave empty for latest Amazon Linux 2023)"
  type        = string
  default     = ""
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs (NAT instance will be deployed in first one)"
  type        = list(string)
  default     = []
}

variable "private_route_table_ids" {
  description = "List of private route table IDs to update with NAT instance routes"
  type        = list(string)
  default     = []
}

variable "subnet_filter_tags" {
  description = "Tags to filter public subnets for auto-discovery"
  type        = map(string)
  default = {
    Tier = "Public"
  }
}

variable "route_table_filter_tags" {
  description = "Tags to filter private route tables for auto-discovery"
  type        = map(string)
  default = {
    Tier = "Private"
  }
}

variable "create_routes" {
  description = "Whether to create routes in private route tables"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair to use for the NAT instance"
  type        = string
  default     = "tngs-fr-admin"
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into the NAT instance (your public IP)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID where NAT instance will be deployed"
  type        = string
  default     = ""
}

variable "vpc_scan_file" {
  description = "Path to VPC scan output JSON file"
  type        = string
  default     = "../../vpc_scan_output/data.json"
}

variable "route53_zone_name" {
  description = "Route53 hosted zone name (e.g., ccak.fr)"
  type        = string
  default     = ""
}

variable "route53_zone_id" {
  description = "ID de la hosted zone Route53 (prioritaire sur le nom si renseigné)"
  type        = string
  default     = ""
}

variable "create_dns_record" {
  description = "Whether to create Route53 DNS record for NAT instance"
  type        = bool
  default     = false
}

variable "private_subnet_cidrs" {
  description = "Liste des CIDR des subnets privés pour la configuration NAT"
  type        = list(string)
  default     = []
}
