import os
import sys
import yaml
from jinja2 import Environment, FileSystemLoader

if len(sys.argv) < 2:
    print("Usage: render.py <env>")
    sys.exit(1)

env_name = sys.argv[1]
base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
templates_dir = os.path.join(base_dir, "templates")
envs_dir = os.path.join(base_dir, "environments")
output_dir = os.path.join(base_dir, "generated", env_name)
os.makedirs(output_dir, exist_ok=True)

yaml_path = os.path.join(envs_dir, f"{env_name}.yml")
if not os.path.exists(yaml_path):
    print(f"[!] Environment YAML not found: {yaml_path}")
    sys.exit(2)


with open(yaml_path) as f:
    context = yaml.safe_load(f)
    # Force nat_gateway à booléen Python si présent
    if "nat_gateway" in context:
        context["nat_gateway"] = bool(context["nat_gateway"])

jinja_env = Environment(loader=FileSystemLoader(templates_dir), trim_blocks=True, lstrip_blocks=True)

# Only pass context variables that are still used in templates (no subnets, vpc_id, or SGs)
for template_name in ["main.tf.j2", "variables.tf.j2", "locals.tf.j2", "cloud_init.yaml.j2", "providers.tf.j2"]:
    template = jinja_env.get_template(template_name)
    rendered = template.render(**context)
    out_name = template_name.replace(".j2", "")
    with open(os.path.join(output_dir, out_name), "w") as out:
        out.write(rendered)
    print(f"[+] Rendered {out_name}")
