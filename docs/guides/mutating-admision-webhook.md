---
description: Information on how to put workloads on spot instances without modification
---
# Mutating Admission Webhook

Modifying workload manifests to achieve the desired savings takes time and effort. The CAST AI Mutating Admission Webhook slightly
modifies workload manifests on-the-fly. It's a quick and effortless way to achieve savings without modifying every workload.

Whenever there's a request to schedule a pod, the CAST AI Mutating Admission Webhook (in short, mutating webhook) will mutate
workload manifest - for example, adding spot toleration to influence the desired pod placement by the Kubernetes Scheduler.

CAST AI Mutating Admission Webhook presets:

- Spot-only
- Spot-only except `kube-system`
- Partial Spot
- Custom
- [Coming soon] Intelligent placement on Rebalancing

!!! note "Running pods will not be affected"
    The Webhook only mutates pods during scheduling. Over time, all pods should eventually be re-scheduled and, in turn, mutated. The application owners will release a new version of workload that will trigger all the replicas to be rescheduled, Evictor, or Rebalancing will remove older nodes, putting pods for rescheduling, etc.

    If you'd like to initiate mutation for the whole namespace immediately, run this command which will recreate all pods:

    ```shell
    kubectl -n {NAMESPACE} rollout restart deploy
    ```

## Spot-only

Preset `allSpot`.

The Spot-only mutating webhook will mark all workloads in your cluster as suitable for spot instances, causing the autoscaler to prefer spot instances when scaling the cluster up. As this will make cluster more cost-efficient, choosing this mode is recommended for Development and Staging environments, batch job processing clusters, etc. The CAST AI autoscaler will create spot instances only if the pod has "Spot toleration," see [Spot/Preemptible Instances](spot.md). The Mutating Webhook will add the Spot toleration and the Spot node selector to all the workloads being scheduled.

### Install Spot-only

To run all pods (including `kube-system`) on spot instances, use:

```shell
helm upgrade -i --create-namespace -n castai-pod-node-lifecycle castai-pod-node-lifecycle \
    https://storage.googleapis.com/alpha-prereleases/castai-pod-node-lifecycle/castai-pod-node-lifecycle-latest.tgz \
    --set staticConfig.preset=allSpot
```

## Spot-only except `kube-system`

Preset `allSpotExceptKubeSystem`.

