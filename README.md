**Project Overview**
- **Purpose:** Terraform configuration to create an AWS EKS cluster plus related IAM, security groups and supporting resources.
- **Scope:** This folder (`EKS/`) contains the EKS cluster configuration, IAM roles (including optional Karpenter), security groups, data sources and variables used by the module.

**Quick Start**
- **Prerequisites:**
  - Terraform >= 1.6.0
  - AWS CLI or credentials available via environment or profile (`AWS_PROFILE` or `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`).
  - `kubectl` if you need to interact with the created cluster.

- **Deploy (local validation; does not apply infra automatically):**
```
cd EKS
cp terraform.tfvars.example terraform.tfvars   # edit values (vpc/subnets, tags)
terraform init -backend=false
terraform fmt -recursive
terraform validate
terraform plan -var-file="terraform.tfvars"
```

**Important Files & Structure**
- `providers.tf` : required providers and terraform version.
- `variables.tf` : all configurable variables used by the module (region, cluster_name, node sizing, IAM lists, etc.).
- `terraform.tfvars.example` : example values to copy into `terraform.tfvars`.
- `eks_cluster.tf` : EKS cluster resource and cluster-level attachments.
- `iam_roles.tf` : IAM roles for EKS and optional Karpenter (parameterized).
- `security_groups.tf` : Security group resources used by control plane, nodes and ALB.
- `data_sources.tf` : `aws_subnet` lookups and `aws_eks_cluster_auth`.
- `locals.tf` : local values (includes `vpc_config` JSON parsing of `vpc_scan_output/`).
- `outputs.tf` : useful outputs (endpoint, ca, SG ids, role ARNs, etc.).

**Variables of note**
- `cluster_name` : cluster name used to prefix resource names.
- `private_subnet_ids`, `public_subnet_ids` : if empty, `locals` will extract them from `vpc_scan_output/` JSON.
- `vpc_id` : optional, falls back to parsed `vpc_scan_output/`.
- `create_karpenter` : boolean to enable Karpenter role/profile creation.
- `cluster_managed_policy_arns`, `karpenter_managed_policy_arns` : lists of managed policy ARNs attached by default.

**vpc_scan_output/**
- This folder contains a JSON snapshot used for local development to discover VPC/subnet/security group IDs. **Do not commit** this folder; it is ignored by `.gitignore`.
- If you prefer to use live lookups instead of the JSON file, replace the local parsing logic in `locals.tf` with appropriate `data` resources (be careful: live lookups require AWS permissions at plan time).

**Karpenter**
- The repo contains optional Karpenter IAM role and instance profile. Set `create_karpenter = true` (default true) or false to disable creation.
- Karpenter also requires an OIDC provider + service account with IRSA to be fully functional — check `karpenter/` for charts/manifests and add an OIDC provider if missing.

**Outputs**
- `eks_cluster_endpoint`, `cluster_ca_certificate`, `eks_control_plane_sg_id`, `eks_cluster_role_arn`, `karpenter_role_arn`, etc. Use these to configure CI/CD, kubeconfig scripts or downstream modules.

**Format, Validate and Troubleshooting**
- Run `terraform fmt -recursive` to keep files formatted.
- Use `terraform init -backend=false` for a local validation without remote state.
- `terraform validate` checks configuration syntax and provider compatibility.
- If `terraform plan` complains about missing providers or auth, ensure AWS credentials are reachable and the correct region/profile is set.

**Recommended Next Steps**
- Add a remote backend (S3 + DynamoDB) for team collaboration before applying to production.
- Add a managed `aws_eks_node_group` or finish Karpenter setup (provisioner + IRSA + instance profile mapping) to have worker nodes.
- Add a short `scripts/generate-kubeconfig.sh` that uses outputs to call `aws eks update-kubeconfig`.
- Add CI workflow to run `terraform fmt`, `terraform validate` and `terraform plan` on PRs.

**Contact / Notes**
- Tags: resources merge `local.common_tags` with `var.tags` when provided.
- This README documents what is discoverable in the repo; if you want I can generate a `README` at the repository root linking to this module, or add a GitHub Actions workflow skeleton.
