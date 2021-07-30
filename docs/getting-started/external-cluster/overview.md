---
description: Explore how external cluster management brings CAST AI features to externally managed clusters in EKS, GKE or AKS.
---

# External Cluster Overview

External cluster management brings CAST AI features, like autoscaler, to an externally managed clusters, like EKS, GKE
or AKS. By installing CAST AI agent, you start observing cluster running costs and potential savings; you can then
enable features that optimize your cluster - like adding and removing nodes, or right-sizing deployments. To get started,
login to the console and navigate to **Connect cluster** window.

![img.png](../screenshots/connect-cluster.png)

Script will install the agent that will run inside the cluster in read-only mode. After installation, agent will collect
and analyze your cluster configuration to provide most optimal setup along with savings estimation for your current
cloud environment. To start saving costs, turn on the automatic optimization when ready.

Connect your cluster:

- [AWS EKS](./eks/eks.md)
- [GCP GKE](./gke/gke.md)
- AKS (Coming soon)
