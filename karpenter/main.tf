resource "kubernetes_manifest" "karpenter_provisioner" {
  manifest = {
    apiVersion = "karpenter.sh/v1alpha5"
    kind       = "Provisioner"
    metadata = {
      name   = "default"
      labels = local.common_tags
    }
    spec = {
      cluster = { name = data.aws_eks_cluster.tngs_eks.name }
      ttlSecondsAfterEmpty = 30
      requirements = [
        {
          key      = "karpenter.k8s.aws/instance-type"
          operator = "In"
          values   = ["t3.small","t3.medium","t3a.medium"]
        },
        { key = "kubernetes.io/arch", operator = "In", values = ["amd64"] }
      ]
      provider = {
        subnetSelector        = { "karpenter.k8s.aws/cluster" = data.aws_eks_cluster.tngs_eks.name }
        securityGroupSelector = { "aws:cloudformation:stack-name" = aws_security_group.eks_nodes.id }
        instanceProfile       = aws_iam_instance_profile.karpenter_profile.name
        capacityType          = "spot"
      }
      consolidation = true
      limits = {
        resources = {
          cpu    = 8
          memory = "32Gi"
        }
      }
      taints = [
        { key = "spot", value = "true", effect = "NoSchedule" }
      ]
    }
  }
}
