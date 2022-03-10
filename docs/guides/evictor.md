---
description: Information on how to enable and configure Evictor: our bin-packing component
---
# Evictor

## Install Evictor

Evictor will compact your pods into fewer nodes, creating empty nodes that will be removed by the Node deletion policy. To install Evictor fo the first time run this command:

```
helm repo add castai https://castai.github.io/official-addons
helm -n kube-system upgrade -i evictor castai/evictor --set dryRun=false
```

This process will take some time. Also, by default, Evictor will not cause any downtime to single replica deployments / StatefulSets, pods
without ReplicaSet, meaning that those nodes can't be removed gracefully. Familiarize with [rules](#avoiding-downtime-during-bin-packing) and available [overrides](#rules-override-for-specific-pods-or-nodes) in order to setup Evictor to meet your needs.

In order for evictor to run in more aggressive mode (start considering applications with single replica), you should pass the following parameters:

```
--set dryRun=false,aggressiveMode=true
```

In order for evictor to run in scoped mode (only removing nodes created by CAST AI when using scoped autoscaler), you should pass the following parameters:

```
--set dryRun=false,scopedMode=true
```

Evictor by default will only impact nodes older than 5 minutes, if you wish to change the grace period before a node can be considered for eviction set the nodeGracePeriod parameter to the desired time in minutes. This is useful for slow to start nodes to prevent them from being marked for eviction before they can start taking workloads. 

```
--set dryRun=false,nodeGracePeriod=8
```

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
`autoscaling.cast.ai/removal-disabled`| `"true"`| `Annotation`on`Pod`, but can be both`label`and`annotation`on`Node` | Both`Pod`and`Node` | Evictor won't try to Evict a Node with this Annotation or Node running Pod annotated with this Annotation. |
`beta.evictor.cast.ai/disposable` | `"true"`| `Annotation`| `Pod` | Evictor will treat this`Pod` as Evictable despite any of the other rules defined in [Rules](#avoiding-downtime-during-bin-packing)|
`beta.evictor.cast.ai/eviction-disabled` Note: Deprected. Use `autoscaling.cast.ai/removal-disabled` instead.| `"true"` | `Annotation`on`Pod`, but can be both`label`and`annotation`on`Node`| Both`Pod`and`Node`| Evictor won't try to Evict a Node with this Annotation or Node running Pod annotated with this Annotation. |

### Examples of override applications

Label or annotate a pod, so Evictor won't evict a node running an annotated pod (can be applied on a node as well).

```
kubectl label pods <pod-name> beta.evictor.cast.ai/eviction-disabled="true"
```

```
kubectl annotate pods <pod-name> beta.evictor.cast.ai/eviction-disabled="true"
```

Label or annotate a node, to prevent eviction of pods as well as removal of the node (even when it's empty):

```
kubectl label nodes <node-name> autoscaling.cast.ai/removal-disabled="true"
```

```
kubectl annotate nodes <node-name> autoscaling.cast.ai/removal-disabled="true"
```

You can also annotate a pod to make it dispossable, irrespective of other criteria that would normally make the pod un-evictable. Here is an example of a disposable pod manifest:

```
kind: Pod
metadata:
  name: disposable-pod
  annotations:
    beta.evictor.cast.ai/disposable: "true"
spec:
  containers:
    - name: nginx
      image: nginx:1.14.2
      ports:
        - containerPort: 80
      resources:
        requests:
          cpu: '1'
        limits:
          cpu: '1'
```

Due to applied annotation, pod will be targeted for eviction even though it is not replicated.
