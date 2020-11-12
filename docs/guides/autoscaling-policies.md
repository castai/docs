# Autoscaling policies

Autoscaling policies define a set of rules based on which your cluster is being monitored and scaled to maintain steady
performance at the lowest cost possible.

This topic describes available policy configuration options as well as provides guidance on how to configure them.

## Prerequisites

To enable autoscaling policies you need to create a cluster first. Here's how to create one: [Creating your first
cluster](https://castai.github.io/docs/getting-started/creating-your-first-cluster/).

To see available policy settings, select your cluster and navigate to _Policies_ on
[CAST AI's console](https://console.cast.ai/):

![](autoscaling-policies/policies.png)

## Cluster CPU limits policy

Each CAST AI's cluster size can be limited by **the total amount** of vCPUs available on all worker nodes
used to run workloads.
If disabled, the cluster will be able to upscale indefinitely, and downscale to 0 worker nodes depending on the actual
resource consumption.

### Configuring CPU limits policy

Cluster CPU limits settings can be adjusted either via [CAST AI's console:](https://console.cast.ai/)

![](autoscaling-policies/cluster_size.png)

or via [CAST AI's policies API endpoint](https://api.cast.ai/v1/spec/#/cluster-policies/UpsertPolicies) by setting
values for

```json
"clusterLimits": {
    "cpu": {
      "maxCores": <value>,
      "minCores": <value>
    },
    "enabled": <value>
}
```

The new settings will propagate immediately.

## Horizontal pod autoscaler (HPA) policy

See HPA documentaion for a detailed overview.

## Unscheduled pods policy

A pod becomes unschedulable when the Kubernetes scheduler is unable to find a node that can accommodate the pod.
For instance, a pod can request more CPU or memory than it is available on any of the worker nodes.
In many of the cases, this indicates a need to scale up by adding additional nodes to the cluster.
CAST AI's autoscaler is equipped with a mechanism to handle this case.

After receiving unschedulable pods event, best price/performance ratio node will be selected by the CAST AI's
recommendation engine which would be able to accommodate all currently unschedulable pods.
It will then be provisioned and joined to the cluster. This process usually takes a few minutes depending on which cloud
 service provider was picked.
Currently, only a single node will be added at a time. If there are still unschedulable pods remaining, the cycle is
repeated until all pods are scheduled if the reason was insufficient resources.

### Configuring unscheduled pods policy

You can enable/disable unschedulable pods policy either on [CAST AI's console:](https://console.cast.ai/):

![](autoscaling-policies/unschedulable_pods.png)

or via [CAST AI's policies API endpoint](https://api.cast.ai/v1/spec/#/cluster-policies/UpsertPolicies) by setting
values for

```json
"unschedulablePods": {
    "enabled": <value>,
    "evaluationPeriodSeconds": <value>
}
```

It may take a few minutes for the new settings to propagate.

## Cluster CPU utilization scale up policy

Increased CPU load on worker nodes indicates that the cluster is getting 'hot' - the current fleet of nodes might not
be sufficient to fulfil current computing resources needs.
In that case, computing capacity can be increased by adding in additional worker nodes.
CAST AI's cluster autoscaler provides mechanism to handle this with _CPU utilization scale up policy_.
Having this policy applied, your cluster is periodically checked for the actual CPU consumption over the worker nodes.
When sustained increased CPU load is detected, autoscaler automatically adds a new node to try to redistribute load
more evenly.
Depending on the underlying cloud service provider, this process can take a few minutes. Meanwhile, autoscaler will
not attempt to add a new node if addition is already in progress.

### Configuring CPU utilization scale up policy

Autoscaler's scale up policy is set by adjusting thresholds for average cluster CPU load in percentages and evaluation
period in seconds.
Evaluation window describes for how long the average cluster CPU utilization should stay above the threshold for it to
be considered eligible for scale up.

You can edit settings for this policy via [CAST AI's console](https://console.cast.ai/):

![](autoscaling-policies/cpu_scale_up.png)

or [CAST AI's policies API endpoint](https://api.cast.ai/v1/spec/#/cluster-policies/UpsertPolicies) by setting values
for

```json
"cpuUtilization": {
    "scaleUpThreshold": {
      "avgCpuLoadPercentageMoreThan": <value>,
      "enabled": <value>,
      "evaluationPeriodSeconds": <value>
    }
}
```

It may take a few minutes for the new settings to propagate.

## Cluster CPU utilization scale down policy

CAST AI's node autoscaler decreases the size of the cluster when some worker nodes are consistently unneeded for a
significant amount of time.
A node is considered unneeded when it has low actual CPU utilization. On the event of scale down a node will be drained
and removed from a cluster if:

* other worker nodes meet the resources (CPU, memory) demand of the pods currently running.
* it doesn't contain any pods with volumes attached - the node is stateless.
* it doesn't contain pods with restrictive.
[PodDisruptionBudget](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/#pod-disruption-budgets)
* it doesn't contain pods that cannot be moved elsewhere due to node selection constraints (non-matching node selectors
 or affinity, matching anti-affinity, etc.)

If autoscaler fails to find worker nodes eligible for deletion, cluster's state would not be affected.
Otherwise, only a single node at a time will be attempted to be removed. In that case, autoscaler issues termination of
 the underlying instance in a cloud-provider-dependent manner.
This process usually takes a few minutes.
  
### Configuring CPU utilization scale down policy

You can control autoscaler's scale down policy by adjusting thresholds for average cluster CPU load in percentages and
 evaluation period in seconds.
Evaluation window describes for how long should the average cluster CPU utilization stay below threshold for it to be
 considered eligible for scale down.

Scale down policy settings can be adjusted via  [CAST AI's console:](https://console.cast.ai/):

![CPU scale down](autoscaling-policies/cpu_scale_down.png)

or [CAST AI's policies API endpoint](https://api.cast.ai/v1/spec/#/cluster-policies/UpsertPolicies) by setting values
 for

```json
"cpuUtilization": {
    "scaleDownThreshold": {
      "avgCpuLoadPercentageLessThan": <value>,
      "enabled": <value>,
      "evaluationPeriodSeconds": <value>
    }
}
```  

It may take a few minutes for the new settings to propagate.

## Policies precedence rules

If multiple policies are enabled and multiple rules were triggered during the same evaluation period, they will be
handled in the following order:

* [Cluster CPU limits policy](#cluster-cpu-limits-policy)
* [Horizontal Pod Autoscaler (HPA) policy](#horizontal-pod-autoscaler-hpa-policy)
* [Unscheduled pods policy](#unscheduled-pods-policy)
* [Cluster CPU utilization scale up policy](#cluster-cpu-utilization-scale-up-policy)
* [Cluster CPU utilization scale-down policy](#cluster-cpu-utilization-scale-down-policy)
