Commands
- Show a complete list of pod attributes: `kubectl explain pods --recursive`
- Drill down into a specif pod attribute: `kubectl explain pods.spec.restartPolicy`

Pods run one or more containers. All containers in the same pod share the Pod's execution environment.
    - Shared filesystem and volumes (The mnt namespace)
    - Shared network stack (The net namespace)
    - Shared memory (The ipc namespace)
    - Shared process tree (The pid namespace)
    - shared hostname (The uts namespace)

Basics of networking
Every k8s cluster runs a pod network and automatically connects all pods to it.
- It's a flat layer-2 overlay network - no routing or switching is done by the control plane.
- It spans every cluster node, allowing pods to communicate with each other. Every across nodes.
- It is implemented by a third-party plugin, which configures the network via CNI(Container Network Interface)
- You choose a plugin at install time, when you create the cluster.
- This network is only for pods and not nodes.

Multi-Container Pods
- A pod can have multiple containers, it's usually recommended to have one container per pod
- Seperations of concerns or single responsibility principle
- There are times when two containers share resources and can be collocated on the same pod.
- Implemented wither using "sidecar" containers or "init" containers.
- "init" containers are a special type of container defined in the k8s API.
- They will start and complete before the main container. They also run once.
- Their purpose is to prepare/initialize the environment for the main container.
- "sidecar" containers are ordinary containers that run alongside the main container.
- They are not a resource specified in the k8s API
- They add functionality to the main container, without taking over it's role.
- Common examples include logging, monitoring, and tracing.
- Also heavily used by a service mesh to intercept network traffic and provide encryption and telemetry.

Pods are designed as immutable objects. You shouldn't change them after deployment
Immutability applies at two levels: Object immutability(The Pod) and App immutability(container)

k8s lets you specify resource requests and resource limits for containers
- Requests are minimum values
- Limits are maximum values

