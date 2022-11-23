---
description: Time to say goodbye? You can choose from two different options to remove CAST resources based on how you used CAST AI in your cluster.
---

# Remove CAST resources from AKS cluster

Based on the way how CAST was used on a cluster there are two options to remove CAST resources.

## Disconnect read only agent

In order to disconnect your cluster from CAST AI click **Disconnect cluster** button in **Clusters** list and follow the guidance.  Alternatively run following command from your terminal used to access the cluster:

```bash
kubectl delete namespace castai-agent
```

On top of that, also delete following kubernetes objects related to `castai-agent` agent:

```bash
clusterrole.rbac.authorization.k8s.io/castai-agent
clusterrolebinding.rbac.authorization.k8s.io/castai-agent
```

Once cluster is disconnected its `Status` will change to `Disconnected` and you can choose to remove it from console by pressing **Delete cluster** button.

!!! note ""
    Cluster will continue to run as normal, since **Delete cluster** action only removes it from CAST AI console.

## Removing CAST AI credentials and other resources

When CAST was used to to optimize AKS cluster following resources were created:

- CAST AI agent deployment
- Cluster controller
- Spot handler
- Evictor
- Custom role
- App registration and secret
- Service principal

To remove them follow the steps outlined below.

### Prerequisites

In order to remove these resources first of all:

- Go to CAST AI console → **Autoscaler** page → Disable all CAST AI policies
- Disconnect the cluster by clicking **Disconnect cluster** button and following the guidance

With above mentioned pre-requisites completed please follow next steps in Azure portal to remove CAST resources from your cluster:

### Delete node pools

Go to Kubernetes services → your cluster → Node pools → find 2 node pools named "castpool" and "castworkers" and delete them.

### Delete app registration

Go to App registrations → Search for "CAST.AI *cluster-name*" application and delete it.
