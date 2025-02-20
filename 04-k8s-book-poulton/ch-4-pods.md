Commands
- Show a complete list of pod attributes: `kubectl explain pods --recursive`
- Drill down into a specif pod attribute: `kubectl explain pods.spec.restartPolicy`

Pods run one or more containers. All containers in the same pod share the Pod's execution environment.
    - Shared filesystem and volumes (The mnt namespace)
    - Shared network stack (The net namespace)
    - Shared memory (The ipc namespace)
    - Shared process tree (The pid namespace)
    - shared hostname (The uts namespace)
