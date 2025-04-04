# Create an SSH key pair using Azure CLI
az sshkey create --name "azure-cli" --resource-group "rg-do-not-delete"

# Create an SSH key pair using ssh-keygen
ssh-keygen -t rsa -b 4096

# Create the cluster
az deployment group create --resource-group rg-aks-basics-bicep --template-file main.bicep --parameters dnsPrefix=<dns-prefix> linuxAdminUsername=<linux-admin-username> sshRSAPublicKey='<ssh-key>'

# connect to the cluster
az aks get-credentials --resource-group rg-aks-basics-bicep --name aks-a36800