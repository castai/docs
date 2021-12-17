---
description: CAST AI uses your Cloud Service Provider (CSP) accounts to create the cloud resources, optimize cloud costs, and help you go multi cloud.
---

# How it works

The CAST AI engine uses your Cloud Service Provider (CSP) accounts to create the required cloud resources and set up a multi cloud cluster for you.

[Start using multi cloud Kubernetes with a few clicks](../getting-started/overview.md).

## Multi cloud network

- CAST AI uses your owned and provided CSP accounts to create VPCs or Resource Groups (depending on the cloud services you use).

- CAST AI creates the required network (like subnets, public IPs, and VPNs) to ensure a uniform network across created VPCs for a seamless Kubernetes operation.

- Processes behind it help non-compatible clouds merge into a single flat network.

CAST AI selects regions with network latency in mind. For your applications and cluster to function as expected, cross-cloud latency shouldn't go above 10 ms in normal operation. The CAST AI regions were measured to operate in a 5-7 ms range.

## Enter Kubernetes

With the network in place:

- VMs are added to take the role of Kubernetes Masters and Workers. You can add or remove Worker nodes in the [/nodes](../product-overview/console/nodes.md) menu.

- Cluster enters a [reconcilation loop](../concepts/cluster-lifecycle.md#2-reconciliation-healing).

If you delete any resources from the provided CSP accounts manually, CAST AI recreates them to the specification set by you in the console. No instant changes to the cluster are allowed during the time of reconciliation. You can only apply them after the reconciliation.

## Automated cleanup

When you delete a cluster via the [CAST AI console](../product-overview/console/dashboard.md), the operation will terminate all VMs and delete the cloud resources (attached storage, public IPs, VPN connections, network subnets, etc.).

To further understand the lifecycle of a cluster, check our [Cluster lifecycle](../concepts/cluster-lifecycle.md) overview.
