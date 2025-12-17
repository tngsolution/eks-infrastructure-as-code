#!/usr/bin/env python3
import subprocess
import json
import sys
import yaml


# Usage: python check_aws_resources.py [env]
# Default env is 'dev'
#
# This script checks the existence of AWS resources (VPC, subnets, route tables, gateways, NACLs, security groups)
# using the resource IDs from Terraform outputs, not by tags or names. Subnets are verified by their real AWS IDs.

def aws_cli(cmd):
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"AWS CLI error: {' '.join(cmd)}\n{result.stderr}")
        return None
    try:
        return json.loads(result.stdout)
    except Exception:
        return result.stdout.strip()

def get_tf_outputs(env):
    tf_dir = f"generated/{env}"
    result = subprocess.run([
        'terraform', 'output', '-json'
    ], cwd=tf_dir, capture_output=True, text=True)
    if result.returncode != 0:
        print("Error running terraform output:", result.stderr)
        return None
    return json.loads(result.stdout)
def main():
    env = sys.argv[1] if len(sys.argv) > 1 else 'dev'
    with open(f"environments/{env}.yml") as f:
        env_yaml = yaml.safe_load(f)
    print(f"Checking AWS resources for environment: {env}\n")

    tf_outputs = get_tf_outputs(env)
    if not tf_outputs:
        print("Could not load Terraform outputs. Aborting.")
        return

    # VPC
    vpc_id = tf_outputs.get('vpc_id', {}).get('value')
    if vpc_id:
        vpc = aws_cli(["aws", "ec2", "describe-vpcs", "--vpc-ids", vpc_id])
        if vpc and vpc.get('Vpcs'):
            print(f"VPC exists: {vpc_id} (OK)")
        else:
            print(f"VPC {vpc_id}: NOT FOUND!")
    else:
        print("No vpc_id output found!")

    # Subnets
    print("\nSubnets:")
    for subnet in env_yaml.get('subnets', []):
        subnet_name = subnet['name']
        key = f"{subnet_name}_id"
        subnet_id = tf_outputs.get(key, {}).get('value')
        if subnet_id:
            sub = aws_cli(["aws", "ec2", "describe-subnets", "--subnet-ids", subnet_id])
            if sub and sub.get('Subnets'):
                print(f"  {subnet_name}: {subnet_id} (OK)")
            else:
                print(f"  {subnet_name}: {subnet_id} NOT FOUND!")
        else:
            print(f"  {subnet_name}: No output found!")

    # Route Tables
    if vpc_id:
        print("\nRoute Tables:")
        for route in env_yaml.get('routes', []):
            rt_name = route['route_table_name']
            rts = aws_cli([
                "aws", "ec2", "describe-route-tables",
                "--filters",
                f"Name=vpc-id,Values={vpc_id}",
                f"Name=tag:Name,Values={rt_name}"
            ])
            if rts and rts.get('RouteTables'):
                print(f"  {rt_name}: {rts['RouteTables'][0]['RouteTableId']} (OK)")
            else:
                print(f"  {rt_name}: NOT FOUND!")

    # Internet Gateway
    if vpc_id:
        print("\nInternet Gateway:")
        igws = aws_cli([
            "aws", "ec2", "describe-internet-gateways",
            "--filters",
            f"Name=attachment.vpc-id,Values={vpc_id}"
        ])
        if igws and igws.get('InternetGateways'):
            print(f"  IGW: {igws['InternetGateways'][0]['InternetGatewayId']} (OK)")
        else:
            print("  IGW: NOT FOUND!")

    # NAT Gateway
    if vpc_id:
        print("\nNAT Gateway:")
        nats = aws_cli([
            "aws", "ec2", "describe-nat-gateways",
            "--filter",
            f"Name=vpc-id,Values={vpc_id}"
        ])
        if nats and nats.get('NatGateways'):
            print(f"  NAT: {nats['NatGateways'][0]['NatGatewayId']} (OK)")
        else:
            print("  NAT: NOT FOUND!")

    # NACLs
    if vpc_id:
        print("\nNACLs:")
        for nacl in env_yaml.get('nacls', []):
            nacl_name = nacl['name']
            nacls = aws_cli([
                "aws", "ec2", "describe-network-acls",
                "--filters",
                f"Name=vpc-id,Values={vpc_id}",
                f"Name=tag:Name,Values={nacl_name}"
            ])
            if nacls and nacls.get('NetworkAcls'):
                print(f"  {nacl_name}: {nacls['NetworkAcls'][0]['NetworkAclId']} (OK)")
            else:
                print(f"  {nacl_name}: NOT FOUND!")

    # Security Groups
    if vpc_id:
        print("\nSecurity Groups:")
        for sg in env_yaml.get('security_groups', []):
            sg_name = sg['name']
            sgs = aws_cli([
                "aws", "ec2", "describe-security-groups",
                "--filters",
                f"Name=vpc-id,Values={vpc_id}",
                f"Name=group-name,Values={sg_name}"
            ])
            if sgs and sgs.get('SecurityGroups'):
                print(f"  {sg_name}: {sgs['SecurityGroups'][0]['GroupId']} (OK)")
            else:
                print(f"  {sg_name}: NOT FOUND!")

if __name__ == "__main__":
    main()
