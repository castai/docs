---
description: CAST AI Components Hosted On Customers' Clusters
---

# CAST AI Components Hosted On Customers' Clusters

Connecting existing cluster procedure installs several CAST AI components into a cluster.
This is done in phases to provide different levels of experience:

- Phase 1 - is meant to provide visibility around connected clusters without possibility of tuning it; one can think of Phase 1 as about operating in read-only mode.
- Phase 2 - enables all the functionality of CAST AI platform mostly around clusters optimisation; CAST AI platform instructs clusters and Cloud Providers to re-arrange used resources to reach most optimal state.


## Phase 1 Component - CAST AI Kubernetes Agent

CAST AI Agent is the first component installed when a new cluster is connected.
The agent runs as a Pod in a CAST AI dedicated namespace:
```shell
» kubectl get pods -n castai-agent
NAME                            READY   STATUS    RESTARTS   AGE
castai-agent-5559cfb4b6-92rkm   2/2     Running   0          21h
```

There is are two containers running inside that Pod:

- [CAST AI Kubernetes Agent](https://github.com/castai/k8s-agent/) is responsible for sending cluster state data (snapshots) to the main system
- [Cluster Proportional Vertical Autoscaler](https://github.com/kubernetes-sigs/cluster-proportional-vertical-autoscaler/) is responsible for tuning allocated resource for this Pod (self-tuning) based on predefined formula


## Phase 2 Components - Cluster Controller, Evictor, Spot Handler

CAST AI Cluster Controller, Evictor and Spot Handler (installed as DaemonSet, not as a regular Deployment) components are installed when a connected cluster is promoted to Phase 2, which enables cost savings by managing customer's cluster:
```shell
» kubectl get deployments -n castai-agent
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
castai-agent                1/1     1            1           43h
castai-cluster-controller   2/2     2            2           64m
castai-evictor              0/0     0            0           64m
```

- Cluster Controller is responsible for executing actions it receives from the central platform (like for example accept a newly created node to the cluster, etc.)
- Evictor is responsible for removing pods from underutilised nodes to be able to decrease overall amount of cluster nodes
- Spot Handler is responsible for scheduled events monitoring and delivering them to the central platform
