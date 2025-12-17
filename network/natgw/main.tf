/*
  NAT Gateway deployment
  - Creates Elastic IP(s) for NAT Gateway(s)
  - Creates NAT Gateway(s) in public subnet(s)
  - Optionally updates route tables for private subnets
*/

resource "aws_eip" "nat" {
  count  = var.nat_gateway_count
  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-nat-eip-${count.index + 1}"
    }
  )

  depends_on = [var.internet_gateway_id]
}

resource "aws_nat_gateway" "main" {
  count         = min(var.nat_gateway_count, length(local._public_subnet_ids))
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = local._public_subnet_ids[count.index]

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-nat-gw-${count.index + 1}"
    }
  )

  depends_on = [var.internet_gateway_id]
}

resource "aws_route" "private_nat_gateway" {
  count                  = var.create_routes ? length(local._private_route_table_ids) : 0
  route_table_id         = local._private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index % var.nat_gateway_count].id
}
