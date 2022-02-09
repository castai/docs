---
description: Guide on how to scrape CAST AI metrics
---

# CAST AI cluster metrics integration

CAST AI exposes Prometheus metrics api endpoint for integration with your existing Prometheus monitoring stack.

## Setup guide

1. Create readonly CAST AI API key via Console UI.

2. Configure Prometheus scrape job:

   - Replace `{apiKey}` with your api key.

```yaml
scrape_configs:
  - job_name: 'castai_cluster_metrics'
    scrape_interval: 15s
    scheme: https
    static_configs:
      - targets: ['api.cast.ai']
    metrics_path: '/v1/metrics/prom'
    authorization:
      type: 'Token'
      credentials: '{apiKey}'
    # Optional filter by clusters. Field clusterName is the same as on GET /v1/kubernetes/external-clusters/{clusterId} response clusterNameId field.
    # params:
    #   clusterNames:
    #     - 'cluster1-bd9e12be'
    #     - 'cluster2-ca4e11a0'
```

## Metrics by type

Cluster metrics can be used for observability and alerting purposes (e.g. Prometheus metrics can be integrated with PagerDuty to alert on call support engineers in case snapshots are not being received (or processed) for a set period of time, as it would mean that cluster is not autoscaling).

| Name | Type | Description | Action
| ----------- | ----------- | ----------- | ----------- |
`castai_autoscaler_agent_snapshots_received_total` | Counter | CAST AI Autoscaler agent snapshots received total | Check if Agent is running in the cluster |
`castai_autoscaler_agent_snapshots_processed_total` | Counter | CAST AI Autoscaler agent snapshots processed total | Contact CAST AI support |
`castai_cluster_allocatable_cpu_cores` | Gauge | Cluster allocatable CPU cores  |  |
`castai_cluster_allocatable_memory_bytes` | Gauge | Cluster allocatable memory |  |
`castai_cluster_provisioned_cpu_cores` | Gauge | Cluster provisioned CPU cores |  |
`castai_cluster_provisioned_memory_bytes` | Gauge | Cluster provisioner memory |  |
`castai_cluster_requests_cpu_cores` | Gauge | Cluster requested CPU cores |  |
`castai_cluster_requests_memory_bytes` | Gauge | Cluster requested memory |  |
`castai_cluster_node_count` | Gauge | Cluster nodes count |  |
`castai_cluster_pods_count` | Gauge | Cluster pods count |  |
`castai_cluster_unschedulable_pods_count` | Gauge | Cluster unschedulable pods count |  |
`castai_evictor_node_target_count` | Gauge | CAST AI Evictor targeted nodes count |  |
`castai_evictor_pod_target_count` | Gauge | CAST AI Evictor targeted pods count |  |

## Example queries

Cost per cluster:

```
sum(castai_cluster_total_cost_hourly{}) by (castai_cluster)
```

Received snapshots count:

```
sum(increase(castai_autoscaler_agent_snapshots_received_total{castai_cluster="$cluster"}[5m]))
```

Alert on missing snapshots:

```
absent_over_time(castai_autoscaler_agent_snapshots_received_total{castai_cluster="$cluster"}[5m])
```

**Note**: Replace `$cluster` with existing `castai_cluster` label value.
