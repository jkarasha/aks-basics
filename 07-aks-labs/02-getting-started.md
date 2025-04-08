# Overview

How to package applications for delivery to AKS. 

## Setting up your environment

We will use Terraform to provision the necessary resources.

Before proceeding, we'll need to make sure you have the following providers registered in your Azure subscription:

```bash
az provider register --namespace Microsoft.Quota
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.ContainerRegistry
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.ApiManagement
az provider register --namespace Microsoft.Monitor
az provider register --namespace Microsoft.AlertsManagement
az provider register --namespace Microsoft.Dashboard
az provider register --namespace Microsoft.App
```

In additon, make sure you have the following features registered:

```bash
az feature register --namespace "Microsoft.ContainerService" --name "EnableWorkloadIdentityPreview"
az feature register --namespace "Microsoft.ContainerService" --name "AKS-GitOps"
az feature register --namespace "Microsoft.ContainerService" --name "AzureServiceMeshPreview"
az feature register --namespace "Microsoft.ContainerService" --name "AKS-KedaPreview"
az feature register --namespace "Microsoft.ContainerService" --name "AKS-PrometheusAddonPreview"
```

The necessary terraform scripts can be found on this repository. 
[Awesome AKS](https://github.com/pauldotyu/awesome-aks)
