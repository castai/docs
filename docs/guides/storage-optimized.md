---
description: CAST AI supports running your workloads on Storage Optimized instances. This guide helps you configure and run it.
---

# Storage Optimized Instances

Storage optimized instances are specific instance types, designed for workloads that require high, sequential read and write access to very large data sets on local storage. They are optimized to deliver a huge amount of low-latency, random I/O operations per second (IOPS) to applications. This makes them a better choice for performance compared to other cloud services.

There are multiple instances available in the supported providers (GCS and AWS so far) and they can provide network performance, SSD I/O performance, NVMe volumes, etc. For an extended specification and instructions about the instances available and their features, please refer to the following official documentation:

Storage options

- AWS: [Storage optimized instances](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/storage-optimized-instances.html)
- GCS: [Local SSD disks](https://cloud.google.com/compute/docs/disks#localssds)

The CAST AI autoscaler supports running your workloads on Storage Optimized instances.
The following guide will help you configure and run it.

## Pricing

### GCS

Because local SSDs can only be purchased in 375 GB increments, the cost-per-month for a single device is the monthly rate multiplied by 375 GB. For example, at a monthly rate of $0.080, the cost would be $30.00 per device per month. Actual data storage and usage are included in that price and there is no additional charge for local traffic between the virtual machine and the local SSD device. [Local SSD prices](https://cloud.google.com/compute/disks-image-pricing#localssdpricing) differ by region.

You can reserve local SSDs in a specific zone, with or without a commitment. Without a commitment, you pay normal on-demand prices. For committed-use discounted pricing for local SSDs, a reservation must be created when purchasing the commitment. For more information, see [Reserving zonal resources](https://cloud.google.com/compute/docs/instances/reserving-zonal-resources).

Spot prices apply to local SSDs attached to [Spot VMs](https://cloud.google.com/compute/docs/instances/spot) (or preemptible VMs). Spot prices provide smaller discounts for local SSDs than for machine types and GPUs. Local SSDs attached to Spot VMs are not eligible for other discounts.

### AWS

In the case of AWS, the price is associated with the type of instance and the type of plan chosen, which can be: On-Demand, Savings Plans, Reserved Instances, Spot Instances or Dedicated Hosts.

Please refer to [official pricing source](https://aws.amazon.com/ec2/pricing/) to know more.

## Available configurations

To make use of the storage-optimized feature, node selectors, taints and tolerations work together to ensure that pods are scheduled into inappropriate nodes and viceversa.

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
