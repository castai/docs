# Subnets selection

## Feature availability

|   | EKS | KOPS | GKE | AKS |
| - | --- | ---- | --- | --- |
| **Random subnets selection (from available set)** |  **+**  |  +   |  -  |  **+**  |
| **Subnets selection by usage***                   | **+****|  -   |  -  |  **+**** |

!!! Note ""
    \* Select the subnet with the greatest number of free IP addresses
  
    ** Available if AWS cloud CNI is used with specific settings or if Azure CNI is used for AKS clusters

## Available subnets detection

Cluster subnets with subnet IP CIDR and availability zone are synced periodically with CAST AI. The autoscaler based on various rules decides from which subnets to choose when constructing in-memory nodes for autoscaling. The selection is influenced by:

* Pod node selector for `topology.cast.ai/subnet-id` label;
* Pod node affinity for `topology.cast.ai/subnet-id` label;
* Availability zone on in-memory node (will only consider the subnets in the same zone);
* Choose a zone based on constraints from other parts - e.g., Persistent Volume zone is affecting in-memory node zone;
* Choose the least allocated zone;
* Choose a random zone.

**If subnet calculation is supported** and we detect that all the available subnets are full, the pod will get a pod event with a message `there is no subnet with enough available IP addresses.`

## EKS

Subnets usage calculation is only available for EKS clusters that use AWS cloud CNI for networking.

Subnets usage is calculated based on CNI settings and instance type networking capabilities([max ENI count on instance type and ipv4 count per ENI](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html#AvailableIpPerENI)).

CNI settings used to calculate used IP addresses:

| Name | Description | Default |
| ---- | ----------- | ------- |
| **WARM_ENI_TARGET**   | How many free ENIs should be attached as reserve.      | 1 |
| **WARM_IP_TARGET**    | How many free secondary IPs should be kept as reserve. |   |
| **MINIMUM_IP_TARGET** | Minimum IP count to be requested when adding node.     |   |
| **MAX_ENI**           | Additional caping on instance type max ENI count.      |   |

CNI settings that disable subnets usage calculation:

| Name | Supported values |
| ---- | ----------------- |
| **AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG**| `None` or `false` |
| **ENABLE_POD_ENI**| `None` or `false` |
| **ENABLE_PREFIX_DELEGATION**| `None` or `false` |
| **ENABLE_IPv6**| `None` or `false` |

### How does the calculation work

The source of documentation is [here](https://github.com/aws/amazon-vpc-cni-k8s#eni-allocation).

Each instance type in AWS has limits on [how many ENIs can be attached and how many IPs each ENI can have](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html#AvailableIpPerENI), those numbers are synchronized with CAST AI periodically and used by this algorithm.

Some key points:

* Each ENI uses 1 IP for itself and all other IPs are secondary and can be used for pods, so always (max IPs for pods in ENI = max IPs per ENI - 1).
* If we just attach ENI, 1 IP will always be used regardless of CNI settings.
* If `WARM_IP_TARGET` is `specified WARM_ENI_TARGET` is not used.
* If `MAX_ENI` < instances max ENI count, it works as an override for instance setting, otherwise instance setting is used.
* All the pods that have `hostNetwork:true` don't get secondary IP and host IP is used for communication (as an example AWS CNI and kube-proxy) PS. They are still counted as PODs and are capped by podCount constraint on node.

Here is a detailed description of how [WARM_ENI_TARGET, WARM_IP_TARGET, and MINIMUM_IP_TARGET work](https://github.com/aws/amazon-vpc-cni-k8s/blob/master/docs/eni-and-ip-target.md).

### Useful commands for investigations

Command to get subnet IPs allocation - we consider that subnet is used only for this K8s cluster (some worker groups or security groups might use some IPs if they were created with this subnet and this could result in few IPs difference between calculation and actual allocation, bringing failed node creation instead of pod event in some edge cases), using same subnets for anything else than this cluster will make this feature work incorrectly.

```bash
aws ec2 describe-network-interfaces --filters Name=subnet-id,Values=subnet_id > subnet_id.yaml
```

Command to print all pods with IPs information, sorted by node.

```bash
kubectl get pod -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName,POD-IP:.status.podIP,HOST-IP:.status.hostIP --sort-by=.spec.nodeName  --all-namespaces
```

## AKS

Subnets usage calculation is only available for AKS clusters with Azure CNI enabled for networking. The network that contains the subnets to dynamically choose from should only be used in one cluster.

Azure subnets are regional. Therefore, the allocation based on the least allocated zone cannot be performed while the allocation based on the least used subnet can.

The calculation of subnet usage is done based on the fact that Azure reserves the first four and last IP address for a total of 5 IP addresses within each subnet. Additionally, whenever a node is created there is also a reservation of the number of IPs equal to the maximum number of pods supported by the node plus 1 for the node itself.

The `topology.cast.ai/subnet-id` node selector as well as the node affinity should contain just the subnet names as values. For example, if there are two subnet IDs:

* `/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/virtualNetworks/<virtual-network>/subnets/subnet-1` and
* `/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/virtualNetworks/<virtual-network>/subnets/subnet-2`

the **nodeSelector** should be as follows:

```yaml
spec:
 nodeSelector:
  topology.cast.ai/subnet-id: "subnet-1"
```

while the **nodeAffinity** as below:

```yaml
spec:
 affinity:
  nodeAffinity:
   requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions:
      - key: topology.cast.ai/subnet-id
        operator: In
        values:
          - subnet-1
          - subnet-2
```
