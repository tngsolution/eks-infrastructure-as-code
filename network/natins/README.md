# NAT Instance (Cost-Optimized NAT Solution)

Stack Terraform pour déployer une **NAT Instance** EC2 économique permettant aux ressources dans les subnets privés (comme EKS) d'accéder à Internet.

## 💰 Coût : ~$4-15/mois (vs $32-50 pour NAT Gateway)

## Architecture

```
Internet
    ↓
Internet Gateway
    ↓
Public Subnet → [NAT Instance t3.nano + EIP]
    ↓
Private Subnets → [EKS Nodes]
```

## Caractéristiques

- ✅ **Économique** : t3.nano = $3.80/mois
- ✅ **Auto-configuration** : user_data configure le NAT automatiquement
- ✅ **Secure** : IMDSv2, encrypted root volume
- ✅ **Auto-discovery** : Découvre les subnets/routes par tags
- ✅ **Amazon Linux 2023** : Dernière AMI stable

## Déploiement rapide

```bash
cd network/natins

# Option 1: Avec VPC scan
cd ../../scripts && python3 scan-account.py && cd ../network/natins

# Option 2: Avec VPC ID
echo 'vpc_id = "vpc-xxxxx"' > terraform.tfvars

terraform init
terraform plan
terraform apply
```

## Configuration minimale

```hcl
vpc_id        = "vpc-xxxxx"
instance_type = "t3.nano"  # $3.80/mois
```

## Types d'instances recommandés

| Type | vCPU | RAM | Coût/mois | Usage |
|------|------|-----|-----------|-------|
| t3.nano | 2 | 0.5 GB | $3.80 | Dev/Test léger |
| t3.micro | 2 | 1 GB | $7.59 | Dev/Test standard |
| t3.small | 2 | 2 GB | $15.18 | Staging |
| t3.medium | 2 | 4 GB | $30.37 | Production légère |

## ⚠️ Important pour EKS

La NAT Instance permet à vos nodes EKS dans les subnets privés de :
- ✅ Pull des images Docker depuis ECR/DockerHub
- ✅ Accéder aux API AWS
- ✅ Télécharger des packages
- ✅ Communiquer avec Internet sortant

## Limitations vs NAT Gateway

| Aspect | NAT Instance | NAT Gateway |
|--------|--------------|-------------|
| Coût | $4-15/mois | $32-50/mois |
| Bande passante | 5-25 Gbps | 100 Gbps |
| HA | Manuelle | Automatique |
| Maintenance | Vous | AWS |
| Setup | 5 min | 1 min |

## Maintenance

```bash
# SSH sur l'instance (via bastion ou SSM)
aws ssm start-session --target <instance-id>

# Vérifier le NAT
sudo iptables -t nat -L -n -v

# Logs
sudo journalctl -u iptables-restore
```

## Outputs

```hcl
nat_instance_id        = "i-xxxxx"
nat_instance_public_ip = "54.x.x.x"
security_group_id      = "sg-xxxxx"
```

## Destroy

```bash
terraform destroy
```
