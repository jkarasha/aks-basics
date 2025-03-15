#!/bin/bash

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to display error messages and exit
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Function to display info messages
info() {
    echo -e "${GREEN}Info: $1${NC}"
}

# Function to display warning messages
warn() {
    echo -e "${YELLOW}Warning: $1${NC}"
}

# Check if required tools are installed
command -v az >/dev/null 2>&1 || error_exit "Azure CLI is not installed"
command -v kubectl >/dev/null 2>&1 || error_exit "kubectl is not installed"

# Create sample workload application
info "Creating sample workload application..."

kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: sample-workload-identity-key-vault
  namespace: nextflow
  labels:
    azure.workload.identity/use: "true"
spec:
  serviceAccountName: nextflow-sa
  containers:
    - image: ghcr.io/azure/azure-workload-identity/msal-go
      name: oidc
      env:
      - name: KEYVAULT_URL
        value: https://aks-demo-kv.vault.azure.net
      - name: SECRET_NAME
        value: my-secret
  nodeSelector:
    kubernetes.io/os: linux
EOF
