Finding things on busy platform like k8s is hard, service discovery makes it easy.

Apps on k8s need two things to be able to send requests to other apps; the name of the service, and a way to translate that into an IP address.

[The Service Registry](https://kubernetes.io/docs/concepts/services-networking/service/)

The job of a service registry is to maintain a list of services and their IP addresses. Apps use is to convert a name to an IP address. Each k8s cluster has a built-in cluster DNS that it uses as its service registry. True to k8s it's k8s native application managed by a deployment and fronted by a service. The Deployment is called `coredns` or `kube-dns` and the Service is called `kube-dns` or `kube-dns-headless`.

To see the status of the service registry, run the following command:

```bash
kubectl get pods -l k8s-app=kube-dns -n kube-system
```

To see the deployment that manages the service registry, run the following command:

```bash
kubectl get deploy -l k8s-app=kube-dns -n kube-system
```

To see the service that manages the service registry, run the following command:    

```bash
kubectl get service -l k8s-app=kube-dns -n kube-system
```

[Service Registration](https://kubernetes.io/docs/concepts/services-networking/service/#service-registration)

Service registration is done automatically. The cluster DNS watches the API server for new services. Every time it sees a new one, it gets it name and IP and automatically registers it with the service registry.

The cluster DNS registers both the DNS A and SRV records for the service. Associated EndpointSlice objects are also created. 

Every node runs a kube-proxy that observes new objects and creates local routing rules sot that requests are routed to the pods.


[Service Discovery](https://kubernetes.io/docs/concepts/services-networking/service/#service-discovery)

K8s configures every containes to use the Cluster DNS for service discovery. This is accomplished by configure every container's `/etc/resolv.conf` to point to the Cluster DNS. It also adds search domains to append to `unqualified` names. For example given the service `orders`, it will convert to a fully qualified name of `orders.default.svc.cluster.local`.

[ClusterIP Routing](https://kubernetes.io/docs/concepts/services-networking/service/#clusterip-routing)
