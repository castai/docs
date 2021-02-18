# How it works

CAST AI engine uses your Cloud Service Provider (CSP) accounts to create the required cloud resources and set up a multi cloud cluster for you. You can start using multi cloud Kubernetes with just a few clicks - check out [Getting started](../getting-started.md).

## Multi cloud network

1. CAST AI uses your owned and provided CSP accounts to create VPCs or Resource Groups (depending on which cloud services you use).
2. CAST AI creates the required network (like subnets, public IPs, and VPNs) to ensure a uniform network across created VPCs for a seamless Kubernetes operation.
3. Processes behind help non-compatible clouds merge into a single flat network.

CAST AI selects regions with network latency in mind. For your applications and the cluster to function as expected, cross-cloud latency shouldn't go above 10 ms in normal operation. The CAST AI regions were measured to operate in a 5-7 ms range.

## Enter Kubernetes

With the network in place:

4. VMs are added to take the role of Kubernetes Masters and Workers. You can add or remove Worker nodes in [/nodes](../console-overview/console-overview.md#nodes) menu. 
6. Cluster enters a [reconcilation loop](../concepts/cluster-lifecycle.md#2-reconciliation-healing).

If you delete any resources from the provided CSP accounts manually, CAST AI recreates them to the specification provided by you in the console. During the time of reconciliation, no instant changes to the cluster are allowed. You can only apply them after the reconciliation.

## Automated cleanup

When you delete a cluster via the [CAST AI console](../console-overview/console-overview.md#dashboard) - the operation will terminate all VMs and delete cloud resources (attached storage, public IPs, VPN connections, network subnets, etc.).

To further understand the lifecycle of a cluster - check our [Cluster lifecycle](../concepts/cluster-lifecycle.md) overview.
