YOUR_INITIALS="a368700"
INITIALS=$(echo "$YOUR_INITIALS" | tr '[:upper:]' '[:lower:]')
RESOURCE_GROUP="rg-azure-$INITIALS"
VM_SKU="Standard_D2as_v5"
AKS_NAME="aks-$INITIALS"
NODE_COUNT="3"
LOCATION="westus3"  
#
STORAGE_ACCOUNT_NAME="sa$INITIALS"
SHARE_NAME="share$INITIALS"
#
echo "INITIALS: $INITIALS"
echo "RESOURCE_GROUP: $RESOURCE_GROUP"
echo "VM_SKU: $VM_SKU"
echo "AKS_NAME: $AKS_NAME"
echo "NODE_COUNT: $NODE_COUNT"
echo "LOCATION: $LOCATION"

# Create storage account
az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --sku Standard_LRS
# Create fileshare
az storage share create --name $SHARE_NAME --connection-string $(az storage account show-connection-string --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP -o tsv)
#
STORAGE_KEY=$(az storage account keys list \
    --resource-group $RESOURCE_GROUP \
    --account-name $STORAGE_ACCOUNT_NAME \
    --query "[0].value" -o tsv)

echo "STORAGE_ACCOUNT_NAME: $STORAGE_ACCOUNT_NAME"
echo "STORAGE_KEY: $STORAGE_KEY"
