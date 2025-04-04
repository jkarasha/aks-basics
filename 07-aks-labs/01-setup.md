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

### Sample

Running the corresponding script will create a cluster with the following:

* Deploy the selected version of Kubernetes.
* Create a system node pool with 3 nodes spread across availability zones 1, 2, and 3. This node pool will be used to host Kubernetes control plane and AKS-specific components.
* Use standard load balancer to support traffic across availability zones.
* Use Azure CNI Overlay Powered By Cilium networking. This will give you the most advanced networking features available in AKS and gives great flexibility in how IP addresses are assigned to pods. Note the Advanced Container Networking Services (ACNS) feature is enabled and will be covered later in the workshop.

Some best practice for production clusters:
* Disable SSH access to the nodes to prevent unauthorized access
* Enable a managed identity for passwordless authentication to Azure services

