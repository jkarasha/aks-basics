Namespaces is a way of dividing a kubernetes cluster into multiple virtual clusters. Not to be confused with kernel namespaces.
    - Kernel namespaces are a way of dividing a computer into multiple virtual operating sytems called containers.
    - k8s namespaces are a way of dividing a kubernetes cluster into multiple virtual clusters called namespaces

Not all objects are namespaced. Use `kubectl api-resources` to list all resources that are namespaced or not. Objects such as Nodes and PersistentVolumes are cluster-scoped and cannot be isolated to namespaces.

Unless specified, k8s defaults to the "default" namespace. All objects deployed without the `--namespace` flag will be deployed into the "default" namespace.

Namespaces allows for multi-tenancy within a single cluster. Each namespace can have its own users, permissions, resource quotas and policies.

However this only offers soft isolation, does not prevent compromised workloads from escaping the namespace and affecting other tenants. For that reason, it's not recommended to use namespaces for multi-tenancy. The best way to guarantee true isolation is to use seperate clusters.

To see all namespaces, run: `kubectl get namespace`. Notice k8s pre-creates a few namespaces called "default", "kube-system" and "kube-public" and "kube-node-lease". 
    - "default" is the k8s default namespace, it's where all objects without a pre-defined namespace are deployed.
    - "kube-system" is where control plane components such are the internal DNS service and metrics server are deployed.
    - "kube-public" is for objects that need to readable by anyone
    - "kube-node-lease" is used for node heartbeat and managing node leases.

Use `kubectl describe ns <namespace-name>` to see more details about a namespace.

To see resource in a namespace, append `-n or --namespace` to the command. For example `kubectl get pods -n default`. You can also use `--all-namespaces` to see resources in all namespaces.

It's not always convenient to use `-n or --namespace` so k8s provides a way to set the default namespace for a session. To do this, run `kubectl config set-context --namespace=<namespace-name>`

When deploying resources you can either use the `-n or --namespace` flag or use the `metadata.namespace` field in the spec of the resource.
