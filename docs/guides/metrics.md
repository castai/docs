---
description: Guide on how to scrape CAST AI metrics
---

# CAST AI cluster metrics integration

CAST AI exposes Prometheus metrics api endpoint for integration with your existing Prometheus monitoring stack.

## Setup guide

1. Create readonly CAST AI API key via Console UI.

2. Configure Prometheus scrape job:

   - Replace `{apiKey}` with your api key.

```
scrape_configs:
  - job_name: 'castai_cluster_metrics'
    scrape_interval: 10s
    scheme: https
    static_configs:
      - targets: ['api.cast.ai']
    metrics_path: '/v1/kubernetes/external-clusters/prometheus/metrics'
    authorization:
      type: 'Token'
      credentials: '{apiKey}'

```

## Metrics by type

Cluster metrics can be used for observability and alerting purposes (e.g. Prometheus metrics can be integrated with PagerDuty to alert on call support engineers in case snapshots are not being received (or processed) for a set period of time, as it would mean that cluster is not autoscaling).

| Name | Type | Description | Action
| ----------- | ----------- | ----------- | ----------- |
`castai_autoscaler_agent_snapshots_received_total` | Counter | CAST AI Autoscaler agent snapshots received total | Check if Agent is running in the cluster |
`castai_autoscaler_agent_snapshots_processed_total` | Counter | CAST AI Autoscaler agent snapshots processed total | Contact CAST AI support |
`castai_cluster_total_cost_hourly` | Gauge | CAST AI cluster total cost hourly |  |

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
