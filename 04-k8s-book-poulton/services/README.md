Because pods are unreliable, you shouldn't connect to them directly. You should always use a Service.

Service has a front-end and a back-end. The front-end includes a DNS name, IP address and a port that k8s guarantees will never change. The back-end is a label selector that sends traffic to healthy pods with matching labels.

When you create a Service, k8s automatically creates and associated `EndpointSlice` to track healthy pods with matching labels.

K8s has several types of services:
- ClusterIP
- NodePort
- LoadBalancer

`ClusterIP` is the most basic and provides a realiable endpoint name(name, IP, Port) on the internal Pod network.
`NodePort` builds on top  of ClusterIP and allow external clients to connect via a port on the every cluster node.
`LoadBalancer` builds on top of both and integrate with cloud providers load balancer for simple access from the internet.

[ClusterIP Services]
Allows connectivity from inside the cluster. It's IP is routable on the internal network, it's name is automatically registered with the cluster internal DNS. All containers are pre-programmed to use the cluster DNS to resolve names.

[NodePort Services]
Builds on the ClusterIP by adding a dedicated port on every node on the cluster. This dedicated port is what's called the NodePort. This means external clients can send traffi to the cluster node on the NodePort and reach the Service. (I don't understand this yet? Is it just a way to export the Service to external clients? Why? Oh, the ClusterIP port is not reachable by extnernal clients).

NodePort service has two limitations: It has to to use a high port number (30000 - 32767), and because it must have a way to address the node directly. It also has to know if the node is healthy or not. Because of this, most people prefer to use a `LoadBalancer` Service.

[LoadBalancer Services]
Provides an easier way to export Services to external clients. Essentially a NodePort service with a load balancer in front of it.
