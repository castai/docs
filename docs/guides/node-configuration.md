# Node Configuration

## Feature availability

| EKS | KOPS | GKE | AKS |
| --- | ---- | --- | --- |
| **+** |  -   |  -  |  -  |
| **+** |  -   |  -  |  -  |

The CAST AI autoscaler allows you to provide node configuration parameters
that will be applied to CAST AI provisioned nodes.
Node configuration on its own does not influence workload placement.

The list of supported configuration parameters:

| Configuration | Options | Default |
|---------------|---------|---------|
| Root volume ration | CPU to storage (GiB) ratio | 1 CPU : 5 GiB |
| Subnets  | Subnet IDs for CAST AI provisioned nodes | All subnets pointing to NAT/Internet gateways |
| Security groups  | Security group IDs for CAST AI provisioned nodes | [Tagged](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html) and CAST AI SG |
| Instance profile ARN  |  Instance profile ARN for CAST AI provisioned nodes  | cast-<cluster-name\>-eks-<cluster-id[:8]\> |
| Instance tags   | Tags for CAST AI provisioned nodes | [] |
| Image version   | Image to be used when building CAST AI provisioned node | Latest available [AMI](https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html) for kubernetes release |
| Dns-cluster-ip   | Override the IP address to be used for DNS queries within the cluster | "" |
| SSH key   | Base64 encoded public key or AWS key ID | "" |

By default values are either inferred from the cluster (subnets, security groups...) or a generic value is applied.

## Create node configuration

A default node configuration is created during phase 2 cluster onboarding.
You can choose to modify this configuration or create a new one.
If you choose to add new node configuration, you will have to mark it as
the default node configuration.

Node configurations are versioned and when the CAST AI autoscaler adds new node,
the latest version of node configuration is applied. Over time CAST AI provisioned
nodes trend to the latest available node configuration.

### Web UI

In the cluster view a new tab "Node configuration" has been created.
Here you can view and manage node configurations.

![](node-config/node-config.png)

 1. Use the button "Add configuration"

    ![](node-config/node-config-create-1.png)

 2. Name your configuration and fill in your values

    ![](node-config/node-config-create-2.png)

 3. Click "Save"

 4. Click "..." and "Set as default"

    ![](node-config/node-config-create-3.png)

### Terraform

Use the module `castai_node_configuration` from [CAST AI terraform provider](https://github.com/castai/terraform-provider-castai).

### API

For API operations consult the generated [documentation](https://api.cast.ai/v1/spec/#/NodeConfigurationAPI).

## Delete node configuration

To delete a node configuration, the following has to be true:

* the configuration is not linked to a node template
* if the configuration is marked as "default", it must not be the latest version

### Web UI

In the node configuration view, click "..." of the configuration you wish to delete
and then "Delete configuration".

![](node-config/node-config-delete.png)

## Node view

In the "Nodes" tab, you can view and filter nodes based on applied node configuration:

![](node-config/node-config-list.png)
