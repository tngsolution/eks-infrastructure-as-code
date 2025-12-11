/*
  ECR repository and VPC endpoints for private clusters
  - Creates an ECR repo (optional)
  - Creates a security group for interface endpoints
  - Creates Interface Endpoints for ECR API, ECR DKR and STS
  - Creates a Gateway Endpoint for S3 when route table ids are available
*/

locals {
  # route table ids: prefer explicit variable, otherwise try vpc_scan_output
  _s3_route_table_ids = length(var.s3_route_table_ids) > 0 ? var.s3_route_table_ids : try(local.vpc_config.route_table_ids, [])
  _vpc_id             = var.vpc_id != "" ? var.vpc_id : try(local.vpc_config.vpc_id, null)
}

resource "aws_ecr_repository" "app" {
  count = var.create_ecr ? 1 : 0

  name                 = var.ecr_repository_name != "" ? var.ecr_repository_name : "${var.cluster_name}-app"
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }
  tags = merge(local.common_tags, var.tags)
}

resource "aws_security_group" "vpce_sg" {
  count       = var.create_vpc_endpoints ? 1 : 0
  name        = "${var.cluster_name}-vpce-sg"
  description = "Security group for VPC interface endpoints (ECR/STS)"
  vpc_id      = local._vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_vpc_endpoint" "ecr_api" {
  count              = var.create_vpc_endpoints && local._vpc_id != null ? 1 : 0
  vpc_id             = local._vpc_id
  service_name       = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = local.private_subnet_ids
  security_group_ids = [aws_security_group.vpce_sg[0].id]
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  count              = var.create_vpc_endpoints && local._vpc_id != null ? 1 : 0
  vpc_id             = local._vpc_id
  service_name       = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = local.private_subnet_ids
  security_group_ids = [aws_security_group.vpce_sg[0].id]
}

resource "aws_vpc_endpoint" "sts" {
  count              = var.create_vpc_endpoints && local._vpc_id != null ? 1 : 0
  vpc_id             = local._vpc_id
  service_name       = "com.amazonaws.${var.region}.sts"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = local.private_subnet_ids
  security_group_ids = [aws_security_group.vpce_sg[0].id]
}

# Gateway endpoint for S3 requires route table ids
resource "aws_vpc_endpoint" "s3" {
  count             = var.create_vpc_endpoints && length(local._s3_route_table_ids) > 0 && local._vpc_id != null ? 1 : 0
  vpc_id            = local._vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = local._s3_route_table_ids
}

/*
  Outputs for convenience
*/
output "ecr_repository_url" {
  value       = var.create_ecr && length(aws_ecr_repository.app) > 0 ? aws_ecr_repository.app[0].repository_url : ""
  description = "URL of the created ECR repository (empty if not created)"
}

output "vpc_endpoints_created" {
  value = {
    ecr_api = length(aws_vpc_endpoint.ecr_api) > 0 ? aws_vpc_endpoint.ecr_api[0].id : null
    ecr_dkr = length(aws_vpc_endpoint.ecr_dkr) > 0 ? aws_vpc_endpoint.ecr_dkr[0].id : null
    sts     = length(aws_vpc_endpoint.sts) > 0 ? aws_vpc_endpoint.sts[0].id : null
    s3      = length(aws_vpc_endpoint.s3) > 0 ? aws_vpc_endpoint.s3[0].id : null
  }
  description = "IDs of created VPC endpoints (null entries mean not created)"
}
