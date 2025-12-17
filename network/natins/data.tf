data "aws_vpc" "selected" {
  count = local._vpc_id != null ? 1 : 0
  id    = local._vpc_id
}

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

# Route53 DNS record for NAT instance

data "aws_route53_zone" "main" {
  count        = var.create_dns_record && var.route53_zone_id == "" && var.route53_zone_name != "" ? 1 : 0
  name         = var.route53_zone_name
  private_zone = false
}
