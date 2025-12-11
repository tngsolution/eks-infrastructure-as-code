# resource "aws_security_group_rule" "eks_cp_allow_my_ip" {
#   type              = "ingress"
#   security_group_id = aws_security_group.eks_control_plane.id
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   cidr_blocks       = ["90.91.229.156/32"]
#   description       = "Allow Abdoul IP to access EKS control plane"
# }

# ----------------------------
# SG Nodes EKS
# ----------------------------
resource "aws_security_group" "eks_nodes" {
  name   = "${var.cluster_name}-nodes-sg"
  vpc_id = local.vpc_id

  # 1️⃣ Le control plane peut leur parler (443)
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_eks_cluster.tngs_eks.vpc_config[0].cluster_security_group_id]
  }

  # 2️⃣ Le kubelet accepte les appels des nodes eux-mêmes
  ingress {
    from_port = 10250
    to_port   = 10250
    protocol  = "tcp"
    self      = true
  }

  # 3️⃣ Autoriser les pods entre eux (facultatif si CNI gère tout)
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  # 4️⃣ Egress ouvert (classique en EKS)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, var.tags)
}

# ----------------------------
# SG Public ALB
# ----------------------------
resource "aws_security_group" "alb_public" {
  name   = "${var.cluster_name}-public-alb-sg"
  vpc_id = local.vpc_id

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
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, var.tags)
}
