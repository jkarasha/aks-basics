Stateful sets are used to deploy and manage stateful applications. Statefulsets are comparable to deployments, they use a control loop that reconciles observed state with desired state. They both manage pods and add self-healing, scaling, rollouts etc.

However statefulsets offer additional benefits that deployments do not.

* Predictable and persistent pod names
* Predictable and persistent DNS hostnames
* Predictable and persistent volume bindings

These three properties form a Pod's state, and are sometimes referred to as a `Pod's sticky ID`. StatefulSets ensure all three persist across failures, scaling operations and other scheduling events.

StatefulSets pod following a naming convention: `<sts-name>-<ordinal>`. Ordinal is a number starting from 0, and is used to identify the pod within the StatefulSet.

StatefulSets creates a one Pod at a time an wait for it to be running and ready before starting the next. This is different from how deployments work. Deployments use a ReplicaSet controller to start all pods at the same time, which can result in a race condition where one pod is ready before the next one is scheduled. The same startup rules are used whe `sts` scales up or down. When scaling up `sts-demo-0` is created, and then `sts-demo-1` and so on. When scaling down, `sts-demo-1` is deleted and then `sts-demo-0` is deleted.

Be careful when deleting a StatefulSet, pods are not terminated in an orderly manner. To delete a StatefulSet, first scale it down to zero replicas, and then delete it. Also remember to set the `terminationGracePeriodSeconds` to a non-zero value when scaling down, usually at least 10 seconds. This allows the applications to flush any buffers and safely commit writes that are still in flight.

[StatefulSets and Volumes]
When StatefulSets create pods, they also create any volumes the Pods require. K8s will give the volumes special names, like `sts-demo-0-<volume-name>` to make it easy to `stick` the volume to the pod. Although sticky to the pod, the volume is still decoupled using a `PersistentVolumeClaim`. This means volumes have an independent lifecycle, allowing them to survive Pod failures and Pod termination operations.

[StatefulSets and Failure]
The StatefulSet controller observes the state of the cluster and reconciles the observed state with the desired state. If a pod fails, the StatefulSet controller will create a new pod to take its place.

Node failures are a bit trickier to handle. Because a k8s has no way to knowing if a node has completely failed or is just in a transient state. If a `failed` node is back online, the StatefulSet controller will create a new pod on that node. If unfortunately those pods had been recreated on a different node, you'll have identical pods trying to write to the same volume, resulting in data corruption/loss. Newer k8s do a better job handling this situation.

[Network ID & Headless Services]
A `headless` service is a service that has no `clusterIP` and no `externalIP`. It's becomes a StatefulSets `governing service`. When you combine a StatefulSet with a `headless` service, the service creates `DNS SRV` and `DNS A` records for every pod matching teh Service's label selector, making it easier for service discovery.





