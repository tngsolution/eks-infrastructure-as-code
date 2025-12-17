# NAT Gateway Terraform Module

This Terraform stack deploys AWS NAT Gateway(s) for providing internet access to resources in private subnets.

## Architecture

- **Elastic IPs**: One per NAT Gateway
- **NAT Gateways**: Deployed in public subnets
- **Routes**: Automatically updates private subnet route tables (optional)

## High Availability Options

### Single NAT Gateway (Cost-Optimized)
- **Use Case**: Development, testing, non-critical workloads
- **Configuration**: `nat_gateway_count = 1`
- **Cost**: ~$32-40/month (depending on data transfer)
- **Risk**: Single point of failure

### Multiple NAT Gateways (High Availability)
- **Use Case**: Production, critical workloads
- **Configuration**: `nat_gateway_count = 2` or `3` (one per AZ)
- **Cost**: ~$96-120/month for 3 NAT Gateways
- **Benefit**: No single point of failure, AZ-level redundancy

## Prerequisites

- VPC with public and private subnets
- Internet Gateway attached to VPC
- Terraform >= 1.0
- AWS CLI configured with appropriate credentials

## Usage

### 1. Configure Variables

Copy the example file and customize:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
name_prefix       = "my-project"
region            = "us-east-1"
environment       = "dev"
nat_gateway_count = 1

public_subnet_ids = [
  "subnet-abc123",
  "subnet-def456",
  "subnet-ghi789"
]

private_route_table_ids = [
  "rtb-abc123",
  "rtb-def456",
  "rtb-ghi789"
]
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Plan Deployment

```bash
terraform plan
```

### 4. Deploy

```bash
terraform apply
```

## Configuration Options

### Basic Configuration

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `name_prefix` | Prefix for resource names | `"eks"` | No |
| `region` | AWS region | `"us-east-1"` | No |
| `environment` | Environment name | `"dev"` | No |
| `nat_gateway_count` | Number of NAT Gateways | `1` | No |
| `public_subnet_ids` | Public subnet IDs | - | Yes |

### Advanced Configuration

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `private_route_table_ids` | Private route table IDs | `[]` | No |
| `create_routes` | Create routes automatically | `true` | No |
| `internet_gateway_id` | IGW ID for dependencies | `null` | No |
| `vpc_id` | VPC ID | `""` | No* |
| `vpc_scan_file` | VPC scan JSON file | `"../../vpc_scan_output/data.json"` | No* |
| `tags` | Additional tags | `{}` | No |

*Either `vpc_id` or valid `vpc_scan_file` should be provided

## Outputs

| Output | Description |
|--------|-------------|
| `nat_gateway_ids` | List of NAT Gateway IDs |
| `nat_gateway_public_ips` | Public IPs of NAT Gateways |
| `elastic_ip_ids` | Elastic IP allocation IDs |
| `nat_gateway_subnet_ids` | Subnet IDs where NAT Gateways are deployed |

## Examples

### Single NAT Gateway (Dev Environment)

```hcl
name_prefix       = "dev-app"
environment       = "dev"
nat_gateway_count = 1

public_subnet_ids = ["subnet-abc123"]
private_route_table_ids = [
  "rtb-private-1",
  "rtb-private-2"
]
```

### Multi-AZ NAT Gateways (Production)

```hcl
name_prefix       = "prod-app"
environment       = "prd"
nat_gateway_count = 3

public_subnet_ids = [
  "subnet-us-east-1a",
  "subnet-us-east-1b",
  "subnet-us-east-1c"
]

private_route_table_ids = [
  "rtb-private-us-east-1a",
  "rtb-private-us-east-1b",
  "rtb-private-us-east-1c"
]
```

## Cost Considerations

### Pricing (us-east-1)
- **NAT Gateway hourly**: ~$0.045/hour (~$32.40/month)
- **Data processing**: ~$0.045/GB
- **Elastic IP**: Free while attached, $0.005/hour if unattached

### Monthly Cost Estimates
- **1 NAT Gateway**: ~$32-50/month (depending on data transfer)
- **3 NAT Gateways**: ~$96-150/month
- **Data transfer**: Varies by usage (typically $5-50/month per NAT GW)

### Cost Optimization
- Use single NAT Gateway for dev/test environments
- Consider NAT instances for very light workloads
- Monitor data transfer to optimize costs

## Integration with VPC Scan

This module can automatically discover VPC configuration from `vpc_scan_output/data.json`:

```bash
# Run VPC scan first
cd ../../scripts
python3 scan-account.py

# Then deploy NAT Gateway
cd ../services/natgw
terraform apply
```

## Cleanup

```bash
terraform destroy
```

## Notes

- NAT Gateway creation takes ~3-5 minutes
- Deletion takes ~2-3 minutes
- Elastic IPs are retained until explicitly deleted
- Ensure Internet Gateway exists before deploying
- For HA, deploy one NAT Gateway per AZ

## Troubleshooting

### NAT Gateway not routing traffic
- Verify route table associations
- Check security group rules
- Confirm Internet Gateway is attached

### High costs
- Review data transfer patterns
- Consider consolidating to fewer NAT Gateways for non-prod
- Monitor CloudWatch metrics for usage

### Terraform errors
- Ensure proper AWS credentials
- Verify subnet IDs are in public subnets
- Check Internet Gateway exists in VPC

## References

- [AWS NAT Gateway Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)
- [NAT Gateway Pricing](https://aws.amazon.com/vpc/pricing/)
- [High Availability Best Practices](https://aws.amazon.com/vpc/faqs/)
