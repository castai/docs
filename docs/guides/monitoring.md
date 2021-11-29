---
description: Tips on how to setup monitoring and alerting for CAST AI agent
---

# CAST AI agent health monitoring

## Agent logs

To quickly assess the state of the agent use standard `kubectl` command to access agent container logs:

```sh
kubectl logs -n castai-agent -l app.kubernetes.io/name=castai-agent -c agent
```

## Monitoring using Prometheus

CAST AI exposes number of cluster metrics, some of them can be used to assess the health of the system and alert in case of issues. For example if the agent is performing as expected it should send snapshots (deltas) about changing cluster state back to central SaaS console. In case snapshots are not received for sustained period of time it should be cause of concern. We propose to setup alerting rule using Prometheus monitoring stack as described here.  

## Advanced monitoring using kube-state-metrics and Prometheus

We suggest building [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics) and [Prometheus](https://prometheus.io/) setup for advanced monitoring capability. It would enable users to capture cases like:

- Agent pod not transitioning in to `Running` status

- Agent pod  constantly restarting

Examples of how to setup Prometheus alerting rules to cover these scenarions are presented below:

```yaml
alerting_rules.yml:
    groups:
      - name: castai-agent
        rules:
          - alert: CastaiAgentFailedToRun
            expr: |
              sum by (namespace, pod) (
                        max by(namespace, pod) (
                          kube_pod_status_phase{phase=~"Pending|Unknown|Failed",namespace="castai-agent"}
                        ) * on(namespace, pod) group_left(owner_kind) topk by(namespace, pod) (
                          1, max by(namespace, pod, owner_kind) (kube_pod_owner{owner_kind!="Job"})
                        )
                      ) > 0
            for: 5m
            labels:
              severity: page
            annotations:
              summary: "Kubernetes pod {{ $labels.pod }} cannot transition to Running phase."
              description: "Checks the Kubernetes pod status phase metric and alerts when phase Running has not been reached in at least 5 minutes. Tip: phase=Running does not mean that the pod is running without any issues, i.e. when phase=Running, pod can have status CrashLoopBackOff, it only means that the pod was successfully scheduled."
              value: "{{`{{ $value }}`}}"
          - alert: CastaiAgentCrashLooping
            expr: |
              increase(kube_pod_container_status_restarts_total{namespace="castai-agent"}[1h]) > 5
            for: 0s
            labels:
              severity: page
            annotations:
              summary: "Kubernetes pod {{ $labels.pod }} crash looping."
              description: "Checks the total number of pod restarts in the last hour and alerts when there were at least 5 restarts."
              value: "{{ $value }}"
```
