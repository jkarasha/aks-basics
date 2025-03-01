K8s allows you to build and store apps and their configurations seperately and bring them together at run time.

[ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
Used to store non-sensitive data such apps
- Environment variables
- Config files (webserver config, database config)
- Hostnames
- Service ports
- Account names

** Do not store sensitive data in ConfigMaps **

At a high level, a ConfigMap is a place to store configuration data that you can easily inject
into containers at run time. They are transparent to the application, therefor no need to change your
application to work with them.

ConfigMaps hold a map of key to value pairs. The values can be strings or arbitrary objects.
Instead of `akms` think `akmd` -> apiVersion-kind-metadata-data where data stores you config.

Could be key-value pairs
```
apiVersion: v1
kind: ConfigMap
metadata:
    name: my-config
data:
    key1: value1
    key2: value2
```

or could be an object with key-value pairs

```
apiVersion: v1
kind: ConfigMap
metadata:
    name: my-config
data:
  test.conf |
    env = "dev"
    endpoint = "https://localhost:8080"
    charset = "utf-8"
    vault = dev/vault
    log-level = info
    log-format = json
    log-size = 1m
```

Once stored, you can inject it into containers at run time as: environment variables, arguments to the container's startup command or files in a volume.

Like other k8s objects, ConfigMaps can be created imperatively or declaratively. To create imperatively, you can use the `kubectl create configmap` command.

Unlike other k8s objects, ConfigMaps do not have a concept of state(desired state vs actual state). That's why they are defined with a `data` section instead of a `spec` section.

[Using configmaps in containers](https://kubernetes.io/docs/concepts/configuration/configmap/#using-configmaps-in-containers)

- ConfigMaps + Env vars: by using `valueFrom.configMapKeyRef` in the container spec.
```
env:
  -name: FIRSTNAME
  valueFrom:
    configMapKeyRef:
      name: test-cm-singlemap
      key: given
```
When the pod is scheduled and the container is started, `FIRSTNAME` will be injected as an environment variable.

Environment variables are static so changes made to the ConfigMap do not propagate to the container.

You can use the variables, just like any other environment variable.
```
command: [ "/bin/sh", "-c", "echo First name $(FIRSTNAME)" ]
```

- ConfigMaps + Volumes: by using `valueFrom.configMapKeyRef` in the volume spec. This allows for changes to the volume contents to be reflected on the container at run time.

```
...
spec:
  volumes:
  - name: config-volume-map
    configMap:
      name: test-cm-singlemap
  containers:
  - name: configmap-test
    image: busybox
    volumeMounts:
    - mountPath: /etc/test.conf
      name: config-volume-map
```

[Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
Secrets are identical to ConfigMaps, except that they are intended for storing sensitive information.

Although k8s makes an effort to secure the data, it is not 100% secure.

For a more complete and secure secrets management use something like [Vault](https://www.vaultproject.io/).

The process for using `secrets` is:

1. Create the secret which is persisted on the cluster store. It's `unencrypted` by default.
2. You schedule a Pod that uses the secret
3. k8s transfers the `unencrypted secret` over the network to the node running the pod.
4. The kubelet on the node starts the Pod and it's containers.
5. The container runtime mounts the secret into the container via an in-memory tmpfs and decodes it from base64 to plain text.
6. The container reads the secret data and uses it to configure the application.
7. When you delete the Pod, k8s deletes the copy of the Secret on the node. The copy in the cluster store is still there.

To create a secret impreatively, you can use the `kubectl create secret` command.

Secrets work like ConfigMaps, you can inject them into containers at runtime as environment variables, command arguments or files in a volume. The most flexible way is to use volumes.

