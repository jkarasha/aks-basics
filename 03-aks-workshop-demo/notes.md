
Exercise: Working with Multi-Container Pods, Ephemeral Volumes and ConfigMaps

#Setup the init config-maps
kubectl apply -f mysql-initdb-cm.yaml

#Setup the configuration config-maps
kubectl apply -f mysql-cnf-cm.yaml

#deploy the multi-container resource
kubectl apply -f mysql-dep.yaml

#Get the logs from the mysql pod
kubectl logs -c logreader -f "mysql-dep-55d8cdcdff-h2s8s"

#exec into the mysql container
kubectl exec -it -c mysql "mysql-dep-55d8cdcdff-h2s8s" -- bash


Exercise: Working with Persistent Volumes, Persistent Volume Claims and Secrets

#Create the namespace
kubectl create ns lab3volume

#Set the context to the current context and set the namespace (don't have to keep using --n)
kubectl config set-context --current --namespace lab3volume

#Create the persistent volume claim
kubectl create secret generic azure-secret --from-literal=azurestorageaccountname=$STORAGE_ACCOUNT_NAME --from-literal=azurestorageaccountkey=$STORAGE_KEY --dry-run=client --namespace lab3volume -o yaml > azure-secret.yaml

#Get the persistent volume
kubectl get pv