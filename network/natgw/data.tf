/*
  Data sources for NAT Gateway deployment
*/

# Fetch VPC information if VPC ID is provided
data "aws_vpc" "selected" {
  count = local._vpc_id != null ? 1 : 0
  id    = local._vpc_id
}

# Fetch Internet Gateway for the VPC
data "aws_internet_gateway" "main" {
  count = local._vpc_id != null ? 1 : 0

  filter {
    name   = "attachment.vpc-id"
    values = [local._vpc_id]
  }
}

# Auto-discover public subnets by tags if not explicitly provided
data "aws_subnets" "public" {
  count = length(var.public_subnet_ids) == 0 && local._vpc_id != null ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [local._vpc_id]
  }

  dynamic "filter" {
    for_each = var.subnet_filter_tags
    content {
      name   = "tag:${filter.key}"
      values = [filter.value]
    }
  }
}

# Auto-discover private route tables by tags if not explicitly provided
data "aws_route_tables" "private" {
  count = length(var.private_route_table_ids) == 0 && local._vpc_id != null ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [local._vpc_id]
  }

  dynamic "filter" {
    for_each = var.route_table_filter_tags
    content {
      name   = "tag:${filter.key}"
      values = [filter.value]
    }
  }
}
