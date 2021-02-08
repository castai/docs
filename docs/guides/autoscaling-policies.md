# Autoscaling policies

Autoscaling policies define a set of rules based on which your cluster is monitored and scaled to maintain steady
performance at the lowest possible cost.

This topic describes the available policy configuration options and provides guidance on how to configure them.

## Prerequisites

To enable the autoscaling policies, you need to create a cluster first. Here's a guide that shows you how to create a cluster: [Creating your first
cluster](../getting-started/creating-your-first-cluster.md).

To see the available policy settings, select your cluster and navigate to _Policies_ on
[CAST AI's console](https://console.cast.ai/):

![](autoscaling-policies/policies.png)

## Cluster CPU limits policy

Each CAST AI cluster size can be limited by **the total amount** of vCPUs available on all the worker nodes
used to run workloads.
If disabled, the cluster can upscale indefinitely and downscale to 0 worker nodes, depending on the actual
resource consumption.

### Configuring CPU limits policy

You can adjust a cluster's CPU limits settings either via the [CAST AI console:](https://console.cast.ai/)

![](autoscaling-policies/cluster_size.png)

or via the [CAST AI policies API endpoint](https://api.cast.ai/v1/spec/#/cluster-policies/UpsertPolicies) by setting
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

## Horizontal Pod Autoscaler (HPA) policy

See [HPA documentation](pod-autoscaler/hpa.md) for a detailed overview.

## Unscheduled pods policy

A pod becomes unschedulable when the Kubernetes scheduler can't find a node that can accommodate the pod.
For instance, a pod can request more CPU or memory than the resources available on any of the worker nodes.
In many such cases, this indicates the need to scale up by adding additional nodes to the cluster.
The CAST AI autoscaler is equipped with a mechanism to handle this.

### Headroom attributes

Headroom is a buffer of spare capacity (in terms of both memory and CPU) to ensure that cluster is capable
to meet suddenly increased demand for resources. It is based on the currently
available total worker nodes resource capacity. For example, if headroom for memory and CPU are both set to 10%, 
and cluster consists of 2 worker nodes equipped with 2 cores and 4GB RAM each, _a total of 0.4 cores and 819MB_ 
would be considered as headroom in the next cluster size increase phase.

### Provisioning decision

After receiving the unschedulable pods event, the CAST AI recommendation engine will select the best 
price/performance ratio node able to accommodate all of the currently unschedulable pods plus headroom.
CAST AI will then provision it and join with the cluster. This process usually takes a few minutes, depending on the cloud service provider of your choice.
Currently, only a single node will be added at a time. If any unschedulable pods still remain, the cycle is
repeated until all the pods are scheduled (provided that the reason was insufficient resources).

### Configuring the unscheduled pods policy

You can enable/disable the unschedulable pods policy and set headroom settings either on the [CAST AI console](https://console.cast.ai/):

![](autoscaling-policies/unschedulable_pods.png)

or via the [CAST AI policies API endpoint](https://api.cast.ai/v1/spec/#/cluster-policies/UpsertPolicies) by setting
values for

```json
"unschedulablePods": {
    "enabled": <value>,
    "headroom": {
        "cpuPercentage": <value>,
        "memoryPercentage": <value>
    }
}
```

It may take a few minutes for the new settings to propagate.

## Policies precedence rules

If multiple policies are enabled and multiple rules are triggered during the same evaluation period, they will be
handled in the following order:

* [Cluster CPU limits policy](#cluster-cpu-limits-policy)
* [Horizontal Pod Autoscaler (HPA) policy](#horizontal-pod-autoscaler-hpa-policy)
* [Unscheduled pods policy](#unscheduled-pods-policy)
* [Cluster CPU utilization scale up policy](#cluster-cpu-utilization-scale-up-policy)
