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

[Hands-on Lab]
TODO: Complete the hands-on lab
