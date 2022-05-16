---
description: What Kubernetes' permissions CAST AI components use
---

# Kubernetes' Service Accounts and permissions used by CAST AI components

CAST AI components running on customers' clusters use predefined Service Accounts and relevant permissions to be able to perform certain functions (like for example sending data about cluster state, etc.).
This section contains detailed description of all required service accounts and permissions granted to CAST AI components.

## Kubernetes Service Accounts used by CAST AI components

Each [CAST AI component](../product-overview/hosted-components.md) installed into customer's cluster uses a dedicated Service Account.
Such setup allows fine-grained permissions tuning for each component:

```shell
» kubectl get serviceAccounts -n castai-agent
NAME                        SECRETS   AGE
castai-agent                1         46h
castai-cluster-controller   1         4h20m
castai-evictor              1         4h20m
castai-spot-handler         1         4h20m
default                     1         46h
```

## CAST AI Kubernetes Agent permissions (Phase 1)

CAST AI Kubernetes Agent must be able to collect cluster operational details (snapshots) and provide them to the central platform to estimate whether there is an optimisation opportunity.
Thus, it must be granted with cluster wide permissions:

| API Group       | Resources                                                                                | Verbs            |
|-----------------|:-----------------------------------------------------------------------------------------|------------------|
| core            | pods, nodes, replicationcontrollers, persistentvolumeclaims, persistentvolumes, services | get, list, watch |
| core            | namespaces                                                                               | get              |
| apps            | deployments, replicasets, daemonsets, statefulsets                                       | get, list, watch |
| storage.k8s.io  | storageclasses, csinodes                                                                 | get, list, watch |
| batch           | jobs                                                                                     | get, list, watch |

CAST AI Kubernetes Agent's resource consumption vastly depends on the cluster size.
The agent requires possibility to adjust resource limits proportionally to the size of the cluster.
For that purpose Cluster Proportional Vertical Autoscaler patches CAST AI Kubernetes Agent's deployment with re-estimated limits, which requires following permission:

| API Group | Resources   | Verbs | Description                                |
|-----------|:------------|-------|--------------------------------------------|
| apps      | deployments | patch | Used only to patch castai-agent deployment |

## CAST AI Cluster Controller (Phase 2)

CAST AI Cluster Controller component is installed when a connected cluster is promoted to Phase 2, which enables cost savings by managing customer's cluster:

```shell
» kubectl get deployments -n castai-agent
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
castai-agent                1/1     1            1           43h
castai-cluster-controller   2/2     2            2           64m
castai-evictor              0/0     0            0           64m
```

### Cluster wide permissions used by Cluster Controller

Cluster Controller operates mostly on cluster level as it performs operations required to optimize customer clusters' costs:

| API Group                 | Resources                                | Verbs                                | Description                                                           |
|---------------------------|:-----------------------------------------|--------------------------------------|-----------------------------------------------------------------------|
| core                      | namespace                                | get                                  |                                                                       |
| core                      | pods, nodes                              | get, list                            |                                                                       |
| core                      | nodes                                    | patch, update                        | Used for node draining and patching                                   |
| core                      | pods, nodes                              | delete                               |                                                                       |
| core                      | pods/eviction                            | create                               |                                                                       |
| certificates.k8s.io       | certificatesigningrequests               | get, list, delete, create            | Used for creating a new certificate when adding a node to the cluster |
| certificates.k8s.io       | certificatesigningrequests/approval      | patch, update                        | Used for creating a new certificate when adding a node to the cluster |
| certificates.k8s.io       | signers                                  | approve                              | Applicable only for kubelet                                           |
| core                      | events                                   | list, create, patch                  |                                                                       |
| rbac.authorization.k8s.io | roles, clusterroles, clusterrolebindings | get, patch, update, delete, escalate | Applicable for all CAST AI Components                                 |
| core                      | namespace                                | delete                               | Applicable only for CAST AI Kubernetes Agent                          |

### Namespace wide (castai-agent) permissions used by Cluster Controller

One of the main task of Cluster Controller is to performs CAST AI components upgrades.
Cluster Controller is granted with **all permissions in castai-agent namespace** which is required for the current and future updates.
Additionally, Cluster Controller is granted with two cluster wide permissions to be able to manage RBAC of CAST AI components and possibility to delete CAST AI namespace (see above).

## CAST AI Evictor (Phase 2)

When a cluster is onboarded with CAST AI for cost optimisation (Phase 2), there are more components installed (not just Cluster Controller).
One other CAST AI components is Evictor - its responsibility is to minimize amount of nodes used by the cluster.

### Cluster wide permissions used by Evictor

When installed Evictor manipulates non CAST AI pods, so it requires a set to cluster wide permissions:

| API Group           | Resources     | Verbs                                           | Description                                                                           |
|---------------------|:--------------|-------------------------------------------------|---------------------------------------------------------------------------------------|
| core                | events        | create, patch                                   |                                                                                       |
| core                | nodes         | get, list, watch, patch, update                 | Used to find a suitable node for eviction                                             |
| core                | pods          | get, list, watch, patch, update, create, delete | List pods to find a suitable node for eviction and delete a stuck pod from a node     |
| apps                | replicasets   | get                                             | Used to find out whether it's safe to evict a pod (it belongs to RS and has replicas) |
| core                | pods/eviction | create                                          | Used for pod eviction                                                                 |
| coordination.k8s.io | leases        | *                                               | Used for leader election when there may be a single instance active                   |
