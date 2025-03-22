# Running Nextflow on AKS

## Overview
How to configure and set up nextflow running on AKS.

## Cluster Prep

Verify/test connection to your cluster:
```
kubectl cluster-info
```

Create the `namespace(tower-nf)`, the `service-account(tower-launcher-sa)`, the `role (tower-launcher-role)`, the `role-binding (tower-launcher-rolebind) and (tower-launcher-userbind)`. See the include `tower-launcher.yml` sample file.

Set the default namespace to the newly created namespace.
```
kubectl config set-context --current --namespace=tower-nf
```

Create a persistent API token for the newly created service account. The persistent API token is necessary for the service account to be able to authenticate with the kubernetes API server.
```
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: tower-launcher-token
  annotations:
    kubernetes.io/service-account.name: tower-launcher-sa
type: kubernetes.io/service-account-token
EOF
```

Verify the persistent token is created by running the  following:
```
kubectl describe secrets/tower-launcher-token
```

Create persistent storage. For AKS we'll use the predefined storage classes to create a `Persistent Volume Claim(PVC)`.
Seqera requires a `ReadWriteMany` PVC mounted to all nodes where workflow pods will be dispatched. The sample file `tower-file-share-pvc.yml` shows an example of create both a `azurefile-csi-premium` as well as a `azurefile` PVC.

## Create a Seqera Compute Environment

The steps to create a Seqera compute environment are outlined in [this document](https://docs.seqera.io/platform/24.3/compute-envs/k8s#seqera-compute-environment).

Key decision points:
- Authentication: Choose your auth method, decide between using `service account` or `X509 cert`
- K8s control plane: `kubectl cluster-info`
- SSL Certificate that was generated when the cluster was created. `ertificate-authority-data in ~/.kube/config`
- Namespace
- Service Account
- Persistent Volume Claim
- Any custom config, for example Azure storage account information that goes in the Nextflow config.

Once a compute environment is created, Seqera will create a `Deployment` that creates a pod to manage all workflows using that compute.


