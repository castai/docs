---
description: Use CAST AI helm charts with custom secret manager
---

# Custom Secret Management

There's plenty of technologies used to manage Secrets in GitOps.
Some store the encrypted Secret data in a git repository
and use a cluster addon to decrypt the data during deployment,
some use a reference to an external secret manager/vault.

To enable the use of CAST AI Agent with custom secret managers,
the Agent helm chart provides the parameter `apiKeySecretRef`.

```yaml
# Name of secret with Token to be used for authorizing agent access to the API
# apiKey and apiKeySecretRef are mutually exclusive
# The referenced secret must provide the token in .data["API_KEY"]
apiKeySecretRef: ""
```

## Example

### CAST AI Agent

An example of using CAST AI Agent helm chart with custom secret:

```shell
helm repo add castai-helm https://castai.github.io/helm-charts
helm repo update
helm upgrade --install castai-agent castai-helm/castai-agent -n castai-agent \
  --set apiKeySecretRef=<your-custom-secret> \
  --set clusterID=<your-cluster-id>
```

### CAST AI Cluster Controller

An example of using CAST AI Cluster Controller helm chart with custom secret:

```shell
helm repo add castai-helm https://castai.github.io/helm-charts
helm repo update
helm upgrade --install castai-agent castai-helm/castai-cluster-controller -n castai-agent \
  --set castai.apiKeySecretRef=<your-custom-secret> \
  --set castai.clusterID=<your-cluster-id>
```
