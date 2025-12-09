resource "aws_security_group" "eks_control_plane" {
  name   = "${var.cluster_name}-eks-control-plane-sg"
  vpc_id = length(var.vpc_id) > 0 ? var.vpc_id : local.vpc_config.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = length(keys(var.tags)) > 0 ? merge(local.common_tags, var.tags) : local.common_tags
}

resource "aws_security_group" "eks_nodes" {
  name   = "${var.cluster_name}-private-sg"
  vpc_id = length(var.vpc_id) > 0 ? var.vpc_id : local.vpc_config.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_control_plane.id]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = length(keys(var.tags)) > 0 ? merge(local.common_tags, var.tags) : local.common_tags
}

resource "aws_security_group" "alb_public" {
  name   = "${var.cluster_name}-public-sg"
  vpc_id = length(var.vpc_id) > 0 ? var.vpc_id : local.vpc_config.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  tags = length(keys(var.tags)) > 0 ? merge(local.common_tags, var.tags) : local.common_tags
}
