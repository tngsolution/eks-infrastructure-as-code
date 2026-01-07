# Makefile for infra-generator

ENV ?= dev
TF_DIR = generated/$(ENV)
VENV_DIR = $(CURDIR)/.venv
PYTHON = $(VENV_DIR)/bin/python3
PIP = $(VENV_DIR)/bin/pip3

venv:
	@if [ ! -d $(VENV_DIR) ]; then \
	  python3 -m venv $(VENV_DIR); \
	fi

deps: venv
	$(PIP) install --upgrade pip
	@if [ -f scripts/requirements.txt ]; then \
	  $(PIP) install -r scripts/requirements.txt; \
	else \
	  $(PIP) install pyyaml; \
	fi

check-ip:
ifndef ALLOWED_PUBLIC_IP
	$(error ALLOWED_PUBLIC_IP is not set. Please export ALLOWED_PUBLIC_IP or set it inline. Example: export ALLOWED_PUBLIC_IP="x.x.x.x/32")
endif


render: check-ip deps
	$(PYTHON) scripts/render.py $(ENV)


plan: check-ip render
	cd $(TF_DIR) && terraform plan


apply: check-ip render
	cd $(TF_DIR) && terraform apply

init:
	cd $(TF_DIR) && terraform init

destroy:
	cd $(TF_DIR) && terraform destroy

.PHONY: render plan apply init destroy


test-output: deps
	$(PYTHON) scripts/test_tf_outputs.py $(ENV)


test-aws: deps
	$(PYTHON) scripts/check_aws_resources.py $(ENV)


test-endpoints: deps
	$(PYTHON) scripts/test_endpoints.py $(ENV)


scan: deps
	$(PYTHON) ../../scripts/scan-account.py $(ENV)