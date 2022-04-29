# Subnets selection

## Feature availability

|   | EKS | KOPS | GKE | AKS |
| - | --- | ---- | --- | --- |
| **Random subnets selection (from available set)** |  **+**  |  +   |  -  |  -  |
| **Subnets selection by usage***                   | **+**** |  -   |  -  |  -  |

!!! Note ""
    \* select subnet with most free IP addresses
  
    ** available if AWS cloud CNI is used with specific settings

## Available subnets detection

Cluster subnets with subnet IP CIDR and availability zone are synced periodically to CAST AI. Autoscaler based on various rules when constructing in-memory nodes for autoscaling decides from which subnets to choose. What does influence selection:

* pod node selector for "topology.cast.ai/subnet-id" label
* pod node affinity for "topology.cast.ai/subnet-id" label
* availability zone on in-memory node (would choose only subnets in the same zone)
* chose zone based on constraints from other parts. eg Persistent Volume zone is affecting in-memory node zone
* choose the least allocated zone
* chose random zone

**If subnet calculation is supported** and we detect that all available subnets are full pod will get a pod event with a message `there is no subnet with enough available IP addresses"`.

## Subnets usage calculation

Subnets usage calculation is available only for EKS and when AWS cloud CNI is used for networking

Subnets usage is calculated based on CNI settings and instance type networking capabilities([max ENI count on instance type and ipv4 count per ENI](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html#AvailableIpPerENI)).

CNI settings used to calculate used IP addresses:

| Name | Description | Default |
| ---- | ----------- | ------- |
| **WARM_ENI_TARGET**   | how many free ENIs should be attached as reserve      | 1 |
| **WARM_IP_TARGET**    | how many free secondary IPs should be kept as reserve |   |
| **MINIMUM_IP_TARGET** | minimum IP count to be requested when adding node     |   |
| **MAX_ENI**           | additional caping on instance type max ENI count      |   |

CNI settings that disable subnets usage calculation:

| Name | What is supported | Why? |
| ---- | ----------------- | ---- |
| **AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG**| `None` or `false` | Configuration is in file, since its custom we can not know how CNI behaves |
| **ENABLE_POD_ENI**| `None` or `false` | [Documentation](https://github.com/aws/amazon-vpc-cni-k8s#enable_pod_eni-v170) is not clear, need POC to support it |
| **ENABLE_PREFIX_DELEGATION**| `None` or `false` | Looks like good improvement for CNI(X16 more pods + X16 used IPs). Need investigation and POC to know how it works. |
| **ENABLE_IPv6**| `None` or `false` | We have ipv4 CIDR in subnets |

## How does the calculation work

The Source of documentation is [here](https://github.com/aws/amazon-vpc-cni-k8s#eni-allocation)

Each instance type in AWS has limits on [how many ENIs can be attached and how many IPs each ENI can have](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html#AvailableIpPerENI), those numbers are synchronized to CAST AI periodically and are used by this algorithm.

Some key points:

* Each ENI uses 1 IP for self and all other IPs are secondary and can be used for pods, so always (max IPs for pods in ENI = max IPs per ENI - 1).
* If we just attach ENI 1 IP will always be used regardless of CNI settings
* If `WARM_IP_TARGET` is `specified WARM_ENI_TARGET` is not used
* If `MAX_ENI` < instances max ENI count it works as an override for instance setting, otherwise instance setting is used
* All pods which have `hostNetwork:true` do not get secondary IP and host IP is used for communication (as an example AWS CNI and kube-proxy) PS: they are still counted as PODs and are capped by podCount constraint on node

Here is a detailed description of how [WARM_ENI_TARGET, WARM_IP_TARGET, and MINIMUM_IP_TARGET work](https://github.com/aws/amazon-vpc-cni-k8s/blob/master/docs/eni-and-ip-target.md)

## Useful commands for investigations

command to get subnet IPs allocation - we considering that subnet is used only for this k8s cluster(some worker groups or security groups might use some IPs if they were created with this subnet this could result into few IPs difference between calculation and actual allocation this could result into failed node creatiom instead of pod event in some edge cases), using same subnets for anything else than this cluster will make this feature work incorrectly.

```bash
aws ec2 describe-network-interfaces --filters Name=subnet-id,Values=subnet_id > subnet_id.yaml
```

command to print all pods with IPs information, sorted by node

```bash
kubectl get pod -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName,POD-IP:.status.podIP,HOST-IP:.status.hostIP --sort-by=.spec.nodeName  --all-namespaces
```
