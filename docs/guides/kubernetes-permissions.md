---
description: What Kubernetes' permissions CAST AI components use
---

# Kubernetes Service Accounts used by CAST AI components

Dedicated Service Accounts are created for each CAST AI component when installing them:
```shell
» kubectl get serviceAccounts -n castai-agent
NAME                        SECRETS   AGE
castai-agent                1         46h
castai-cluster-controller   1         4h20m
castai-evictor              1         4h20m
castai-spot-handler         1         4h20m
default                     1         46h
```


# Kubernetes' permissions used by CAST AI components

CAST AI components running on customers' clusters require relevant permissions to be able to perform certain functions (like for example sending data about cluster state, etc.).
This section contains detailed description of all required permissions granted to CAST AI components.


## CAST AI Agent permissions

The Agent must be able to collect cluster operational details (snapshots) and provide them to the central platform to estimate whether there is an optimisation opportunity.
Thus, it must be granted with cluster wide permissions:

| API Group       | Resources                                                                                               | Verbs                  |
|-----------------|:--------------------------------------------------------------------------------------------------------|------------------------|
| core            | pods<br/>nodes<br/>replicationcontrollers<br/>persistentvolumeclaims<br/>persistentvolumes<br/>services | get<br/>list<br/>watch |
| core            | namespaces                                                                                              | get                    |
| apps            | deployments<br/>replicasets<br/>daemonsets<br/>statefulsets                                             | get<br/>list<br/>watch |
| storage.k8s.io  | storageclasses<br/>csinodes                                                                             | get<br/>list<br/>watch |
| batch           | jobs                                                                                                    | get<br/>list<br/>watch |


CAST AI Agent's resource consumption vastly depends on the cluster size.
The agent requires possibility to adjust resource limits proportionally to the size of the cluster.
For that purpose Cluster Proportional Vertical Autoscaler patches Agent's deployment with re-estimated limits, which requires following permission:

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

| API Group                 | Resources                                      | Verbs                                            | Description                                                           |
|---------------------------|:-----------------------------------------------|--------------------------------------------------|-----------------------------------------------------------------------|
| core                      | namespace                                      | get                                              |                                                                       |
| core                      | pods<br/>nodes                                 | get<br/>list                                     |                                                                       |
| core                      | nodes                                          | patch<br/>update                                 | Used for node draining and patching                                   |
| core                      | pods<br/>nodes                                 | delete                                           |                                                                       |
| core                      | pods/eviction                                  | create                                           |                                                                       |
| certificates.k8s.io       | certificatesigningrequests                     | get<br/>list<br/>delete<br/>create               | Used for creating a new certificate when adding a node to the cluster |
| certificates.k8s.io       | certificatesigningrequests/approval            | patch<br/>update                                 | Used for creating a new certificate when adding a node to the cluster |
| certificates.k8s.io       | signers                                        | approve                                          | Applicable only for kubelet                                           |
| core                      | events                                         | list<br/>create<br/>patch                        |                                                                       |
| rbac.authorization.k8s.io | roles<br/>clusterroles<br/>clusterrolebindings | get<br/>patch<br/>update<br/>delete<br/>escalate | Applicable for all CAST AI Components                                 |
| core                      | namespace                                      | delete                                           | Applicable only for CAST AI Agent                                     |


### Namespace wide (castai-agent) permissions used by Cluster Controller

Among many things Cluster Controller performs CAST AI components upgrades.
Cluster Controller is granted with **all permissions in castai-agent namespace** which is required for the current and future updates.
Additionally, Cluster Controller is granted with two cluster wide permissions to be able to manage RBAC of CAST AI components and possibility to delete CAST AI namespace (see above).


## CAST AI Evictor (Phase 2)

When a cluster is onboarded with CAST AI for cost optimisation (Phase 2), there are more components installed (not just Cluster Controller).
One other CAST AI components is Evictor - its responsibility is to minimize amount of nodes used by the cluster.

### Cluster wide permissions used by Evictor

When installed Evictor manipulates non CAST AI pods, so it requires a set to cluster wide permissions:

| API Group           | Resources     | Verbs                                                             | Description                                                                           |
|---------------------|:--------------|-------------------------------------------------------------------|---------------------------------------------------------------------------------------|
| core                | events        | create<br/>patch                                                  |                                                                                       |
| core                | nodes         | get<br/>list<br/>watch<br/>patch<br/>update                       | Used to find a suitable node for eviction                                             |
| core                | pods          | get<br/>list<br/>watch<br/>patch<br/>update<br/>create<br/>delete | List pods to find a suitable node for eviction and delete a stuck pod from a node     |
| apps                | replicasets   | get                                                               | Used to find out whether it's safe to evict a pod (it belongs to RS and has replicas) |
| core                | pods/eviction | create                                                            | Used for pod eviction                                                                 |
| coordination.k8s.io | leases        | *                                                                 | Used for leader election when there may be a single instance active                   |
