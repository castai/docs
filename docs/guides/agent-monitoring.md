---
description: Tips on how to set up monitoring and alerting for the CAST AI agent
---

# CAST AI agent health monitoring

The CAST AI agent deployed inside customer's cluster is a critical part of the solution, hence monitoring its status is vital. This document outlines the recommended techniques for monitoring and understanding the health of this agent.

## Agent logs

To quickly assess the state of the agent, use the standard `kubectl` command to access the agent container logs:

```sh
kubectl logs -n castai-agent -l app.kubernetes.io/name=castai-agent -c agent
```

The expected outcome if the agent operations are healthy is as follows:

```txt
time="2021-12-02T09:19:42Z" level=info msg="delta with items[#] sent, response_code=204"
```

## Prometheus metrics

CAST AI exposes a number of Prometheus metrics, some of them can be used to assess the health of the CAST AI agent and alert in case of any issues. For example, if the agent is performing as expected it should send snapshots (deltas) containing metadata about the cluster every 15s back to the CAST AI console. If snapshots are not received for a sustained period of time, this should be cause of concern and investigation. To monitor and alert against such scenarios, we propose using Prometheus metrics and alerting as described [here](../guides/metrics.md).

## Advanced monitoring using kube-state-metrics and Prometheus

We suggest building [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics) and [Prometheus](https://prometheus.io/) setup for advanced monitoring capability. This would enable users to capture cases like:

- Agent pod not transitioning into `Running` status,

- Agent pod constantly restarting.

Examples of Prometheus alerting rules that cover the mentioned scenarions are presented below:

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
