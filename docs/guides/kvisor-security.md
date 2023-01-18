---
description: Check how to install and upgrade CAST AI kvisor security component
---

# CAST AI kvisor

Kvisor is resposible for images vulnerability scanning, Kubernetes YAML manifests linting and CIS security recommendations.
It's open source and can be found on [github](https://github.com/castai/kvisor).

## Install kvisor

!!! note ""
    Before installing kvisor you must connect your cluster. Please see [guide](../getting-started/overview.md) for cluster connection.

Add CAST AI helm charts repository.

```shell
helm repo add castai-helm https://castai.github.io/helm-charts
helm repo update
```

You can list all available components and versions.

```shell
helm search repo castai-helm
```

Expected example output

```
NAME                                    CHART VERSION   APP VERSION     DESCRIPTION
castai-helm/castai-agent                0.18.0          v0.23.0         CAST AI agent deployment chart.
castai-helm/castai-cluster-controller   0.17.0          v0.14.0         CAST AI cluster controller deployment chart.
castai-helm/castai-evictor              0.10.0          0.5.1           Cluster utilization defragmentation tool
castai-helm/castai-spot-handler         0.3.0           v0.3.0          CAST AI spot handler daemonset chart.
castai-helm/castai-kvisor               0.16.9        v0.20.3         CAST AI security agent deployment chart.
```

Now let's install it.

```shell
helm upgrade --install castai-kvisor castai-helm/castai-kvisor -n castai-agent \
  --set castai.apiKey=<your-api-token> \
  --set castai.clusterID=<your-cluster-id>
  --set structuredConfig.provider=<aks|eks|gke>
```

!!! note ""
    For `structuredConfig.provider` you should pass your kubernetes provider or leave empty if it's none of `aks`, `eks` or `gke`.

!!! note ""
    You can create api key via CAST AI console UI.

!!! note ""
    You can find your cluster ID in CAST AI console UI.

## Upgrade kvisor

Upgrade to latest version.

```shell
helm repo update
helm upgrade castai-kvisor castai-helm/castai-kvisor -n castai-agent --reuse-values
```

## Configuring features

You can change any of the supported config values described in [kvisor helm chart](https://github.com/castai/kvisor/blob/main/charts/castai-kvisor/values.yaml#L42)

To increase concurrent images scan count:

```shell
helm upgrade castai-kvisor castai-helm/castai-kvisor -n castai-agent \
  --reuse-values --set structuredConfig.imageScan.maxConcurrentScans=6
```

To disable images can:

```shell
helm upgrade castai-kvisor castai-helm/castai-kvisor -n castai-agent \
  --reuse-values --set structuredConfig.imageScan.enabled=false
```

To disable kube bench jobs:

```shell
helm upgrade castai-kvisor castai-helm/castai-kvisor -n castai-agent \
  --reuse-values --set structuredConfig.kubeBench.enabled=false
```

To disable kubernetes YAML manifests linters:

```shell
helm upgrade castai-kvisor castai-helm/castai-kvisor -n castai-agent \
  --reuse-values --set structuredConfig.linter.enabled=false
```

To check all applied configurations:
```shell
helm get values castai-kvisor -n castai-agent
```

## Troubleshooting

Check kvisor logs

```shell
kubectl logs -l app.kubernetes.io/name=castai-kvisor -n castai-agent
```
