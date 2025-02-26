Kubernetes `persistent volume subsystem` let's you connect enterprise-grade storage systems to your Kubernetes cluster. These systems provide advanced data management services such as backup and recovery, replication, snapshots, and high availability.

K8s has support for many different providers. These include block, file and object storage.

Like we saw earlier with networking, k8s uses plugins to connect to storage systems. Modern plugins use the Container Storage Interface(CSI), which is an industry-standard interface for connecting storage systems to Kubernetes.

K8s uses a persistent volume subsystem, which is a standardized set of API objects that make it easy for applications running k8s to consume storage. The key API objects include `PersistentVolume(PV)`, `PersistentVolumeClaims(PVC)`, and `StorageClasses(SC)`.

PVs map to external volumes, PVCs grant access to PVs and SCs make it all automatic and dynamic.

K8s has mechanism to prevent multiple pods from writing to the same volume. There's also a 1:1 mapping between external volumes and PVs. You cannot combine multiple external volumes into a make a single PV.

[Storage Providers](https://kubernetes.io/docs/concepts/storage/storage_classes/)

K8s lets you use storage from a wider range of external systems, called `providers` or `provisioners`. 
Each provider supplies it's own CSI plugin and has unique features and configuration options. All providers are not created equal.

Plugins are usually distributed via Helm chart of YAML installer. Once installed the plugin runs as a set of pods in the `kube-system` namespace.

[Container Storage Interface(CSI)](https://kubernetes.io/docs/concepts/storage/storage-classes/)
An open-source project that defines an industry-standard interface for connecting storage systems to Kubernetes. Any CSI compatible plugin should work with any k8s implementation.

Most cloud providers will usually pre-install CSI plugins for their cloud's native storage services.


[K8S Persistent Volume Subsystem](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

It's made up of `PersistentVolume(PV)`, `PersistentVolumeClaims(PVC)`, and `StorageClasses(SC)`.
PVs represent external volumes, PVCs grant access to PVs, and SCs make it all automatic and dynamic.

[Hands-on Lab](https://azure-samples.github.io/aks-labs/docs/storage/advanced-storage-concepts)
Switch to using AKS specific example

Azure storage options can be categorized into two buckets: Block storage and Shared File storage. 

Storage selection on AKS is based on attach mode. Block storage can be attached to a single node one time only `(RWO: Read Write Once)` while Shared File Storage can be attached to different nodes one time  `(RWX: Read Write Many)`. If you need to access the same file from different nodes, you would need Shared File Storage.

Block storage can be further broken down into `Azure Disk`, `Elastic SAN` and `Local Disks`.

Share file storage can be further broken down into `Azure File Share`, `Azure NetApp Files`, and `Azure Blobs`.


In addition to above options, you'll need to select a performance tier and redundancy type.

Set up a new node pool
```
cat <<EOF >> .env
ACSTOR_NODEPOOL_NAME="acstorpool"
AKS_NAME="aks-ji2zo3qjzbrpg"
RG_NAME="rg-aks-demo-a368604"
EOF
source .env
```

Let's go ahead and add the node pool to our cluster. Requires at least 3 nodes in the poo.
```
az aks nodepool add \
--cluster-name ${AKS_NAME} \
--resource-group ${RG_NAME} \
--name ${ACSTOR_NODEPOOL_NAME} \
--node-vm-size Standard_L8s_v3 \
--node-count 3
```

Update the cluster to enable `Azure Container Storage`. For this to work, make sure you have `k8s-extension` installed, `az extension add -n k8s-extension`.
```
az aks update \
--resource-group ${RG_NAME} \
--name ${AKS_NAME} \
--enable-azure-container-storage ephemeralDisk \
--azure-container-storage-nodepools ${ACSTOR_NODEPOOL_NAME} \
--storage-pool-option NVMe \
--ephemeral-disk-volume-type PersistentVolumeWithAnnotation
```
* This command takes a bit of time, check status using `kubectl get pods -n acstor --watch`. 
* When done it creates a default storage pool that we will delete for this exercise to work, `kubectl delete sp -n acstor ephemeraldisk-nvme`
