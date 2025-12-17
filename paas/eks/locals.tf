locals {
  common_tags = {
    Project = "SAA-C03"
    Team    = "DevOps"
  }

  # eks_control_plane_sg_id = data.aws_security_groups.eks_control_plane.ids[0]

  # VPC config: read from vpc_scan_output JSON (user generates locally with scan-account.py)
  # File is .gitignored — NOT committed to repo
  vpc_config_file = var.vpc_scan_file != "" ? var.vpc_scan_file : "${path.module}/../../vpc_scan_output/data.json"
  vpc_config      = try(jsondecode(file(local.vpc_config_file)), {})

  vpc_id = var.vpc_id != "" ? var.vpc_id : try(local.vpc_config.vpc_id, null)

  public_subnet_ids = [
    for s in try(local.vpc_config.subnets, []) : s.subnet_id
    if try(strcontains(s.tags.Name, "public"), false)
  ]

  private_subnet_ids = [
    for s in try(local.vpc_config.subnets, []) : s.subnet_id
    if try(strcontains(s.tags.Name, "private"), false)
  ]

  private_sg_id = try([
    for sg in try(local.vpc_config.security_groups, []) : sg.group_id
    if sg.group_name == "tngs-fr-private-sg"
  ][0], null)

  public_sg_id = try([
    for sg in try(local.vpc_config.security_groups, []) : sg.group_id
    if sg.group_name == "tngs-fr-public-sg"
  ][0], null)

  nat_instance_sg_id = try([
    for sg in try(local.vpc_config.security_groups, []) : sg.group_id
    if sg.group_name == "my-eks-nat-instance-sg"
  ][0], null)
}
