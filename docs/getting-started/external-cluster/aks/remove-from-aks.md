---
description: Time to say goodbye? You can choose from two different options to remove CAST resources based on how you used CAST AI in your cluster.
---

# Remove CAST resources from AKS cluster

Based on the way how CAST was used on a cluster there are two options to remove CAST resources.

## Disconnect AKS cluster

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
