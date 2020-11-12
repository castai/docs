# How it works

Long story short, the CAST AI engine uses your Cloud Service Provider (CSP) accounts to create the required cloud
resources and set up a multi-cloud cluster for you. You can start using multi-cloud Kubernetes with just a few clicks.
With few clicks of a button, you can start using multi-cloud Kubernetes.

To get a bit more technical; using your owned and provided Cloud Service Provider (CSP) accounts CAST AI will create
VPCs or Resource Groups (depending which clouds you use), further on the required network will be created like subnets,
public IPs and VPNs.  To get a bit more technical; using your owned and provided CSP accounts, CAST AI will create VPCs
or Resource Groups (depending on which cloud services you use). Further on the required network will be created like
subnets, public IPs, and VPNs.

Later on, this will be used to ensure a uniform network across created VPCs, which is required for seamless Kubernetes
operation. There are certain processes in place to help non-compatible clouds merge into a single flat network.

Latter will be used to ensure uniform network across created VPCs which is required for seamless Kubernetes operation.
There are certain processes in place to make non-compatible clouds merge into a single flat network. CAST AI regions
are selected with network latency in mind. In order for your applications and the cluster itself to function as
expected, cross-cloud latency must not go above 10 ms in normal operation. CAST AI regions were measured to operate in a
5-7 ms range.

CAST AI regions are selected with network latency in mind. In order for your applications and the cluster itself to
function as expected cross-cloud latency must not go above 10 ms in normal operation. CAST AI regions were measured to
operate in a 5-7 ms range. Once we have the network in place, VMs are added to take the role of Kubernetes Masters and
Workers. You can add or remove Worker nodes later on, based on your need. But currently, the count and size of Master
nodes are decided during cluster creation.

Once we have the network in place VMs are added to take the role of Kubernetes Masters and Workers. You can add or
remove Worker nodes, later on, based on your need. But currently, the count and size of Master nodes are decided during
cluster creation. Later on, the same CAST AI engine reconciles the created a cluster every hour to make sure that it’s
still in the desired state. In this context, reconciling means going through all your cloud resources and ensuring the
required configuration.

Later on every hour same CAST AI engine reconciles created a cluster to make sure that it’s still in the desired state.
By saying reconcile I mean that it goes through all your cloud resources and ensures required configuration. If you
manually delete any resources from provided CSP accounts, CAST AU would recreate them to the specification provided by
you in the console. During the time of reconciliation, no instant changes to the cluster are allowed. You can only apply
them after the reconciliation.

if you would manually delete any resources from provided CSP accounts we would recreate them to the specification
provided by you in CAST AI console. During the time of reconciliation, no instant changes to the cluster will be
allowed. They can be applied after the reconciliation. When you’re done with your cluster, you can delete it via the
CAST AI console. This operation will terminate all VMs and delete cloud resources like attached storage, public IPs, VPN
connections, network subnets, etc. Basically, this makes your cloud accounts look like prior to using
CAST AI Kubernetes.

When you’re done with your cluster, you can delete it via the CAST AI console. This operation will terminate all VMs and
delete cloud resources like attached storage, public IPs, VPN connections, network subnets, etc. Basically, this makes
your cloud accounts look like prior to using CAST AI Kubernetes.
