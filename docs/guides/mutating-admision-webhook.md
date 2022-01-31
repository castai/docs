---
description: Information on how to put workloads on spot instances without modification
---
# Mutating Admission Webhook

Modifying workload manifests to achieve the desired savings takes time and effort. The CAST AI Mutating Admission Webhook slightly
modifies workload manifests on-the-fly. It's a quick and effortless way to achieve savings without modifying every workload.

Whenever there's a request to schedule a pod, the CAST AI Mutating Admission Webhook (in short, mutating webhook) will mutate
workload manifest - for example, adding spot toleration to influence the desired pod placement by the Kubernetes Scheduler.

CAST AI Mutating Admission Webhook modes:

- Spot-only
- Partial Spot
- [Coming soon] Intelligent placement on Rebalancing

## Spot-only

The Spot-only mutating webhook will mark all workloads in your cluster as suitable for spot instances, causing the autoscaler to prefer
spot instances when scaling the cluster up. As this will make cluster more cost-efficient, choosing this mode is recommended
for Development and Staging environments, batch job processing clusters, etc. The CAST AI autoscaler will create spot instances
only if the pod has "Spot toleration," see [Spot/Preemptible Instances](spot.md). The Mutating Webhook will add Spot toleration to
all the workloads being scheduled.

### Install Spot-only mutating webhook

To run all pods (including kube-system) on spot instances, use:

```shell
helm upgrade -i --create-namespace -n castai-pod-node-lifecycle castai-pod-node-lifecycle \
    https://storage.googleapis.com/alpha-prereleases/castai-pod-node-lifecycle/castai-pod-node-lifecycle-latest.tgz \
    --set staticConfig.preset=allSpot
```

To run all workload pods (excluding kube-system) on spot instances, use:

```shell
helm upgrade -i --create-namespace -n castai-pod-node-lifecycle castai-pod-node-lifecycle \
    https://storage.googleapis.com/alpha-prereleases/castai-pod-node-lifecycle/castai-pod-node-lifecycle-latest.tgz \
    --set staticConfig.preset=allSpotExceptKubeSystem
```

To run all workload pods on spot instances, use this (but exclude list of Namespaces):

```shell
helm upgrade -i --create-namespace -n castai-pod-node-lifecycle castai-pod-node-lifecycle \
    https://storage.googleapis.com/alpha-prereleases/castai-pod-node-lifecycle/castai-pod-node-lifecycle-latest.tgz \
    --set staticConfig.defaultToSpot=true --set 'staticConfig.forcePodsToOnDemand={kube-system/.*,another-namespace/.*}'
```

Note: The existing running pods will not be affected. The Webhook only mutates pods during scheduling. Over time, all pods
should eventually be re-scheduled and, in turn, mutated. The application owners will release a new version of workload that
will trigger all the replicas to be rescheduled, Evictor, or Rebalancing will remove older nodes, putting pods for rescheduling,
etc.  

If you'd like to initiate mutation for the whole namespace quickly, run this command:

```shell
kubectl -n {NAMESPACE} rollout restart deploy
```

## Partial Spot

When 100% of pods on spot instances is not a desirable scenario, you can use a ratio like 60% on stable on-demand instances and
remaining 40% of pods in same ReplicaSet (Deployment / StatefulSet) running on spot instances. This conservative configuration
ensures that there are enough pods on stable compute for the base load, but still allows achieving significant savings for pods
above the base load by putting them on spot instances. This setup is recommended for all types of environment, from Production to Development.

### Install partial Spot mutating webhook

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
