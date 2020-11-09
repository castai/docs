# Autoscaling policies 

Autoscaling policies define a set of rules based on which your cluster is being monitored and scaled to maintain steady performance at the lowest cost possible.

This topic describes available policy configuration options as well as provides guidance on how to configure them. 

## Policy levels

Policies can be split into multiple sections based on its the area of effect within cluster:

* [Cluster limits](https://castai.github.io/docs/administration/configuring-gcp-credentials/)
* [Node](https://castai.github.io/docs/administration/configuring-gcp-credentials/)
* [Pod](https://castai.github.io/docs/administration/configuring-gcp-credentials/)

### Cluster limits policies

Cluster limits policies allow you to set the minimum and maximum allowed cluster's computing capacity based on particular node metrics. 
If enabled, cluster's upscaling and downscaling actions will respect the limits constraint - the cluster's total resource capacity will stay within the defined range.

#### Cluster CPU limits policy

Each CAST AI's cluster size can be limited by the total amount of vCPU available on all worker nodes used to run workloads.

To enable ![]

### Node policies

CAST AI's autoscaler supports node-level scaling. 

### Pod policies
 

