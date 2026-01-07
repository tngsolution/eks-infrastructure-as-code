ENV ?= dev
TF_DIR = .
VENV_DIR = $(CURDIR)/.venv
PYTHON = $(VENV_DIR)/bin/python3
PIP = $(VENV_DIR)/bin/pip3
SCAN_OUTPUT = ../vpc_scan_output/$(ENV).json

venv:
	@if [ ! -d $(VENV_DIR) ]; then \
	  python3 -m venv $(VENV_DIR); \
	fi

deps: venv
	$(PIP) install --upgrade pip
	@if [ -f ../network/core/infra-generator/scripts/requirements.txt ]; then \
	  $(PIP) install -r ../network/core/infra-generator/scripts/requirements.txt; \
	else \
	  $(PIP) install pyyaml boto3; \
	fi

init:
	cd $(TF_DIR) && terraform init

plan: deps
	cd $(TF_DIR) && terraform plan -var="vpc_scan_file=$(SCAN_OUTPUT)"

apply: deps
	cd $(TF_DIR) && terraform apply -var="vpc_scan_file=$(SCAN_OUTPUT)"

destroy:
	cd $(TF_DIR) && terraform destroy -var="vpc_scan_file=$(SCAN_OUTPUT)"

.PHONY: venv deps init plan apply destroy
