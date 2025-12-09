import boto3
import json
import os

region = "eu-west-3"
output_dir = "./vpc_scan_output"
os.makedirs(output_dir, exist_ok=True)

ec2 = boto3.client("ec2", region_name=region)

# Récupérer toutes les VPCs
vpcs = ec2.describe_vpcs()["Vpcs"]

for vpc in vpcs:
    vpc_id = vpc["VpcId"]
    vpc_data = {
        "vpc_id": vpc_id,
        "cidr_block": vpc.get("CidrBlock"),
        "subnets": [],
        "route_tables": [],
        "internet_gateways": [],
        "nat_gateways": [],
        "security_groups": []
    }

    # Subnets
    subnets = ec2.describe_subnets(Filters=[{"Name": "vpc-id", "Values": [vpc_id]}])["Subnets"]
    for s in subnets:
        vpc_data["subnets"].append({
            "subnet_id": s["SubnetId"],
            "az": s["AvailabilityZone"],
            "cidr": s["CidrBlock"],
            "tags": {t["Key"]: t["Value"] for t in s.get("Tags", [])}
        })

    # Route Tables
    rtbs = ec2.describe_route_tables(Filters=[{"Name": "vpc-id", "Values": [vpc_id]}])["RouteTables"]
    for r in rtbs:
        vpc_data["route_tables"].append({
            "route_table_id": r["RouteTableId"],
            "associations": r.get("Associations", [])
        })

    # IGWs
    igws = ec2.describe_internet_gateways(Filters=[{"Name": "attachment.vpc-id", "Values": [vpc_id]}])["InternetGateways"]
    for ig in igws:
        vpc_data["internet_gateways"].append({"internet_gateway_id": ig["InternetGatewayId"]})

    # NAT Gateways
    nat_gws = ec2.describe_nat_gateways(Filters=[{"Name": "vpc-id", "Values": [vpc_id]}])["NatGateways"]
    for ng in nat_gws:
        vpc_data["nat_gateways"].append({"nat_gateway_id": ng["NatGatewayId"], "subnet_id": ng["SubnetId"]})

    # Security Groups
    sgs = ec2.describe_security_groups(Filters=[{"Name": "vpc-id", "Values": [vpc_id]}])["SecurityGroups"]
    for sg in sgs:
        vpc_data["security_groups"].append({
            "group_id": sg["GroupId"],
            "group_name": sg["GroupName"],
            "description": sg.get("Description")
        })

    # Écrire fichier JSON par VPC
    output_file = os.path.join(output_dir, f"{vpc_id}.json")
    with open(output_file, "w") as f:
        json.dump(vpc_data, f, indent=2)
    print(f"[+] JSON generated for VPC {vpc_id}: {output_file}")
