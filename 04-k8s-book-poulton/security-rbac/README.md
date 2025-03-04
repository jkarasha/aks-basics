K8s is api-centric, it's API is served through the API server.

All requests to the API Server include credentials. This is verified by the authentication module. The AuthN layer in k8s is pluggable and supports multiple authentication mechanisms. 

By default k8s clusters support  `clientCertificates`. Most k8s services howerver integrate the the cloud provider's identity provider. Your cluster details and user credentials are stored in a kubernetes config file in your home directory.

The `kubeconfig` file defines a cluster and a user and combines them into a `context`. It then defines a default context to be used by kubectl commands.

AuthZ happens immediately after AuthN. K8s AuthZ is also pluggable. However, most clusters use RBAC. You can run `kubectl auth can-i` to test your permissions. As soon at a request is authorized, it moves immediately to `admissions control`. At the highest level RBAC is `Users, Actions, Resources`. Which user can perform which actions against which resources.

RBAC is enabled on most k8s clusters and is a `least-privilege deny-by-default` system. That which is not authorized is denied.

To understand RBAC, the key concepts are `Roles` and `RoleBindings`. You can use the `kubectl get roles|rolebindings` command to list them.Roles define a set up permissions, RoleBindings bind them to users. Roles and RoleBindings are namespaced, that means they apply to a specific namespace. `ClusterRole` and `ClusterRoleBindings` are cluster-wide and apply to all namespaces. You can use the `kubectl get clusterroles|clusterrolebindings` command to list them.

Most clusters have pre-created roles and bindings to help with initial configuration and getting started.



