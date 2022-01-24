---
description: Information on how to put workloads on Spot instances without modification
---
# Mutating Admission Webhook

It takes time and effort to modify workload manifests to achieve desired savings. CAST AI Mutating Admission Webhook slightly
modifies workload manifests on-the-fly. It is a quick and effortless way to achieve savings without modifying each workload.

When ever there is a request to schedule a Pod, CAST AI Mutating Admission Webhook (mutating webhook for short) will mutate
workload manifest, for example add spot toleration, to influence desired Pod placement by Kubernetes Scheduler.

CAST AI Mutating Admission Webhook modes:

- Spot-only
- Partial Spot
- [Soon] Intelligent placement on Rebalancing

## Spot-only

Spot-only mutating webhook will mark all workloads in your cluster as suitable for spot instances, making autoscaler prefer
spot instances when upscaling the cluster. As this will make cluster most cost-efficient, choosing this mode is recommended
for Development, Staging environments, batch job processing clusters, etc. The CAST AI autoscaler will create Spot instances
only if Pod has "Spot toleration", see [Spot/Preemptible Instances](spot.md). Mutating Webhook will add Spot toleration to
all workloads being scheduled.

### Install Spot only mutating webhook

Running all Pods (including kube-system) on Spot instances:

```shell
helm upgrade -i --create-namespace -n castai-pod-node-lifecycle castai-pod-node-lifecycle \
    https://storage.googleapis.com/alpha-prereleases/castai-pod-node-lifecycle/castai-pod-node-lifecycle-latest.tgz \
    --set staticConfig.preset=allSpot
```

For running all workload Pods (excluding kube-system) on Spot instances use:

```shell
helm upgrade -i --create-namespace -n castai-pod-node-lifecycle castai-pod-node-lifecycle \
    https://storage.googleapis.com/alpha-prereleases/castai-pod-node-lifecycle/castai-pod-node-lifecycle-latest.tgz \
    --set staticConfig.preset=allSpotExceptKubeSystem
```

For running all workload Pods on Spot instances use, but exclude list of Namespaces:

```shell
helm upgrade -i --create-namespace -n castai-pod-node-lifecycle castai-pod-node-lifecycle \
    https://storage.googleapis.com/alpha-prereleases/castai-pod-node-lifecycle/castai-pod-node-lifecycle-latest.tgz \
    --set staticConfig.defaultToSpot=true --set 'staticConfig.forcePodsToOnDemand={kube-system/.*,another-namespace/.*}'
```

Note: existing running pods will not be affected. Webhook only mutates pods during during scheduling. Over time all pods should eventually be re-scheduled and in turn mutated,
application owners will release new version of workload, which will triggering all replicas to be rescheduled, Evictor or Rebalancing
will remove older nodes, putting Pods for rescheduling etc. If one wants to initiate mutation for whole namespace quickly run this command:

```shell
kubectl -n {NAMESPACE} rollout restart deploy
```

## Partial Spot

When 100% of Pods on Spot instances is not desirable, but some ratio like 60% on stable on-demand instances and
remaining 40% of Pods in same ReplicaSet (Deployment / StatefulSet) on Spot instances. This conservative configuration
ensures there is enough Pods on stable compute for the base load, but still allows achieving significant savings for Pods
above base load by putting them on Spot instances. Recommended for all types of environment from Production to Development.

### Install partial Spot mutating webhook

For running 40% workload Pods on Spot instances and keep remaining Pods of same ReplicaSet on on-demand use:

```shell
helm upgrade -i --create-namespace -n castai-pod-node-lifecycle castai-pod-node-lifecycle \
    https://storage.googleapis.com/alpha-prereleases/castai-pod-node-lifecycle/castai-pod-node-lifecycle-latest.tgz \
    --set staticConfig.preset=partialSpot
```

To set custom ratio for partial Spot, replace 70 with [1-99] as percentage value:

```shell
helm upgrade -i --create-namespace -n castai-pod-node-lifecycle castai-pod-node-lifecycle \
    https://storage.googleapis.com/alpha-prereleases/castai-pod-node-lifecycle/castai-pod-node-lifecycle-latest.tgz \
    --set staticConfig.defaultToSpot=false --set staticConfig.spotPercentageOfReplicaSet=70
```

## Troubleshooting

Mutating webhook will ignore these type of Pods:

- Bare Pods without ReplicaSet Controller
- Pods in "castai-pod-node-lifecycle" namespace
- Pods with TopologySpreadConstraints with TopologyKey=Lifecycle

CAST AI Mutating webhook Pods write logs to stdOut
