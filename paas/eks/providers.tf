terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }

  required_version = ">= 1.6.0"
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = aws_eks_cluster.tngs_eks.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.tngs_eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}



