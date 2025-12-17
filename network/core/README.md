# infra-generator

This directory contains an infrastructure code generator for VPC resources using Jinja2 templates and YAML environment files.

## Structure

```
infra-generator/
├── templates/
│   ├── vpc.tf.j2           # Jinja2 template for VPC resource
│   ├── variables.tf.j2     # Jinja2 template for Terraform variables
│   └── outputs.tf.j2       # Jinja2 template for Terraform outputs
├── environments/
│   ├── dev.yml             # Dev environment variables
│   ├── int.yml             # Int environment variables
│   └── prd.yml             # Prd environment variables
├── render.py               # Script to render templates
└── generated/
     ├── dev/                # Generated Terraform for dev
     ├── int/                # Generated Terraform for int
     └── prd/                # Generated Terraform for prd
```

## Usage

1. Create and activate a virtual environment (recommended):
    ```sh
    python3 -m venv .venv
    source .venv/bin/activate
    pip install jinja2 pyyaml
    ```
2. Render templates for an environment (e.g., dev):
    ```sh
    python render.py dev
    ```
3. The generated Terraform files will appear in `generated/<env>/`.

Edit the YAML files in `environments/` to change environment-specific values.
```jinja2
AWSTemplateFormatVersion: '2010-09-09'
Description: AWS VPC Creation Template

Parameters:
    VpcCidr:
        Type: String
        Default: 10.0.0.0/16
        Description: CIDR block for the VPC

Resources:
    MyVPC:
        Type: AWS::EC2::VPC
        Properties:
            CidrBlock: {{ VpcCidr }}
            EnableDnsSupport: true
            EnableDnsHostnames: true
            Tags:
                - Key: Name
                    Value: {{ vpc_name | default('MyVPC') }}

    MyInternetGateway:
        Type: AWS::EC2::InternetGateway
        Properties:
            Tags:
                - Key: Name
                    Value: {{ igw_name | default('MyInternetGateway') }}

    AttachGateway:
        Type: AWS::EC2::VPCGatewayAttachment
        Properties:
            VpcId: !Ref MyVPC
            InternetGatewayId: !Ref MyInternetGateway

Outputs:
    VpcId:
        Description: VPC ID
        Value: !Ref MyVPC
    InternetGatewayId:
        Description: Internet Gateway ID
        Value: !Ref MyInternetGateway
```