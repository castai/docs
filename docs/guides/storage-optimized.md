---
description: CAST AI supports running your workloads on Storage Optimized instances. This guide helps you configure and run it.
---

# Storage Optimized Instances

The CAST AI autoscaler supports running your workloads on Storage Optimized instances.
This guide will help you configure and run it.

## Available configurations

### Tolerations

**When to use:** Storage Optimized instances are optional

When a pod is marked only with `tolerations,` the Kubernetes scheduler could place such a pod/pods on regular nodes as well.

```yaml
tolerations:
  - key: scheduling.cast.ai/storage-optimized
    operator: Exists
```

### Node Selectors

**When to use:** only use Storage Optimized instances

If you want to make sure that a pod is scheduled on Storage Optimized instances only, add `nodeSelector` as well as per the example below.
The autoscaler will then ensure that only a Storage Optimized instance is picked whenever your pod requires additional workload in the cluster.

```yaml
tolerations:
  - key: scheduling.cast.ai/storage-optimized
    operator: Exists
nodeSelector:
  scheduling.cast.ai/storage-optimized: "true"
```
