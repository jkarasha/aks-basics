# Overview

K8s is api-centric, it's API is served through the API server.

All requests to the API Server include credentials. This is verified by the authentication module. The AuthN layer in k8s is pluggable and supports multiple authentication mechanisms. 

By default k8s clusters support  `clientCertificates`. Most k8s services howerver integrate the the cloud provider's identity provider. Your cluster details and user credentials are stored in a kubernetes config file in your home directory.

The `kubeconfig` file defines a cluster and a user and combines them into a `context`. It then defines a default context to be used by kubectl commands.

AuthZ happens immediately after AuthN. K8s AuthZ is also pluggable. However, most clusters use RBAC. You can run `kubectl auth can-i` to test your permissions. As soon at a request is authorized, it moves immediately to `admissions control`. At the highest level RBAC is `Users, Actions, Resources`. Which user can perform which actions against which resources.

RBAC is enabled on most k8s clusters and is a `least-privilege deny-by-default` system. That which is not authorized is denied.

To understand RBAC, the key concepts are `Roles` and `RoleBindings`. You can use the `kubectl get roles|rolebindings` command to list them.Roles define a set up permissions, RoleBindings bind them to users. Roles and RoleBindings are namespaced, that means they apply to a specific namespace. `ClusterRole` and `ClusterRoleBindings` are cluster-wide and apply to all namespaces. You can use the `kubectl get clusterroles|clusterrolebindings` command to list them.

Most clusters have pre-created roles and bindings to help with initial configuration and getting started.

## Workload Identity on AKS

Workloads deployed on AKS require Entra application credentials or managed identities to access Entra protected resources.

`Microsoft Entra Workload ID` integrates with the capabilities native to k8s to federate with external identity providers.

### Enable Workload Identity on AKS Cluster

To enable `Workload Identity` on AKS cluster, run the following:
```
az aks update \
--resource-group ${RG_NAME} \
--name ${AKS_NAME} \
--enable-oidc-issuer \
--enable-workload-identity
```

After the cluster has been update, run the following command to get the OIDC(OpenID Connect) issuer URL.
```
AKS_OIDC_ISSUER="$(az aks show \
--resource-group ${RG_NAME} \
--name ${AKS_NAME} \
--query "oidcIssuerProfile.issuerUrl" \
--output tsv)"
```
### Create a Managed Identity

A managed identity is an account created in Entra ID. This identity can be used by the application to connect to resources that support Entra Authentication. Application can use managed identities to obtain Microsoft Entra Tokens without having to manage any credentials.

Run the following to set an identity name.
```
USER_ASSIGNED_IDENTITY_NAME="myIdentity"
```

Run the following command to create the managed identity.
```
az identity create \
--resource-group ${RG_NAME} \
--name ${USER_ASSIGNED_IDENTITY_NAME} \
--location ${LOCATION} \
```

We then need to get/retrieve several properties of the managed identity for use with subsequent steps.
```
USER_ASSIGNED_CLIENT_ID="$(az identity show \
--resource-group ${RG_NAME} \
--name ${USER_ASSIGNED_IDENTITY_NAME} \
--query "clientId" \
--output tsv)"
#
USER_ASSIGNED_PRINCIPAL_ID="$(az identity show \
--name "${USER_ASSIGNED_IDENTITY_NAME}" \
--resource-group ${RG_NAME} \
--query "principalId" \
--output tsv)"
#
SERVICE_ACCOUNT_NAMESPACE="default"
SERVICE_ACCOUNT_NAME="workload-identity-sa"
#
# What is the Federated Identity Credential Name??
FEDERATED_IDENTITY_CREDENTIAL_NAME="myFedIdentity"
```

### Create a Kubernetes Service Account

Create a k8s service account and annotate it with the client ID of the managed identity created previously. This annotation is used to associate the managed identity with the service account.
```
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: ${USER_ASSIGNED_CLIENT_ID}
  name: ${SERVICE_ACCOUNT_NAME}
  namespace: ${SERVICE_ACCOUNT_NAMESPACE}
EOF
```

### Create the Federated Identity Credential

Federated identity credentials are a new type of credential that enables workload identity federation for software workloads. For supported scenarios, it allows you to access Microsoft Entra protected resources without needing to manage secrets. (How's this different from managed identities).

Run the code below to create a federated identity credential:
```
az identity federated-credential create \
--name ${FEDERATED_IDENTITY_CREDENTIAL_NAME} \
--identity-name ${USER_ASSIGNED_IDENTITY_NAME} \
--resource-group ${RG_NAME} \
--issuer ${AKS_OIDC_ISSUER} \
--subject "system:serviceaccount:${SERVICE_ACCOUNT_NAMESPACE}:${SERVICE_ACCOUNT_NAME}" \
--audience api://AzureADTokenExchange
```

* It takes a few seconds for the federated identity credential to propagate after it's created.

Assign the `Key Vault Secrets User` role to the user-assigned managed identity that you created above. This allows the managed identity to read secrets from the key vault.

```
az role assignment create \
--assignee-object-id "${USER_ASSIGNED_PRINCIPAL_ID}" \
--role "Key Vault Secrets User" \
--scope "${AKV_ID}" \
--assignee-principal-type ServicePrincipal
```

### Deploy a sample application utilizing workload identity.

```
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: sample-workload-identity
  namespace: ${SERVICE_ACCOUNT_NAMESPACE}
  labels:
    azure.workload.identity/use: "true"  # Required. Only pods with this label can use workload identity.
spec:
  serviceAccountName: ${SERVICE_ACCOUNT_NAME}
  containers:
    - image: busybox
      name: busybox
      command: ["sh", "-c", "sleep 3600"]
EOF
```

* The manifest should reference the service account created earlier.
* Ensure the application pods using workload identity include the label `azure.workload.identity/use: "true"` in the pod spec. Otherwise the pods will fail after they are restarted.

### Access Secrets in Key Vault with Workload Identity.

We'll use `Azure RBAC` permission model to grant the pod access to the key vault.

Run the following command to create a secret in the key vault.
```
az keyvault secret set \
--vault-name "${AKV_NAME}" \
--name "my-secret" \
--value "Hello\!"
```

Now, run the following command to deploy a pod that references the service account and keyvault URL:
```
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: sample-workload-identity-key-vault
  namespace: ${SERVICE_ACCOUNT_NAMESPACE}
  labels:
    azure.workload.identity/use: "true"
spec:
  serviceAccountName: ${SERVICE_ACCOUNT_NAME}
  containers:
    - image: ghcr.io/azure/azure-workload-identity/msal-go
      name: oidc
      env:
      - name: KEYVAULT_URL
        value: ${AKV_URL}
      - name: SECRET_NAME
        value: my-secret
  nodeSelector:
    kubernetes.io/os: linux
EOF
```

Use the `kubectl describe` to check whether all the properties are injected properly by the webhook.
```
kubectl describe pod sample-workload-identity-key-vault | grep "SECRET_NAME:"
```

Verify that the pod is able to get a token and access the resource by checking it's logs.
```
kubectl logs sample-workload-identity-key-vault
```
