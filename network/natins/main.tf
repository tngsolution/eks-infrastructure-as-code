/*
  NAT Instance deployment (Cost-optimized alternative to NAT Gateway)
  - Creates EC2 instance configured as NAT
  - Creates Elastic IP for the instance
  - Configures security group
  - Updates route tables for private subnets
*/

# Latest Amazon Linux 2023 AMI optimized for NAT
data "aws_ami" "amazon_linux_nat" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "nat_instance" {
  name        = "${var.name_prefix}-nat-instance-sg"
  description = "Security group for NAT instance"
  vpc_id      = local._vpc_id

  ingress {
    description = "Allow all from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.selected[0].cidr_block]
  }

  dynamic "ingress" {
    for_each = var.ssh_allowed_cidr != "" ? [1] : []
    content {
      description = "SSH from admin"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.ssh_allowed_cidr]
    }
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-nat-instance-sg"
    }
  )
}

resource "aws_eip" "nat_instance" {
  domain = "vpc"
  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-nat-instance-eip"
    }
  )
}

resource "aws_eip_association" "nat_instance" {
  instance_id   = aws_instance.nat.id
  allocation_id = aws_eip.nat_instance.id
}

resource "aws_instance" "nat" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_nat.id
  instance_type          = var.instance_type
  subnet_id              = local._public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.nat_instance.id]
  source_dest_check      = false # Critical for NAT functionality
  key_name               = var.ssh_key_name
  monitoring             = var.enable_monitoring # Enable detailed CloudWatch monitoring

  user_data = base64encode(templatefile("${path.module}/simple_nat_user_data.sh.tpl", {
    private_subnet_cidrs = join(" ", local.private_subnet_cidrs)
  }))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-nat-instance"
    }
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes = [ami]
  }
}

resource "aws_route" "private_nat_instance" {
  count                  = var.create_routes ? length(local._private_route_table_ids) : 0
  route_table_id         = local._private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat.primary_network_interface_id
}

resource "aws_route53_record" "nat_instance" {
  count   = var.create_dns_record && (var.route53_zone_id != "" || var.route53_zone_name != "") ? 1 : 0
  zone_id = var.route53_zone_id != "" ? var.route53_zone_id : data.aws_route53_zone.main[0].zone_id
  name    = "nat.${var.environment}.${var.route53_zone_name}"
  type    = "A"
  ttl     = 300
  records = [aws_eip.nat_instance.public_ip]
}
