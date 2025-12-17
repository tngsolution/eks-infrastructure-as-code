# Makefile for infra-generator

ENV ?= dev
TF_DIR = generated/$(ENV)


check-ip:
ifndef ALLOWED_PUBLIC_IP
	$(error ALLOWED_PUBLIC_IP is not set. Please export ALLOWED_PUBLIC_IP or set it inline. Example: export ALLOWED_PUBLIC_IP="x.x.x.x/32")
endif

render: check-ip
	python render.py $(ENV)


plan: check-ip
	cd $(TF_DIR) && terraform plan


apply: check-ip
	cd $(TF_DIR) && terraform apply

init:
	cd $(TF_DIR) && terraform init

destroy:
	cd $(TF_DIR) && terraform destroy

.PHONY: render plan apply init destroy

test-output:
	python scripts/test_tf_outputs.py $(ENV)

test-aws:
	python scripts/check_aws_resources.py $(ENV)