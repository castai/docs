---
description: What permissions CAST AI components use
---

# Permissions used by CAST AI components

CAST AI components running on customers' clusters require relevant permissions to be able to perform certain functions (like for example sending data about cluster state, etc.).
This section contains detailed description of all required permissions granted to CAST AI components.

## CAST AI Agent

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


### Namespace wide permissions used by Agent Pod

CAST AI Agent's resource consumption vastly depends on the cluster size.
The agent requires possibility to adjust resource limits proportionally to the size of the cluster.
For that purpose Cluster Proportional Vertical Autoscaler patches castai-pod's deployment with re-estimated limits, which requires following permission:

| API Group | Resources                  | Verbs |
|-----------|:---------------------------|-------|
| apps      | deployments (castai-agent) | patch |
