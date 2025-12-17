import os
import yaml
from jinja2 import Environment, FileSystemLoader

def render_templates(env_name):
    base_dir = os.path.dirname(os.path.abspath(__file__))
    envs_dir = os.path.join(base_dir, 'environments')
    templates_dir = os.path.join(base_dir, 'templates')
    output_dir = os.path.join(base_dir, 'generated', env_name)
    os.makedirs(output_dir, exist_ok=True)


    # Load environment YAML
    with open(os.path.join(envs_dir, f'{env_name}.yml')) as f:
        context = yaml.safe_load(f)

    # Inject ALLOWED_PUBLIC_IP from environment if present
    allowed_ip = os.environ.get('ALLOWED_PUBLIC_IP')
    if allowed_ip:
        context['ALLOWED_PUBLIC_IP'] = allowed_ip
    else:
        # Optionally, fail early if not set
        raise RuntimeError('ALLOWED_PUBLIC_IP environment variable must be set.')

    # Set up Jinja2
    jinja_env = Environment(loader=FileSystemLoader(templates_dir))
    for template_name in os.listdir(templates_dir):
        if template_name.endswith('.j2'):
            template = jinja_env.get_template(template_name)
            rendered = template.render(**context)
            out_name = template_name.replace('.j2', '')
            with open(os.path.join(output_dir, out_name), 'w') as out_f:
                out_f.write(rendered)

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python render.py <environment>")
        exit(1)
    render_templates(sys.argv[1])
