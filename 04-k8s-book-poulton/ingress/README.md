Ingress is all about accessing multiple web applications through a single `LoadBalancer` service.

Because there's an internal dependency between the load balancer and the `LoadBalancer`, the `NodePort` and the `ClusterIP`, it means that you will need a distinct load balancer for every service. Load balancers are not free service and that could make the solution expensive.

`Ingress` fixes this issue by letting you expose multiple `Services` through a single load balancer. It does this by creating a single cloud load balancer on port `80` (http) and port `443` (https) and then using `host-based` and `path-based` rules to direct traffic to the appropriate service on the cluster.

Ingress is defined in the `networking.k8s.io/v1` API sub-group and requires a resource and a controller. The `resource` defines the routing rules and the `controller` implements them.

However k8s doesn't have a built in ingress controller. Meaning you will need to install one. There are several options for doing this: `nginx`, `traefik` are the most common.

Ingress operates at `Layer 7` of the OSI model, also known as the application layer. This means it can inspect HTTP headers and forward traffic based on hostnames and paths.

OSI model is the industry standard for TCP/IP networking and has seven layers. The lowest layers are `Layer 1` (Physical layer) and `Layer 2` (Data Link layer) are concerned with signaling and electronics, the middle layers are `Layer 3` (Network layer) and `Layer 4` (Transport layer) are concerned with addressing and routing, the next layers are `Layer 5` (Session layer) and `Layer 6` (Presentation layer) are concerned with content negotiation and application layer protocols, and the highest layer is `Layer 7` (Application layer), which is concerned with application-specific protocols.

Let's assume you had two sub applications that you wanted to support `orders.example.com` and `products.example.com`. This assumes a host-based type of routing. The ingress controller will map these to the `orders` and `products` services respectively. If using `path-based` type of routing, `example.com/orders` and `example.com/products` would be the URLs for the `orders` and `products` services respectively.

A sample yml file to install and set up an nginx ingress controller is the following:
https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/cloud/deploy.yaml

[Ingress Classes]

Ingress classes allow you to run multiple ingress controllers on a single cluster. You assign each `Ingress controller` to a `class` and then create `Ingress resources` that reference that class. Run `kubectl get ingressclass` to see the list of available classes. To take closer look run `kubectl describe ingressclass <class-name>`.


[Configure Host-Based Routing & Path-Based Routing]

- Deploy an app called `orders` and front it with a ClusterIP service called `orders-svc`
- Deploy an app called `products` and front it with a ClusterIP service called `products-svc`

- Deploy and `Ingress` object that creates a single load balancer and routing rules for the following host-names and paths.
    - orders.example.com --> Service: orders-svc
    - products.example.com --> Service: products-svc
    - example.com/orders --> Service: orders-svc
    - example.com/products --> Service: products-svc

- Configure DNS for `orders.example.com` and `products.example.com` to point to the load balancer IP of the ingress controller.

[Inspecing Ingress Objects]

- Run `kubectl get ingress or ing` to see the list of `Ingress` objects in the cluster. For more details run `kubectl describe ingress <ingress-name>`

Once you’ve installed an Ingress controller, you create and deploy Ingress objects, which are lists of rules governing how incoming traffic is routed to applications on your cluster. It supports host-based and path-based HTTP routing.

To remove the earlier installed ingress controller, run the following command:
```bash
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/cloud/deploy.yaml