This mode works the same as the [Spot-only](#spot-only) mode but it forces all pods in the `kube-system` namespace to be placed on on-demand nodes. This mode is recommended for clusters where the high-availability aspect of the control-plane is vitally important while other pods can tolerate spot interruptions.

### Install Spot-only except `kube-system`

To run all pods excluding `kube-system` on spot instances, use:

```shell
helm upgrade -i --create-namespace -n castai-pod-node-lifecycle castai-pod-node-lifecycle \
    https://storage.googleapis.com/alpha-prereleases/castai-pod-node-lifecycle/castai-pod-node-lifecycle-latest.tgz \
    --set staticConfig.preset=allSpotExceptKubeSystem
```

## Partial Spot

Preset `partialSpot`.

When 100% of pods on spot instances is not a desirable scenario, you can use a ratio like 60% on stable on-demand instances and remaining 40% of pods in same ReplicaSet (Deployment / StatefulSet) running on spot instances. This conservative configuration ensures that there are enough pods on stable compute for the base load, but still allows achieving significant savings for pods above the base load by putting them on spot instances. This setup is recommended for all types of environment, from Production to Development.

### Install Partial Spot

For running 40% workload pods on spot instances and keep remaining pods of same ReplicaSet on on-demand instances, use:

```shell
helm upgrade -i --create-namespace -n castai-pod-node-lifecycle castai-pod-node-lifecycle \
    https://storage.googleapis.com/alpha-prereleases/castai-pod-node-lifecycle/castai-pod-node-lifecycle-latest.tgz \
    --set staticConfig.preset=partialSpot
```

To set a custom ratio for partial Spot, replace 70 with [1-99] as percentage value:

```shell
helm upgrade -i --create-namespace -n castai-pod-node-lifecycle castai-pod-node-lifecycle \
    https://storage.googleapis.com/alpha-prereleases/castai-pod-node-lifecycle/castai-pod-node-lifecycle-latest.tgz \
    --set staticConfig.defaultToSpot=false --set staticConfig.spotPercentageOfReplicaSet=70
```

## Custom

No preset.

This mode can be adjusted to match the needs and requirements of your cluster. Instead of choosing a specific preset, you configure the behavior yourself.

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `staticConfig.defaultToSpot` | boolean | `true` | Should the webhook add spot tolerations and node selectors to pods all pods which don't match other rules? |
| `staticConfig.spotPercentageOfReplicaSet` | int | `0` | The percentage of pods (per ReplicaSet) which should be put on Spot instances. Acceptable values `[1-99]`. `0` means the feature is turned off. |
| `staticConfig.ignorePods` | list of `PodAffinityTerm` | `[]` | Terms describing the label selectors for pods which should be ignored by the webhook. |
| `staticConfig.forcePodsToSpot` | list of `PodAffinityTerm` | `[]` | Terms describing the label selectors for pods which should be put on Spot instances. |
| `staticConfig.forcePodsToOnDemand` | list of `PodAffinityTerm` | `[]` | Terms describing the label selectors for pods which should be put on Spot instances. |

Schema description of the `PodAffinityTerm` object can be found in the official [kubernetes-api documentation](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.21/#podaffinityterm-v1-core). The property `topologyKey` is ignored and the property `namespaceSelector` is not yet supported.

### Install Custom

Here is an example of a `values.yaml` with custom rules defined:

```yaml
staticConfig:
  defaultToSpot: true
  spotPercentageOfReplicaSet: 0
  ignorePods:
    - labelSelector:
        matchLabels:
          app.kubernetes.io/name: ignored-pod
  forcePodsToSpot:
    - labelSelector:
        matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
              - spot-pod-1
              - spot-pod-2
  forcePodsToOnDemand:
    - namespaces:
        - kube-system
```

To install the webhook with these custom rules, execute this command:

```shell
helm upgrade -i --create-namespace -n castai-pod-node-lifecycle castai-pod-node-lifecycle \
    https://storage.googleapis.com/alpha-prereleases/castai-pod-node-lifecycle/castai-pod-node-lifecycle-latest.tgz \
    --values values.yaml
```

## Workload level override

Mutating Webhook is a cluster level configuration, but one can have exceptions that could be enforced per Deployment or StatefulSet.

| Annotation Name                      | Value         | Location                  | Effect                                                                                                    |
|--------------------------------------|---------------|---------------------------|-----------------------------------------------------------------------------------------------------------|
 `scheduling.cast.ai/lifecycle`       | `"on-demand"` | Deployment or StatefulSet | All Pods will be scheduled on on-demand instances                                    |
 `scheduling.cast.ai/lifecycle`       | `"spot"`      | Deployment or StatefulSet | All Pods will be scheduled on spot instances                                                   |
 `scheduling.cast.ai/spot-percentage` | `"65"` [1-99] | Deployment or StatefulSet | Override Partial Spot configuration, schedule up to 65% on spot and remaining (at least 35%) on on-demand |

```shell
kubectl patch deployment resilient-app -p '{"spec": {"template":{"metadata":{"annotations":{"scheduling.cast.ai/lifecycle":"spot"}}}}}'
kubectl patch deployment sensitive-app -p '{"spec": {"template":{"metadata":{"annotations":{"scheduling.cast.ai/lifecycle":"on-demand"}}}}}'
kubectl patch deployment conservative-app -p '{"spec": {"template":{"metadata":{"annotations":{"scheduling.cast.ai/spot-percentage":"50"}}}}}'
```

!!! note ""
Annotation added to Pod is NOT permanent and will not impact Mutation Webhook behaviour.
To set permanent override on workload, one needs to modify Pods Template on the controller (for example Deployment).
Operation will re-create all Deployment Pods.

## Troubleshooting

The mutating webhook will ignore these type of pods:

- Bare pods without ReplicaSet Controller
- Pods in "castai-pod-node-lifecycle" namespace
- Pods with TopologySpreadConstraints with TopologyKey=Lifecycle
- DaemonSets will get Spot Toleration by default, ensuring DaemonSet Pods could run on spot and on-demand nodes

The CAST AI Mutating webhook pods write logs to stdOut.

If cluster has Deployments with 1000+ replicas set higher Memory Requests and Limits, by appending these parameters to Helm command

```shell
--set resources.requests.memory=1G --set resources.limits.memory=1G
```
