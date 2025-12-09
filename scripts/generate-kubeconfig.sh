#!/usr/bin/env bash
set -euo pipefail

# generate-kubeconfig.sh
# Usage: ./generate-kubeconfig.sh [CLUSTER_NAME] [REGION] [AWS_PROFILE]
# If run from repo root, it will try to read Terraform outputs from the EKS module.

TF_DIR="$(cd "$(dirname "$0")/.." >/dev/null && pwd)"
EKS_DIR="$TF_DIR"

# Try to read from terraform outputs
get_tf_output() {
  local name="$1"
  if command -v terraform >/dev/null 2>&1; then
    if terraform -chdir="$EKS_DIR" show >/dev/null 2>&1; then
      terraform -chdir="$EKS_DIR" output -raw "$name" 2>/dev/null || true
    else
      terraform -chdir="$EKS_DIR" output -raw "$name" 2>/dev/null || true
    fi
  fi
}

ARG_CLUSTER="${1:-}"
ARG_REGION="${2:-}"
ARG_PROFILE="${3:-}"

CLUSTER_NAME="${ARG_CLUSTER:-$(get_tf_output eks_cluster_name || true)}"
REGION="${ARG_REGION:-${AWS_REGION:-${AWS_DEFAULT_REGION:-}}}"
if [ -z "$REGION" ]; then
  REGION="$(get_tf_output region || true)"
fi

if [ -z "$CLUSTER_NAME" ]; then
  echo "ERROR: cluster name not provided and not found in Terraform outputs (eks_cluster_name)."
  echo "Usage: $0 [CLUSTER_NAME] [REGION] [AWS_PROFILE]"
  exit 1
fi

AWS_CMD=(aws)
if [ -n "$ARG_PROFILE" ]; then
  AWS_CMD+=(--profile "$ARG_PROFILE")
elif [ -n "$ARG_PROFILE" ] && [ "$ARG_PROFILE" = "" ]; then
  :
fi

if [ -n "$REGION" ]; then
  AWS_CMD+=(--region "$REGION")
fi

echo "Updating kubeconfig for cluster: $CLUSTER_NAME"
"${AWS_CMD[@]}" eks update-kubeconfig --name "$CLUSTER_NAME"

echo "kubeconfig updated."
