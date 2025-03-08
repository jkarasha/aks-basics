To make the most of k8s, understanding the API is crucial. k8s is API-driven, all resources are
defined in the API and all communication goes through the API server.

K8s serializes objects such as pods, services as JSON strings and sends them over the network via HTTP.
Objects are also serialized when they are stored in etcd. K8s also supports another protocol called Protobuf
which is more efficient, better and scales better than JSON. However because Protobuf is not as user-friendly
as JSON, k8s still uses JSON for communicating with external clients but uses Protobuf for internal communication.

When clients send requests to the API server, they use`Content-Type: application/json` header to indicate
serialization schemas they support. k8s API server will respond with the same serialization schema.

[The API server](https://kubernetes.io/docs/reference/using-api/api-server/)
The API server exposes a REST API that allows clients to get, create, update, and delete resources.
* All `kubectl` commands to the API Server
* All `kubelets` watch the API server for new tasks and report the status to the API server.
* All control plane services communicate with each other via the API server

The API server is a k8s control plane service that runs as a pod[s] in the`kube-system` namespace.
It's important to ensure that the  control plane is highly available and has enough performance to match
the load of the cluster. If you use a hosted service, the API Server implementation is abstracted away.