---
description: Time to say goodbye? You can choose from two different options to remove CAST resources based on how you used CAST AI in your cluster.
---

# Remove CAST resources from GKE cluster

Based on the way how CAST was used on a cluster there are two options to remove CAST resources.

## Disconnect GKE cluster

In order to disconnect your cluster from CAST AI click **Disconnect cluster** button in **Clusters** list and follow the guidance.  Alternatively run following command from your terminal used to access the cluster:

```bash
kubectl delete deployment castai-agent -n castai-agent
```

On top of that, also delete following kubernetes objects related to `castai-agent` agent:

- namespace
- serviceaccount and secret
- clusterrole and clusterrolebinding
- role and rolebinding
- resourcequota
- configmap

Once cluster is disconnected its `Status` will change to `Disconnected` and you can choose to remove it from console by pressing **Delete cluster** button.

!!! note ""
    Cluster will continue to run as normal, since **Delete cluster** action only removes it from CAST AI console.

## Removing CAST AI credentials and other resources

### Prerequisites

In order to remove these resources first of all:

- Go to CAST AI console → **Policies** page → Disable all CAST AI policies
- Connect to your cluster from the terminal and run command:

```bash
kubectl delete deployment castai-agent -n castai-agent
```

With above mentioned pre-requisites completed please follow next steps in GCP Console to remove CAST resources from your running cluster:

### Delete Service Account

Go to GCP console → Identity and Access Management (IAM) → Service Accounts → find `Service account to manage *cluster-name* GKE cluster via CAST` and delete it
