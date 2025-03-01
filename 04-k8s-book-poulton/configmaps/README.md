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

Once stored, you can inject it into containers at run time as: environment variables, arguments to the container's startup command or files in a volume


