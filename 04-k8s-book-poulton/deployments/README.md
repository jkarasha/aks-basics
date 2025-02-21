
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
There are two ways to manually scale deployments; imperatively, using `kubectl scale --replicas=3 deployment/my-deployment` and declaratively, by updating the deployment yaml file and reposting it.

However to avoid conflicts and issues, it's recommended to make all updates declaratively.

[Performing a rolling update]
Remember that all updated operations are actually replacement operations. Pods are immutable, so you never change or update them after they're deployed. A few of the specifications to remember:
    - `revisionHistoryLimit: 5`, tells k8s to keep the configs from the previous five releases for easy rollbacks.
    - `progressDeadlineSeconds: 300`, tells k8s to wait 5 minutes for the new pod to be ready. If it takes longer, k8s will rollback.
    - `minReadySeconds: 10`, tells k8s to wait 10 seconds for the new pod to be ready. Longer waits give you a better chance of catching problems and preventing scenarios where you replace all replicas with broken ones.
    - `rollingUpdate` tells k8s to use a rolling update strategy.
    - `maxSurge` and `maxUnavailable` tell k8s how many new and unavailable pods to allow before rolling out new ones.

Sounds great? How does k8s know which pods to delete and replace? `labels`! The deployment spec has a selector block, which is a list of labels the Deployment controlle will look for when finding Pods to update during rollouts.

You can monitor the progress using the `kubectl rollout status deployment/my-deployment` command. You can also use the `kubectl rollout pause deploy <deployment-name>` to pause a rolling update and `kubectl rollout resume deploy <deployment-name>` to resume it.

[Rollback]
use the `kubectl rollout history deployment <deployment-name>` command to see revision history. You can them run `kubectl rollout undo deployment <deployment-name> --to-revision=X`, where `X` is the revision number you want to go back to.

Deployments and ReplicaSets use labels and selectors to determine which pods they own and manage. If order to avoid taking ownership of pods that were deployed statically, without using a deployment, k8s adds a system-generated `pod-template-hash` label to each pod created through a deployment.

