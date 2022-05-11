---
description: What permissions CAST AI components use
---

# Service Accounts used by CAST AI components

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


# Permissions used by CAST AI components

CAST AI components running on customers' clusters require relevant permissions to be able to perform certain functions (like for example sending data about cluster state, etc.).
This section contains detailed description of all required permissions granted to CAST AI components.

## CAST AI Agent (Phase 1)

CAST AI Agent component is installed when a new cluster is connected.
The agent runs as a Pod in a CAST AI dedicated namespace:
```shell
» kubectl get pods -n castai-agent
NAME                            READY   STATUS    RESTARTS   AGE
castai-agent-5559cfb4b6-92rkm   2/2     Running   0          21h
```

There is are two applications running inside that Pod:
- [CAST AI Agent](https://github.com/castai/k8s-agent/) is responsible for sending cluster state data (snapshots) to the main system
- [Cluster Proportional Vertical Autoscaler](https://github.com/kubernetes-sigs/cluster-proportional-vertical-autoscaler/) is responsible for tuning allocated resource for this Pod (self-tuning) based on predefined formula


### Cluster wide permissions used by Agent Pod

Below there is a list of all granted cluster wide permissions which are required to read cluster state data (hence permissions are cluster wide):

| API Group       | Resources                                                                                               | Verbs                  |
|-----------------|:--------------------------------------------------------------------------------------------------------|------------------------|
| core            | pods<br/>nodes<br/>replicationcontrollers<br/>persistentvolumeclaims<br/>persistentvolumes<br/>services | get<br/>list<br/>watch |
| core            | namespaces                                                                                              | get                    |
| apps            | deployments<br/>replicasets<br/>daemonsets<br/>statefulsets                                             | get<br/>list<br/>watch |
| storage.k8s.io  | storageclasses<br/>csinodes                                                                             | get<br/>list<br/>watch |
| batch           | jobs                                                                                                    | get<br/>list<br/>watch |


### Namespace wide (castai-agent) permissions used by Agent Pod

CAST AI Agent's resource consumption vastly depends on the cluster size.
The agent requires possibility to adjust resource limits proportionally to the size of the cluster.
For that purpose Cluster Proportional Vertical Autoscaler patches castai-pod's deployment with re-estimated limits, which requires following permission:

| API Group | Resources                  | Verbs |
|-----------|:---------------------------|-------|
| apps      | deployments (castai-agent) | patch |


## CAST AI Cluster Controller (Phase 2)

CAST AI Cluster Controller component is installed when a connected cluster is promoted to Phase 2, which enables cost savings by managing customer's cluster:
```shell
» kubectl get deployments -n castai-agent
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
castai-agent                1/1     1            1           43h
castai-cluster-controller   2/2     2            2           64m
castai-evictor              0/0     0            0           64m
```


### Cluster wide permissions used by Cluster Controller Pod

Cluster Controller operates mostly on cluster level as it performs operations required to optimize customer clusters' costs:

| API Group                 | Resources                                | Verbs                                            | Description                           |
|---------------------------|:-----------------------------------------|--------------------------------------------------|---------------------------------------|
| core                      | namespace                                | get                                              |                                       |
| core                      | pods, nodes                              | get<br/>list                                     |                                       |
| core                      | nodes                                    | patch<br/>update                                 | Used for node draining and patching   |
| core                      | pods, nodes                              | delete                                           |                                       |
| core                      | pods/eviction                            | create                                           |                                       |
| certificates.k8s.io       | certificatesigningrequests               | get<br/>list<br/>delete<br/>create               |                                       |
| certificates.k8s.io       | certificatesigningrequests/approval      | patch<br/>update                                 |                                       |
| certificates.k8s.io       | signers                                  | approve                                          | Applicable only for kubelet           |
| core                      | events                                   | list<br/>create<br/>patch                        |                                       |
| rbac.authorization.k8s.io | roles, clusterroles, clusterrolebindings | get<br/>patch<br/>update<br/>delete<br/>escalate | Applicable for all CAST AI Components |
| core                      | namespace                                | delete                                           | Applicable only for CAST AI Agent     |


### Namespace wide (castai-agent) permissions used by Cluster Controller Pod

Among many things Cluster Controller performs CAST AI components upgrades.
Cluster Controller is granted with **all permissions in castai-agent namespace** which is required for the current and future updates.
Additionally, Cluster Controller is granted with two cluster wide permissions to be able to manage RBAC of CAST AI components and possibility to delete CAST AI namespace (see above).
