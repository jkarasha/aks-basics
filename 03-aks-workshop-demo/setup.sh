YOUR_INITIALS="a368700"
INITIALS=$(echo "$YOUR_INITIALS" | tr '[:upper:]' '[:lower:]')
RESOURCE_GROUP="rg-azure-$INITIALS"
VM_SKU="Standard_D2as_v5"
AKS_NAME="aks-$INITIALS"
NODE_COUNT="3"
LOCATION="westus3"  
echo "INITIALS: $INITIALS"
echo "RESOURCE_GROUP: $RESOURCE_GROUP"
echo "VM_SKU: $VM_SKU"
echo "AKS_NAME: $AKS_NAME"
echo "NODE_COUNT: $NODE_COUNT"
echo "LOCATION: $LOCATION"

#
az group create --location $LOCATION --resource-group $RESOURCE_GROUP

#
az aks create --node-count $NODE_COUNT --generate-ssh-keys --node-vm-size $VM_SKU --name $AKS_NAME --resource-group $RESOURCE_GROUP

