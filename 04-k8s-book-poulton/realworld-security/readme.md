# Real World Security

Securitying k8s clusters can be broken down into a few main categories:

* Security in the software delivery pipeline
* Infrastructure & networking security
* Identity & Access management
* Security monitoring and auditing.

## Security in the software delivery pipeline

Be careful using public image repositories, do your own due diligence. Official images are preferred over community images.
Most images start with a base image and then add other layers to build the final image. Maintain a small number of approved base images for your internal teams to build on top of.
Before allowing images to production, run them through a vulnerability security scan. This will check your images at a binary level and check their contents against a database of known vulnerabilities (CVEs).
Integrate vulnerability scanning into your CI/CD pipeline and implement policies to block images with known vulnerabilities from production.
Kubernetes & most container runtimes support image signing and verification. Use this to ensure that only images you trust are deployed to your cluster.    

## Workload Isolation

Cluster-level workload isolation. K8s does not support secure multi-tenant clusters. The only way to isolate two workloads is to run them on their own clusters.
Namespace allow for `soft` isolation of workloads. A namespace provides a scope for names and a way to divide cluster resources between multiple users.
For applications that require non-standard privileges, you might choose to run them on a ring-fenced subset of worker nodes instead of creating a new cluster. This is called node isolation.   

## Identity & Access management

Kubernetes has a robust RBAC subsystem that allows you to control access to cluster resources. The subsystem integrates with existing IAM providers such as Azure AD, GCP IAM, and AWS IAM.

## Security monitoring and auditing

You should always plan for the eventuality that your systems will be breached. When breaches happens, recognize that a breach has occurred, and build a timeline of events to help you understand what happened.
