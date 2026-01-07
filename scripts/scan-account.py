import boto3
import json
import os
import sys
yaml = None
try:
    import yaml
except ImportError:
    pass

region = "eu-west-3"
output_dir = "./data/network"
os.makedirs(output_dir, exist_ok=True)

# Ajout du scan des zones Route53 (id et nom uniquement)
route53 = boto3.client("route53", region_name=region)
zones = route53.list_hosted_zones()["HostedZones"]
route53_data = []
for zone in zones:
    zone_id = zone["Id"].split("/")[-1]
    zone_name = zone["Name"]
    route53_data.append({
        "zone_id": zone_id,
        "zone_name": zone_name
    })

ec2 = boto3.client("ec2", region_name=region)
route53 = boto3.client("route53", region_name=region)
zones = route53.list_hosted_zones()["HostedZones"]
vpcs = ec2.describe_vpcs()["Vpcs"]
print(f"[DEBUG] VPCs trouvés dans la région {region}:")
for vpc in vpcs:
    vpc_id = vpc["VpcId"]
    vpc_tags = {t["Key"]: t["Value"] for t in vpc.get("Tags", [])}
    vpc_tag_name = vpc_tags.get("Name", vpc_id)
    print(f"  - {vpc_id}: {vpc_tags}")
    # Recherche d'une zone Route53 correspondant au nom du VPC (par suffixe ou égalité stricte)
    zone_id = None
    zone_name = None
    for z in zones:
        zn = z["Name"].rstrip('.')
        if vpc_tag_name.endswith(zn) or vpc_tag_name == zn:
            zone_id = z["Id"].split("/")[-1]
            zone_name = zn
            break
    vpc_data = {
        "vpc_id": vpc_id,
        "cidr_block": vpc.get("CidrBlock"),
        "subnets": [],
        "route_tables": [],
        "internet_gateways": [],
        "nat_gateways": [],
        "security_groups": [],
        "route53": route53_data
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
    # Write JSON file for this VPC, named by tag Name or VpcId
    safe_name = vpc_tag_name.replace("/", "_").replace(" ", "_")
    output_file = os.path.join(output_dir, f"{safe_name}.json")
    with open(output_file, "w") as f:
        json.dump(vpc_data, f, indent=2)
    print(f"[+] JSON generated for VPC {vpc_id} as {output_file}")

