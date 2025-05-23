#!/bin/bash

export RG_NAME="rgAKSLabWorkshop"
export LOCATION="westus3" # Make sure the region supports availability zones
export AKS_NAME="aks-labdemo"
export USER_ID="$(az ad signed-in-user show --query id -o tsv)"
#export DEPLOY_NAME="aks-labdemo$(date +%s)"
export DEPLOY_NAME="aks-labdemo1743826678"

# Enable monitoring & logging
echo "deployment name: ${DEPLOY_NAME}"
echo "resource group: ${RG_NAME}"
echo "AKS name: ${AKS_NAME}"
echo "user id: ${USER_ID}"
echo "location: ${LOCATION}"

: <<'COMMENT'
# Get the resource IDs for the monitoring and logging workspaces
while IFS= read -r line; \
do echo "exporting $line"; \
export $line=$(az deployment group show -g ${RG_NAME} -n ${DEPLOY_NAME} --query "properties.outputs.${line}.value" -o tsv); \
done < <(az deployment group show -g $RG_NAME -n ${DEPLOY_NAME} --query "keys(properties.outputs)" -o tsv)
#

#az deployment group show -g rgAKSLabWorkshop  -n aks-labdemo1743826678 --query "keys(properties.outputs)" -o tsv
COMMENT

export MONITOR_ID=""
export GRAFANA_ID=""
export WORKSPACE_ID=""

# Enable metrics monitoring
az aks update \
--resource-group ${RG_NAME} \
--name ${AKS_NAME} \
--enable-azure-monitor-metrics \
--azure-monitor-workspace-resource-id ${MONITOR_ID} \
--grafana-resource-id ${GRAFANA_ID} \
--no-wait
#
echo "Metrics monitoring enabled in ${AKS_NAME}"

# enable monitoring add-on
az aks enable-addons \
--resource-group ${RG_NAME} \
--name ${AKS_NAME} \
--addon monitoring \
--workspace-resource-id ${LOGS_ID} \
--no-wait
#
echo "Monitoring add-on enabled in ${AKS_NAME}"