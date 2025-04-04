# AKS Labs Workshop

Workshop using `aks-preview` extension, make sure you have it installed.

```
# Check if installed
az extension list --query "[?name=='aks-preview']"

# Add/Install
az extension add --name aks-preview
```

The worksshop also utilizes `availability-zones`, make sure you install in a regions that has support.

```
az account list-locations --query "[?metadata.regionType=='Physical' && metadata.supportsAvailabilityZones==true].{Region:name}" -o table
```

For this demo we'll use `westcentralus` or `northcentralus`.

## AKS Deployment Strategies

Before deploying an AKS cluster, it's essential to consider its size based on the workload requirements. Thinking about the size and nodes you'll need to deploy.

### System and User Node Pools

By default a single nodepool is created that holds both your system and workload nodes. It's recommended to seperate these.
The system nodepool hosts the k8s control plane: kube-apiserver, coredns, and metrics-server. User node pool will host the user workloads.

### Resiliency & Availability Zones

If you choose to use availability zones, k8s will distribute the control plane zones within a region. By distributing the control plane zones across availability zones, you can ensure high availability of the control plane.

## Creating a Cluster

You'll need to decide on the version of k8s to install. Unless you have hard requirements, always choose the more current version available for your region.

```
export K8S_VERSION=$(az aks get-versions -l ${LOCATION} \
--query "reverse(sort_by(values[?isDefault==true].{version: version}, &version)) | [0] " \
-o tsv)
```

### Sample configuration

Running the corresponding script will create a cluster with the following:

* Deploy the selected version of Kubernetes.
* Create a system node pool with 3 nodes spread across availability zones 1, 2, and 3. This node pool will be used to host Kubernetes control plane and AKS-specific components.
* Use standard load balancer to support traffic across availability zones.
* Use Azure CNI Overlay Powered By Cilium networking. This will give you the most advanced networking features available in AKS and gives great flexibility in how IP addresses are assigned to pods. Note the Advanced Container Networking Services (ACNS) feature is enabled and will be covered later in the workshop.

Some best practice for production clusters:
* Disable SSH access to the nodes to prevent unauthorized access
* Enable a managed identity for passwordless authentication to Azure services

## Add the user node pool

The previous configuration will only create a system pool. To run user workloads, you'll need to add a user node pool.

```
az aks nodepool add \
--resource-group ${RG_NAME} \
--cluster-name ${AKS_NAME} \
--mode User \
--name userpool \
--node-count 1 \
--node-vm-size Standard_DS2_v2 \
--zones 1 2 3
```

## Taint the system node pool

We need to add a taint to the system node pool to prevent user workloads from being scheduled on it. A taint is a key-value pair that prevents pods from being scheduled on a node unless the pod has the corresponding toleration

```
az aks nodepool update \
--resource-group ${RG_NAME} \
--cluster-name ${AKS_NAME} \
--name systempool \
--node-taints CriticalAddonsOnly=true:NoSchedule
```

## Monitoring & Logging

Monitoring and logging are essential for maintaining the health and performance of your AKS cluster. AKS provides integrations with Azure Monitor for metrics and logs. Logging is provided by `container insights` which can send container logs to `Azure Log Analytics Workspaces` for analysis. Metrics are provided by `Azure Monitor managed service for Prometheus` which collects performance metrics from nodes and pods and allows you to query using `PromQL` and visualize using `Azure Managed Grafana`.


## Deploy the AKS Store Demo Application
```
kubectl create namespace pets

kubectl apply -f https://raw.githubusercontent.com/Azure-Samples/aks-store-demo/refs/heads/main/aks-store-quickstart.yaml -n pets
```
![Deploy to Azure](images/aks-store-architecture-778ef23874e9ffd101bb1ff5429a3c4e.png)


## Clean up

Clean up resources.