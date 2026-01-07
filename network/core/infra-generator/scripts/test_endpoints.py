import os
import yaml
import sys
import subprocess

# Chemin du fichier YAML d'environnement
ENV = sys.argv[1] if len(sys.argv) > 1 else "dev"
BASE = os.path.dirname(os.path.abspath(__file__))
YAML_PATH = os.path.join(BASE, f"../environments/{ENV}.yml")

with open(YAML_PATH) as f:
    config = yaml.safe_load(f)

endpoints = config.get("endpoints", {})

print("\n--- Endpoint Tests ---")
for ep, enabled in endpoints.items():
    if enabled:
        output_name = f"{ep}_vpc_endpoint_id"
        print(f"Testing output: {output_name}")
        try:
            result = subprocess.run([
                "terraform", "output", "-json", output_name
            ], cwd="../generated/" + ENV, capture_output=True, text=True)
            if result.returncode == 0 and 'null' not in result.stdout:
                print(f"  ✔ {output_name} found: {result.stdout.strip()}")
            else:
                print(f"  ✖ {output_name} missing or null")
        except Exception as e:
            print(f"  ✖ Error testing {output_name}: {e}")
print("---\n")
