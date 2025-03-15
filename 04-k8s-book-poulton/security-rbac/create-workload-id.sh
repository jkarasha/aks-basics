#!/bin/bash

# Script to create and configure AKS Workload Identity
# This script sets up workload identity for an AKS cluster, including:
# - Creating/updating an AKS cluster with OIDC issuer
# - Creating a managed identity
# - Setting up Kubernetes service account
# - Configuring federated credentials

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

# Default values
LOCATION="westus3"
RESOURCE_GROUP="rgAKSDemo"
CLUSTER_NAME="aks-ckad-prep"
USER_ASSIGNED_IDENTITY_NAME="aks-ckad-prep-mi"
SERVICE_ACCOUNT_NAME="nextflow-sa"
SERVICE_ACCOUNT_NAMESPACE="nextflow"

# ASSUMES CLUSTER EXISTS

# Get AKS credentials
info "Enabling OIDC issuer and workload identity..."
az aks update \
    --resource-group ${RESOURCE_GROUP} \
    --name ${CLUSTER_NAME} \
    --enable-oidc-issuer \
    --enable-workload-identity

# Get OIDC Issuer URL
info "Getting OIDC Issuer URL..."
AKS_OIDC_ISSUER="$(az aks show \
    --name "${CLUSTER_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --query "oidcIssuerProfile.issuerUrl" \
    --output tsv)" || error_exit "Failed to get OIDC Issuer URL"

# Create managed identity
info "Creating managed identity ${USER_ASSIGNED_IDENTITY_NAME}..."
az identity create \
    --resource-group ${RESOURCE_GROUP} \
    --name ${USER_ASSIGNED_IDENTITY_NAME} \
    --location ${LOCATION} \

# Get managed identity client ID and resource ID
USER_ASSIGNED_CLIENT_ID="$(az identity show \
    --name "${USER_ASSIGNED_IDENTITY_NAME}" \
    --resource-group "${RESOURCE_GROUP}" \
    --query "clientId" \
    --output tsv)"

USER_ASSIGNED_PRINCIPAL_ID="$(az identity show \
--name "${USER_ASSIGNED_IDENTITY_NAME}" \
--resource-group ${RESOURCE_GROUP} \
--query "principalId" \
--output tsv)"

FEDERATED_IDENTITY_CREDENTIAL_NAME="aks-ckad-prep-fid"

# create Kubernetes namespace
info "Creating Kubernetes namespace ${SERVICE_ACCOUNT_NAMESPACE}..."
kubectl create namespace ${SERVICE_ACCOUNT_NAMESPACE}

# Create Kubernetes service account
info "Creating Kubernetes service account..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: ${USER_ASSIGNED_CLIENT_ID}
  name: ${SERVICE_ACCOUNT_NAME}
  namespace: ${SERVICE_ACCOUNT_NAMESPACE}
EOF

# Create federated identity credential
info "Creating federated identity credential..."
az identity federated-credential create \
    --name ${FEDERATED_IDENTITY_CREDENTIAL_NAME} \
    --identity-name ${USER_ASSIGNED_IDENTITY_NAME} \
    --resource-group ${RESOURCE_GROUP} \
    --issuer ${AKS_OIDC_ISSUER} \
    --subject "system:serviceaccount:${SERVICE_ACCOUNT_NAMESPACE}:${SERVICE_ACCOUNT_NAME}" \
    --audience api://AzureADTokenExchange


info "Workload Identity setup completed successfully!"
echo "Resource Group: ${RESOURCE_GROUP}"
echo "AKS Cluster: ${CLUSTER_NAME}"
echo "Managed Identity: ${USER_ASSIGNED_IDENTITY_NAME}"
echo "Service Account: ${SERVICE_ACCOUNT_NAME}"
echo "Namespace: ${SERVICE_ACCOUNT_NAMESPACE}"