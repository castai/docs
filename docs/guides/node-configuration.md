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

| Configuration | Options |
|----------|-----------|
| Root volume ration | CPU to storage (GiB) ratio |
| Subnets  | Subnet IDs for CAST AI provisioned nodes |
| Security groups  | Security group IDs for CAST AI provisioned nodes |
| Instance profile ARN  |  Instance profile ARN for CAST AI provisioned nodes  |
| Instance tags   | Tags for CAST AI provisioned nodes |
| Image version   | Image to be used when building CAST AI provisioned node |
| Dns-cluster-ip   | Override the IP address to be used for DNS queries within the cluster |
| SSH key   | Base64 encoded public key or AWS key ID |

## Create node configuration

A default node configuration is created during phase 2 cluster onboarding.
You can choose to modify this configuration or create a new one.
If you choose to add new node configuration, you will have to mark it as
the default node configuration.

Node configurations are versioned and when the CAST AI autoscaler adds new node,
the latest version of node configuration is applied. Over time CAST AI provisioned
nodes trend to the latest available node configuration.

### Web UI

TODO: screenshot

In the cluster view a new tab "Node configuration" has been created.
Here you can view and manage node configurations.

1) Use the button "Add configuration"
2) Name your configuration and fill in your values
3) Click "Save"
4) Click "..." and "Set as default"


### Terraform

TODO:

### API

TODO:



## Delete node configuration

To delete a node configuration, the following has to true:

* the configuration is not linked to a node template
* if the configuration is marked as "default", it must not be the latest version

### Web UI

In the node configuration view, click "..." of the configuration you wish to delete
and then "Delete configuration.

## Node view

View node list with applied node configuration + filter nodes.

----

# --- Not related ---

The CAST AI autoscaler supports organizing nodes into groups of different characteristics
and scheduling workload based on these characteristics.

!!! Note ""
    Adding nodes to groups might lead to higher workload fragmentation and lower savings





## Feature availability

| Provider | Supported |
|----------|-----------|
| AWS EKS   | Yes |

## Node Templates

TODO: screenshot

Node templates define logical grouping of nodes based on the following characteristics:

| Characteristic | Options |
|----------|-----------|
| Node configuration | Associated Node configuration
| Instance lifecycle   | Spot / On demand |
| Instance optimization   | None / Compute / Storage |
| Instance constraint | See table below |


### Node Constraints

| Constraint | Options |
|----------|-----------|
| Include families   | Family type |
| Exclude families   | Family type |
| Min CPU   | 1-448 |
| Max CPU   | 1-448 |
| Min memory   | 2GiB-12TiB |
| Max memory   | 2GiB-12TiB |
| GPU manufacturer   | Nvidia |
| Include GPU name   | GPU name |
| Exclude GPU name   | GPU name |
| Min GPUs   | 1-16 |
| Max GPUs   | 1-16 |




0) before you begin, onboard your cluster to phase 2
1) available config options
) templates
) suboptimal results due to fragmentation
) workload -> node template mappping
) un removable pods group
) troubleshooting

## Configuration


What happens to existing workload when new template/config version is generated - next autoscaling cycle

Deleting template/config
Conflicting node configuration
