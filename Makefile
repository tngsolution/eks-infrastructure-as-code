ENV ?= dev
AWS_DEFAULT_REGION ?= eu-west-3
VENV_DIR = $(CURDIR)/.venv
PYTHON = $(VENV_DIR)/bin/python3
PIP = $(VENV_DIR)/bin/pip3
SCAN_SCRIPT = ./scripts/scan-account.py
SCAN_OUTPUT = ./vpc_scan_output/$(ENV).json

venv:
	@if [ ! -d $(VENV_DIR) ]; then \
	  python3 -m venv $(VENV_DIR); \
	fi

deps: venv
	$(PIP) install --upgrade pip
	@if [ -f scripts/requirements.txt ]; then \
	  $(PIP) install -r scripts/requirements.txt; \
	else \
	  $(PIP) install boto3; \
	fi

scan: deps
	$(PYTHON) $(SCAN_SCRIPT) $(ENV)
	@mv ./vpc_scan_output/*.json $(SCAN_OUTPUT) 2>/dev/null || true

.PHONY: scan deps venv

.PHONY: core-infra-render
core-infra-render:
	$(MAKE) -C network/core/infra-generator render ENV=$(ENV)

.PHONY: core-infra-plan
core-infra-plan: core-infra-render
	$(MAKE) -C network/core/infra-generator plan ENV=$(ENV)

.PHONY: core-infra-apply
core-infra-apply:
	$(MAKE) -C network/core/infra-generator apply ENV=$(ENV)

.PHONY: core-infra-init
core-infra-init:
	$(MAKE) -C network/core/infra-generator init ENV=$(ENV)
