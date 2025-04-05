#!/bin/bash

export RG_NAME="rgAKSLabWorkshop"
export LOCATION="westus3" # Make sure the region supports availability zones
export AKS_NAME="aks-labdemo"
export USER_ID="$(az ad signed-in-user show --query id -o tsv)"
export DEPLOY_NAME="aks-labdemo$(date +%s)"

# Enable monitoring & logging
echo "deployment name: ${DEPLOY_NAME}"
echo "resource group: ${RG_NAME}"
echo "AKS name: ${AKS_NAME}"
echo "user id: ${USER_ID}"
echo "location: ${LOCATION}"

#make sure you are logged in.
#az login --use-device-code

# Resource Group
az group create \
--name ${RG_NAME} \
--location ${LOCATION}
echo "Resource group ${RG_NAME} created in ${LOCATION}"

# Use ARM template to deploy resources
az deployment group create \
--name ${DEPLOY_NAME} \
--resource-group ${RG_NAME} \
--template-uri https://raw.githubusercontent.com/azure-samples/aks-labs/refs/heads/main/docs/getting-started/assets/aks-labs-deploy.json \
--parameters userObjectId=${USER_ID} \
--no-wait

echo "Deployment started. You can check the status in the Azure portal."
#--no-wait will run the deployment in the background

# Get the latest k8s version
export K8S_VERSION=$(az aks get-versions -l ${LOCATION} \
--query "reverse(sort_by(values[?isDefault==true].{version: version}, &version)) | [0] " \
-o tsv)

# Create the cluster
az aks create \
--resource-group ${RG_NAME} \
--name ${AKS_NAME} \
--location ${LOCATION} \
--tier standard \
--kubernetes-version ${K8S_VERSION} \
--os-sku AzureLinux \
--nodepool-name systempool \
--node-count 3 \
--zones 2 3 \
--load-balancer-sku standard \
--network-plugin azure \
--network-plugin-mode overlay \
--network-dataplane cilium \
--network-policy cilium \
--ssh-access disabled \
--enable-managed-identity \
--enable-acns \
--generate-ssh-keys

echo "AKS cluster ${AKS_NAME} created in ${LOCATION} with version ${K8S_VERSION}"

# Connect to the cluster
az aks get-credentials \
--resource-group ${RG_NAME} \
--name ${AKS_NAME} \
--overwrite-existing

echo "Connected to AKS cluster ${AKS_NAME}"

# Add a user node pool
az aks nodepool add \
--resource-group ${RG_NAME} \
--cluster-name ${AKS_NAME} \
--mode User \
--name userpool \
--node-count 1 \
--node-vm-size Standard_DS2_v2 \
--zones 2 3

echo "User node pool userpool created in ${AKS_NAME}"

# taint the system node pool
az aks nodepool update \
--resource-group ${RG_NAME} \
--cluster-name ${AKS_NAME} \
--name systempool \
--node-taints CriticalAddonsOnly=true:NoSchedule

echo "System node pool systempool tainted in ${AKS_NAME}"

# create demo namespace
kubectl create namespace pets
echo "Namespace pets created"

# deploy aks-demo application
kubectl apply -f https://raw.githubusercontent.com/Azure-Samples/aks-store-demo/refs/heads/main/aks-store-quickstart.yaml -n pets
echo "aks-store-demo application deployed in pets namespace"

# wait for the application to be ready 
while [ $(kubectl get pods -n pets -l app=store-front -o jsonpath='{.items[0].status.containerStatuses[0].ready}') != "true" ]; do
  echo "Waiting for aks-store-demo application to be ready..."
  sleep 5
done
echo "aks-store-demo application is ready"

# get the application url
export APP_URL=$(kubectl get service store-front -n pets -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Application URL: http://${APP_URL}"