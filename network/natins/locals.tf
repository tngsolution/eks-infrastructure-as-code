locals {
  common_tags = merge(
    {
      Project     = "SAA-C02"
      ManagedBy   = "Terraform"
      Environment = var.environment
      Stack       = "nat-instance"
      Team        = "DEVOPS"
    },
    var.tags
  )

  vpc_config = var.vpc_id == "" && fileexists(var.vpc_scan_file) ? jsondecode(file(var.vpc_scan_file)) : null
  _vpc_id    = var.vpc_id != "" ? var.vpc_id : try(local.vpc_config.vpc_id, null)

  _public_subnet_ids = length(var.public_subnet_ids) > 0 ? var.public_subnet_ids : (
    length(data.aws_subnets.public) > 0 ? data.aws_subnets.public[0].ids : try(local.vpc_config.public_subnet_ids, [])
  )

  _private_route_table_ids = length(var.private_route_table_ids) > 0 ? var.private_route_table_ids : (
    length(data.aws_route_tables.private) > 0 ? data.aws_route_tables.private[0].ids : try(local.vpc_config.route_table_ids, [])
  )

  private_subnet_cidrs = var.private_subnet_cidrs
}
