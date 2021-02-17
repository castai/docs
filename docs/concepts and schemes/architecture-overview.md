# Cluster architecture overview

This chapter summarizes the overall design of your Kubernetes cluster and how it's relationships with CAST AI platform.

## Cluster lifecycle

- ### Provisioning

You initiate creation of the cluster. Refer to [getting started] on how to create a cluster.


- ### Reconciliation & healing

A cluster enters a reconciliation loop. The platform periodically re-checks that actual infrastructure on your cloud reflects the specified configuration, and performs upgrades & patching. Reconciliation performs checks such as:

  - [x] Cluster network configuration is up to date;
  - [x] Are any nodes missing, e.g. accidentally deleted;
  - [x] Are there any unused resources to clean up;

- ### Resizing

CAST AI clusters do not use a "node pool" concept. Instead, you can: 

   - Manually add or remove nodes with specified configuration.
   - Enable autoscaling policies - it scales up and down per-node level.

- ### Cleanup

When you delete a cluster platform will collapse cloud resources in the quickest way. Nodes will not be drained before deleting them.

The platform is designed to minimize unintended removals. If you have any extra virtual machines that do not contain CAST AI cluster UUID - delete operation will fail.

## Cluster architecture

### Context

Below diagram highlights primary groups of components that define a relationship between CAST AI platform and your cluster.

![](architecture-overview/component-relationships.png)

New CAST AI users will start by interacting with the platform via console UI (<https://console.cast.ai>). Once the created cluster is ready, by downloading cluster's kubeconfig you are able to access your cluster directly. Some of the middleware that is running on the cluster (Grafana, Kubernetes dashboard) is directly reachable from UI through the single-signon gateway.

You can notice that there is a bi-direction link between your cluster and CAST AI platform. Not only the platform connects to your cloud infrastructure or the cluster itself; CAST AI also relies on the cluster to "call back" and inform about certain events:

* Cluster control plane nodes actions with provisioning engine, e.g. when to join the cluster;
* Nodes inform about operations being completed, like finishing joining the cluster;
* Relevant cloud events get propagated to provisioning engine & autoscaler, for example, "spot instance is being terminated by cloud provider";

Your app users do not interact with CAST AI in any way. You own your kubernetes cluster infrastructure 100%, including any ingress infrastructure to reach your cluster workloads.

## Cluster infrastructure

### Nodes

Overview on where cluster virtual machines will be provisioned on your cloud:

![](architecture-overview/nodes-infrastructure.svg)

### Ingress

CAST AI provisioned clusters contain all the infrastructure needed to equip your app with an external TLS endpoint:

* DNS entry to round-robin;
* Load-balancing infrastructure: cloud-native load balancers that route traffic to sub-section of your cluster (e.g. traffic that hits AWS load balancer will route to AWS nodes);
* Nginx ingress controller, paired with TLS certificate manager, that listen to your deployed resources and maintain routing&TLS configuration;
* Metric collection for your ingress traffic;

All that is left for you as an application developer is to deploy your app, ingress resource, and configure a domain alias of your choice. See the [guide](../guides/ingress.md) for more details.

![](architecture-overview/ingress.png)

### Network details

#### Region & zone

As you select a Cast region, for each cloud it maps to a specific region on that cloud.

For example, **US East (Ashburn)** region maps to:

* AWS: us-east-1
* GCP: us-east4
* Azure: eastus
* Digital Ocean: nyc1

Currently, on each cloud CAST AI builds a single-zone setup of your cluster. Zone selection is cloud-specific.

#### Master nodes inbound

| Protocol | Port | Source | Description |
|---|---|---|---|
| tcp | 6443 | 0.0.0.0/0 | k8s API server |  
| udp | 51820 | 0.0.0.0/0 | WireGuard (if used)|

#### Worker nodes inbound

| Protocol | Port | Source | Description |
|---|---|---|---|
| udp | 51820 | 0.0.0.0/0 | WireGuard (if used) |
| tcp/udp | NodePort | 0.0.0.0/0 | k8s Service with type=LoadBalancer |

#### Subnets

| Range | Description |
|---|---|
| 10.96.0.0/12 | k8s services |
| 10.217.0.0/16 | k8s pods |
| 10.4.0.0/16 | WireGuard|
| 10.0.0.0/16 | GCP VPC. Smaller /24 blocks are allocated for subnets. |
| 10.10.0.0/16 | AWS VPC. Smaller /24 blocks are allocated for subnets. |
| 10.20.0.0/16 | AZURE VPC. Smaller /24 blocks are allocated for subnets. |
| 10.100-255.0.0/20 | DigitalOcean VPC. There is only one subnet which is allocated dynamically. |
