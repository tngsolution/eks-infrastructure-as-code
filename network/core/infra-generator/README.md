## Handling Sensitive/Public IPs

Some security group and NACL rules require a public IP (for example, to allow SSH from your location). This is referenced as `${ALLOWED_PUBLIC_IP}` in the YAML files.

- **Set the variable at render or apply time:**
	- For one-off runs, you can export the variable in your shell:
		```sh
		export ALLOWED_PUBLIC_IP="x.x.x.x/32"
		make render ENV=dev
		```
		or
		```sh
		export ALLOWED_PUBLIC_IP="x.x.x.x/32"
		make apply ENV=dev
		```
	- You can also set it inline:
		```sh
		ALLOWED_PUBLIC_IP="x.x.x.x/32" make render ENV=dev
		```

**Never hardcode sensitive IPs in YAML. Always use the variable for portability and security.**
# Infra Generator

This project generates Terraform code for AWS VPC, subnets, route tables, gateways, NACLs, and security groups from YAML and Jinja2 templates.

## Usage

### 1. Generate Terraform files

```
make render ENV=dev
```

### 2. Initialize, plan, and apply Terraform

```
make init ENV=dev
make plan ENV=dev
make apply ENV=dev
```

### 3. Test Terraform outputs (structure)

Checks that all expected outputs (IDs) are present in Terraform state:

```
make test-output ENV=dev
```

### 4. Test AWS resources (functional)

Checks that all resources (VPC, subnets, route tables, gateways, NACLs, security groups) exist in AWS using their IDs from Terraform outputs (not by tags or names):

```
make test-aws ENV=dev
```

- Subnets are checked by their real AWS IDs, not by tag or vpc-id.
- All checks are based on the current Terraform state and YAML definitions.

## Requirements
- Python 3
- AWS CLI configured (with access to the target account)
- Terraform
- PyYAML (`pip install pyyaml`)

## Scripts
- `scripts/test_tf_outputs.py`: Checks that all expected Terraform outputs are present.
- `scripts/check_aws_resources.py`: Checks that all AWS resources exist using their Terraform output IDs.

## Customization
- Edit `environments/<env>.yml` to define your VPC, subnets, routes, NACLs, and security groups.
- Edit Jinja2 templates in `templates/` to change resource generation logic.

---

For any issues or improvements, open a pull request or contact the maintainer.
