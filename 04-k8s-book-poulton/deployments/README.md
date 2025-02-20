
How to use deployments to add cloud-native features such as self-healing, scaling, rolling updates, and versioned rollbacks.

Every deployment manages one or more identical pods. If you have two seperate pods in a microservice, best practice is to use seperate deployments for each pod.

Although we say deployments support scaling pods, it's actually the ReplicaSet, defined in the yml, that scales them.

You can scale your apps manually, however it's recommended to use the k8s autoscalers.
    - Horizontal pod autoscaler (Adds/Remove pods to meet current demand. Installed by default, commonly used) 
    - Vertical pod autoscaler (Adjusts container resources to meet current demand. It's not installed by default, not commonly used)
    - Cluster autoscaler (Adds/Remove nodes to meet current demand. Installed by default, commonly used)

[Controllers & Reconciliation]
Reconciliation is the process of ensuring that the desired state of the cluster is achieved. Compares the current state of the cluster to the desired state and makes changes to bring the cluster to the desired state.

ReplicaSets for example, are implemented as a background controller running a reconciliation loop. It ensures the correct number of pods replicas are always running. If there arent enough, it creates new pods. If there are too many, it deletes excess pods.

[Rolling Updates]
Rolling updates are a type of deployment strategy where a new version of the app is deployed and the old version is rolled back.

For rolling updates to work, your apps should be loosely coupled and be backwards and forwards compatible.

Deployments automatically create associated ReplicaSets. To verify this for a given deployment, use `kubectl get rs`. For more details on the ReplicaSet, use `kubectl describe rs <replicaset-name>`.

[Manual Scaling]