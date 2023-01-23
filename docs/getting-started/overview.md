---
description: Get started with cost monitoring and cluster autoscaling features for EKS, GKE, AKS or kOps clusters
---

# Overview

CAST AI offers a variaty of advanced cost monitoring and autoscaling features to EKS, GKE, AKS and kOps clusters. By installing the [CAST AI agent](https://github.com/castai/k8s-agent), you can start monitoring the running costs and potential savings of your cluster - and then enable the features that optimize your cluster.

To get started, log into the console and navigate to the **Connect cluster** window.

![img.png](screenshots/connect-cluster.png)

The script will install the agent that will run inside the cluster in read-only mode. After the installation, the agent will collect and analyze your cluster configuration to provide the most optimal setup along with a savings estimation for your current cloud environment. You will also get insights of your cluster's security state.

To start saving costs, turn the automatic optimization on when you're ready.

Connect your cluster:

- [AWS EKS](eks/eks.md)
- [GCP GKE](gke/gke.md)
- [Azure AKS](aks/aks.md)
- [kOps](kops/kops.md)
