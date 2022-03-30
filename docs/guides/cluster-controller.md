---
description: Check how to install and upgrade CAST AI cluster-controller
---

# CAST AI cluster-controller

Cluster controller is responsible for handling certain Kubernetes actions such as draining and deleting nodes, adding labels, approving CSR requests.
It's open source and can be found on github <https://github.com/castai/cluster-controller>

## Install cluster-controller

By default cluster controller is installed during your cluster onboarding using helm chart <https://github.com/castai/helm-charts/tree/main/charts/castai-cluster-controller>

If for some reasons it was uninstalled you can install it manually.

Add CAST AI helm charts repository.

```sh
helm repo add castai-helm https://castai.github.io/helm-charts
helm repo update
```

You can list all available components and versions.

```sh
helm search repo castai-helm
```

Expected example output

```
NAME                                    CHART VERSION   APP VERSION     DESCRIPTION
castai-helm/castai-agent                0.18.0          v0.23.0         CAST AI agent deployment chart.
castai-helm/castai-azure-spot-handler   0.1.1           v0.1.0          CAST AI Azure spot handler daemonset chart  
castai-helm/castai-cluster-controller   0.14.0          v0.11.0         CAST AI cluster controller deployment chart.
castai-helm/castai-spot-handler         0.3.0           v0.3.0          CAST AI spot handler daemonset chart.
```

Now let's install it.

```sh
helm upgrade --install cluster-controller castai-helm/castai-cluster-controller -n castai-agent \
  --set castai.apiKey=<your-api-token> \
  --set castai.clusterID=<your-cluster-id>
```

!!! note ""
    For AKS clusters you should also pass `--set aks.enabled=true`

!!! note ""
    You can create api token via CAST AI console UI.

!!! note ""
    You can find your cluster ID in CAST AI console UI.

## Upgrade cluster-controller

Cluster controller supports auto-update out of the box and is enabled by default. However sometimes it cannot be updated due to changes in RBAC and requires manual upgrade.

Upgrade to latest version.

```sh
helm repo update
helm upgrade cluster-controller castai-helm/castai-cluster-controller --reuse-values -n castai-agent
```

Upgrade to specific version.

```
helm repo update
helm upgrade cluster-controller castai-helm/castai-cluster-controller --reuse-values -n castai-agent --version=0.14.0
```

## Auto updates

By default cluster-controller can update itself by receiving update action (scheduled by CAST AI). However, it cannot update other components such as castai-evictor, castai-spot-handler or castai-agent.

You can explicitly bind role such as cluster-admin to castai-cluster-controller service account. This will allow cluster-controller to manage all other CAST AI components automatically.

```sh
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: castai-cluster-controller-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: castai-cluster-controller
    namespace: castai-agent
EOF
```
