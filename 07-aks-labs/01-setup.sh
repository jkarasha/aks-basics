export RG_NAME="rgAKSLabWorkshop"
export LOCATION="westcentralus" # Make sure the region supports availability zones

#make sure you are logged in.
#az login --use-device-code

# Resource Group
az group create \
--name ${RG_NAME} \
--location ${LOCATION}

# Use ARM template to deploy resources
export USER_ID="$(az ad signed-in-user show --query id -o tsv)"
export DEPLOY_NAME="aks-labdemo$(date +%s)"
#
az deployment group create \
--name ${DEPLOY_NAME} \
--resource-group ${RG_NAME} \
--template-uri https://raw.githubusercontent.com/azure-samples/aks-labs/refs/heads/main/docs/getting-started/assets/aks-labs-deploy.json \
--parameters userObjectId=${USER_ID} \
--no-wait

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
--zones 1 2 3 \
--load-balancer-sku standard \
--network-plugin azure \
--network-plugin-mode overlay \
--network-dataplane cilium \
--network-policy cilium \
--ssh-access disabled \
--enable-managed-identity \
--enable-acns \
--generate-ssh-keys

# Connect to the cluster
az aks get-credentials \
--resource-group ${RG_NAME} \
--name ${AKS_NAME} \
--overwrite-existing

# Add a user node pool
az aks nodepool add \
--resource-group ${RG_NAME} \
--cluster-name ${AKS_NAME} \
--mode User \
--name userpool \
--node-count 1 \
--node-vm-size Standard_DS2_v2 \
--zones 1 2 3

# taint the system node pool
az aks nodepool update \
--resource-group ${RG_NAME} \
--cluster-name ${AKS_NAME} \
--name systempool \
--node-taints CriticalAddonsOnly=true:NoSchedule


# Enable monitoring & logging
while IFS= read -r line; \
do echo "exporting $line"; \
export $line=$(az deployment group show -g ${RG_NAME} -n ${DEPLOY_NAME} --query "properties.outputs.${line}.value" -o tsv); \
done < <(az deployment group show -g $RG_NAME -n ${DEPLOY_NAME} --query "keys(properties.outputs)" -o tsv)

# Enable metrics monitoring
az aks update \
--resource-group ${RG_NAME} \
--name ${AKS_NAME} \
--enable-azure-monitor-metrics \
--azure-monitor-workspace-resource-id ${monitor_id} \
--grafana-resource-id ${grafana_id} \
--no-wait

# enable monitoring add-on
az aks enable-addons \
--resource-group ${RG_NAME} \
--name ${AKS_NAME} \
--addon monitoring \
--workspace-resource-id ${logs_id} \
--no-wait

# create demo namespace
kubectl create namespace pets

# deploy aks-demo application
kubectl apply -f https://raw.githubusercontent.com/Azure-Samples/aks-store-demo/refs/heads/main/aks-store-quickstart.yaml -n pets