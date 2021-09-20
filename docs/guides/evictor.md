---
description: Information on how to enable and configure Evictor: our bin-packing component
---
# Evictor

## Install Evictor (continuously improved)

Evictor will compact your pods into fewer nodes, creating empty nodes that will be removed by the Node deletion policy:

```
helm repo add castai https://castai.github.io/official-addons
helm -n kube-system upgrade -i evictor castai/evictor --set dryRun=false
```

This process will take some time. Also, Evictor will not cause any downtime to single replica deployments / StatefulSets, pods
without ReplicaSet, meaning that those nodes can't be removed gracefully.

### Upgrading Evictor

- Check the Evictor version you are currently using:

    ```
    helm ls -n kube-system
    ```

- Update the helm chart repository to make sure that your helm command is aware of the latest charts:

    ```
    helm repo update
    ```

- Install the latest Evictor version:

    ```
    helm -n kube-system upgrade -i evictor castai/evictor --set dryRun=false
    ```

- Check whether the Evictor version was changed:

    ```
    helm ls -n kube-system
    ```

## Avoiding downtime during Bin-Packing

Evictor follows certain rules to avoid downtime. In order for the node to be considered for possible removal due to bin-packing, all of the pods running on the node must meet following criteria:

- A pod must be replicated: it should be managed by a `Controller` (e.g. `ReplicaSet`, `ReplicationController`, `Deployment`), which has more than one replicas (see [Overrides](#rules-override-for-specific-pods-or-nodes))
- A pod is not part of `StatefulSet`
- A pod must not be marked as non-evictable (see [Overrides](#rules-override-for-specific-pods-or-nodes))
- All static pods (YAMLs defined in node's `/etc/kubernetes/manifests` by default) are considered evictable
- All `DaemonSet`-controller pods are considered evictable

### Rules override for specific pods or nodes

| Name | Value | Type (`Annotation` or `Label`) | Location (`Pod` or `Node`) | Effect |
| ----------- | ----------- | ----------- | ----------- | ----------- |
`beta.evictor.cast.ai/eviction-disabled` | `"true"` | `Annotation`on`Pod`, but can be both`label`and`annotation`on`Node`| Both`Pod`and`Node`| Evictor won't try to Evict a Node with this Annotation or Node running Pod annotated with this Annotation. |
`autoscaling.cast.ai/removal-disabled`| `"true"`| Both | `Node` | Evictor won't try to Evict a Node marked with this`Annotation`or`Label` |
`beta.evictor.cast.ai/disposable` | `"true"`| `Annotation`| `Pod` | Evictor will treat this`Pod` as Evictable despite any of the other rules defined in <TODO: link>|
