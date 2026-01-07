import os
import sys
import json

def load_scan(env_name):
    scan_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "..", "..", "vpc_scan_output", f"{env_name}.json")
    if not os.path.exists(scan_path):
        raise FileNotFoundError(f"Scan file not found: {scan_path}")
    with open(scan_path) as f:
        scan = json.load(f)
    # Extract subnet IDs and security group IDs
    public_subnet_ids = [s["subnet_id"] for s in scan["subnets"] if "public" in s["tags"].get("Name", "")]
    private_subnet_ids = [s["subnet_id"] for s in scan["subnets"] if "private" in s["tags"].get("Name", "")]
    sg_ids = [sg["group_id"] for sg in scan["security_groups"]]
    return public_subnet_ids, private_subnet_ids, sg_ids

if __name__ == "__main__":
    env = sys.argv[1] if len(sys.argv) > 1 else "dev"
    pub, priv, sgs = load_scan(env)
    print("public_subnet_ids:", pub)
    print("private_subnet_ids:", priv)
    print("security_group_ids:", sgs)
