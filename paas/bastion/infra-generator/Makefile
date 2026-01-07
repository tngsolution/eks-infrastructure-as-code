# Makefile for bastion infra-generator

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
	  $(PIP) install pyyaml jinja2; \
	fi

render: deps
	$(PYTHON) scripts/render.py $(ENV)

plan: render
	cd $(TF_DIR) && terraform plan

apply:
	cd $(TF_DIR) && terraform apply

init:
	cd $(TF_DIR) && terraform init

destroy:
	cd $(TF_DIR) && terraform destroy

clean:
	rm -rf generated
