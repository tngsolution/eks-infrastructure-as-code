#!/usr/bin/env python3
import subprocess
import json
import sys

# Usage: python test_tf_outputs.py [env]
# Default env is 'dev'

env = sys.argv[1] if len(sys.argv) > 1 else 'dev'
tf_dir = f"generated/{env}"

def tf_output(name):
    result = subprocess.run([
        'terraform', 'output', '-json', name
    ], cwd=tf_dir, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error getting output {name}: {result.stderr}")
        return None
    try:
        return json.loads(result.stdout)
    except Exception:
        return result.stdout.strip()

def main():
    print(f"Testing Terraform outputs for environment: {env}\n")
    outputs = subprocess.run([
        'terraform', 'output', '-json'
    ], cwd=tf_dir, capture_output=True, text=True)
    if outputs.returncode != 0:
        print("Error running terraform output:", outputs.stderr)
        sys.exit(1)
    all_outputs = json.loads(outputs.stdout)
    for key, value in all_outputs.items():
        print(f"{key}: {value['value']}")

    import yaml
    with open(f"environments/{env}.yml") as f:
        env_yaml = yaml.safe_load(f)

    # Check and print all subnet outputs, and compare with YAML
    print("\nSubnets:")
    expected_subnets = [s['name'] for s in env_yaml.get('subnets', [])]
    found_subnets = []
    missing_subnets = []
    for subnet in expected_subnets:
        key = f"{subnet}_id"
        if key in all_outputs:
            print(f"  {key}: {all_outputs[key]['value']} (OK)")
            found_subnets.append(subnet)
        else:
            print(f"  {key}: MISSING OUTPUT!")
            missing_subnets.append(subnet)
    if not expected_subnets:
        print("  No expected subnets found in the YAML!")
    elif not missing_subnets:
        print(f"\nAll expected subnets ({len(expected_subnets)}) are present in the outputs.")
    else:
        print(f"\nWarning: {len(missing_subnets)} subnet(s) missing in outputs: {', '.join(missing_subnets)}")

    # Check route tables
    print("\nRoute Tables:")
    expected_rts = [r['route_table_name'] for r in env_yaml.get('routes', [])]
    found_rts = []
    missing_rts = []
    for rt in expected_rts:
        key = f"{rt}_id"
        if key in all_outputs:
            print(f"  {key}: {all_outputs[key]['value']} (OK)")
            found_rts.append(rt)
        else:
            print(f"  {key}: MISSING OUTPUT!")
            missing_rts.append(rt)
    if not expected_rts:
        print("  No expected route tables found in the YAML!")
    elif not missing_rts:
        print(f"\nAll expected route tables ({len(expected_rts)}) are present in the outputs.")
    else:
        print(f"\nWarning: {len(missing_rts)} route table(s) missing in outputs: {', '.join(missing_rts)}")

    # Check gateways (Internet Gateway, NAT Gateway)
    print("\nGateways:")
    igw_key = f"{env_yaml['vpc']['name']}-igw_id"
    nat_key = None
    if env_yaml.get('subnets'):
        public_subnet = next((s for s in env_yaml['subnets'] if s.get('map_public')), None)
        if public_subnet:
            nat_key = f"{public_subnet['name']}-nat_id"
    if igw_key in all_outputs:
        print(f"  {igw_key}: {all_outputs[igw_key]['value']} (OK)")
    else:
        print(f"  {igw_key}: MISSING OUTPUT!")
    if nat_key:
        if nat_key in all_outputs:
            print(f"  {nat_key}: {all_outputs[nat_key]['value']} (OK)")
        else:
            print(f"  {nat_key}: MISSING OUTPUT!")

    # Check NACLs
    print("\nNACLs:")
    expected_nacls = [n['name'] for n in env_yaml.get('nacls', [])]
    for nacl in expected_nacls:
        key = f"{nacl}_id"
        if key in all_outputs:
            print(f"  {key}: {all_outputs[key]['value']} (OK)")
        else:
            print(f"  {key}: MISSING OUTPUT!")

    # Check Security Groups
    print("\nSecurity Groups:")
    expected_sgs = [sg['name'] for sg in env_yaml.get('security_groups', [])]
    for sg in expected_sgs:
        key = f"{sg}_id"
        if key in all_outputs:
            print(f"  {key}: {all_outputs[key]['value']} (OK)")
        else:
            print(f"  {key}: MISSING OUTPUT!")

if __name__ == "__main__":
    main()
