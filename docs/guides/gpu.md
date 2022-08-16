# GPU instances autoscaling

The CAST AI autoscaler supports running your workloads on GPU-optimized instances.
This guide will help you configure and run it in 5 minutes.

## Supported providers

| Provider | GPUs supported |
|----------|--------------------------|
| AWS EKS   | NVIDIA, AMD(coming soon) |
| GCP GKE   | coming soon |
| EKS KOPS  | coming soon |
| Azure AKS | coming soon |

## Configuration

### GPU Driver

A GPU-specific driver should be installed on the cluster to run GPU workloads. CAST AI verifies and ensures that the required driver is available on the cluster before provisioning the required nodes.

### How to install the NVIDIA driver

1. Onboard cluster to CAST AI by providing additional variable `INSTALL_NVIDIA_DEVICE_PLUGIN=true`
2. Install it from NVIDIA repository:

    ``` bash
    helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
    helm repo update
    ```

    ``` bash 
    noglob helm upgrade -i nvdp nvdp/nvidia-device-plugin -n castai-agent \
        --set-string nodeSelector."nvidia\.com/gpu"=true \
        --set \
    tolerations[0].key=CriticalAddonsOnly,tolerations[0].operator=Exists,\
    tolerations[1].effect=NoSchedule,tolerations[1].key="nvidia\.com/gpu",tolerations[1].operator=Exists,\
    tolerations[2].key="scheduling\.cast\.ai/spot",tolerations[2].operator=Exists,\
    tolerations[3].key="scheduling\.cast\.ai/scoped-autoscaler",tolerations[3].operator=Exists,\
    tolerations[4].key="scheduling\.cast\.ai/node-template",tolerations[4].operator=Exists
    ```

3. Use your own plugin. CAST AI does plugin compatibility check with new node before provisioning it so CAST AI should detect plugin to do that. Plugin will be detected by CAST AI if one of these conditions are honored:
    - plugin daemon set name pattern is `*nvidia-device-plugin*`
    - plugin daemon set has label `nvidia-device-plugin: "true"`

### Workload configuration

To request node that has attached GPU workload should:

- define at least GPU limits on workload resources:

    ``` yaml
    resources:
      requests:
        cpu: 1
        memory: 1Gi
        nvidia.com/gpu: 1
      limits:
        memory: 1Gi
        nvidia.com/gpu: 1
    ```

- add toleration for GPU node:

    ``` yaml
    spec:
      tolerations:
        - key: "nvidia.com/gpu"
          operator: Exists
    ```

*toleration is required because CASTA AI adds taint on GPU nodes so that expensive nodes could be used only by workloads that truly require GPUs*
