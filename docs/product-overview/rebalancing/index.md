---
description: Check how CAST AI rebalancing allows you to automatically distribute your workloads hustle free.
---

# Rebalancing

Rebalancing is a CAST AI feature that allows your clusters to reach the most cost-efficient state. Rebalancing is a process which replaces suboptimal nodes with new ones and moves the workloads automatically.

!!! tip ""
    To unlock this feature you will need to connect your cluster & use full autoscaler. See - [External Cluster Overview](../../getting-started/overview.md).

## How it works

Rebalancing works by taking all the workloads running in your cluster and finding the most optimal ways they can be distributed amongst the cheapest nodes. Rebalancing is based on the same algorithms that drive the [CAST AI autoscaler](../../guides/autoscaling-policies.md) to find optimal node configurations for your workloads. The only difference is that all workloads are run through them, rather than just unschedulable pods. The rebalancing process has multiple purposes:

1. Rebalance the cluster during the initial onboarding to immediately achieve cost savings. The rebalancer aims to make it easy to start using CAST AI by running your cluster through the CAST AI algorithms and reshaping your cluster into an optimal state during onboarding.
2. Remove fragmentation which is a normal byproduct of everyday cluster execution. The [CAST AI autoscaler](../../guides/autoscaling-policies.md) is a reactive autoscaling process which aims to satisfy unschedulable pods. As these reactive decisions accumulate, your cluster might become too fragmented. Consider this example: you are upscaling your workloads by 1 replica every hour. That replica is requesting 6 CPU. The cluster will end up with 24 new nodes with 8 CPU capacity each after a day. This means that you will have 48 unused fragmented CPUs. The rebalancer aims to solve this by consolidating the workloads into fewer cheaper nodes, reducing waste.

Only nodes which don't have any problematic workloads will be rebalanced. Learn more about problematic workloads in the [Preparation](preparation.md) section.
