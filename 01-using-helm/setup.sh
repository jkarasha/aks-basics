# test out using help by deploying the voting app
az acr create --resource-group rg-aks-basics-bicep --name a368600acr --sku Basic

# To build and push the image to the ACR. This must be done in the root of the repo
az acr build --image azure-vote-front:v1 --registry a368600acr --file Dockerfile .