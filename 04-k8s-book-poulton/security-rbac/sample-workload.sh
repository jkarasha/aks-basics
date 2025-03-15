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
  name: sample-workload-identity
  namespace: nextflow
  labels:
    azure.workload.identity/use: "true"  # Required. Only pods with this label can use workload identity.
spec:
  serviceAccountName: nextflow-sa
  containers:
    - image: busybox
      name: busybox
      command: ["sh", "-c", "sleep 3600"]
EOF

info "Sample workload application created successfully!"

# Create sample secret
info "Creating sample secret..."

az keyvault secret set \
--vault-name "aks-demo-kv" \
--name "my-secret" \
--value "a368604!@"
