# How it works


!!! note "TODO: pending documentation"
    Explain product essentials: how CAST works;
    
    Revise Dima's document below
    
    
Long story short CAST AI engine uses your Cloud Service Providers' accounts to create required cloud resources and sets up a multi-cloud cluster for you. 
With few clicks of a button, you can start using multi-cloud Kubernetes.

To get a bit more technical; using your owned and provided Cloud Service Provider (CSP) accounts CAST AI will create VPCs or Resource Groups (depending which clouds you use), further on the required network will be created like subnets, public IPs and VPNs. 


Latter will be used to ensure uniform network across created VPCs which is required for seamless Kubernetes operation. There are certain processes in place to make non-compatible clouds merge into a single flat network.

CAST AI regions are selected with network latency in mind. In order for your applications and the cluster itself to function as expected cross-cloud latency must not go above 10 ms in normal operation. CAST AI regions were measured to operate in a 5-7 ms range.

Once we have the network in place VMs are added to take the role of Kubernetes Masters and Workers. You can add or remove Worker nodes, later on, based on your need. But currently, the count and size of Master nodes are decided during cluster creation.

Later on every hour same CAST AI engine reconciles created a cluster to make sure that it’s still in the desired state. By saying reconcile I mean that it goes through all your cloud resources and ensures required configuration. 

if you would manually delete any resources from provided CSP accounts we would recreate them to the specification provided by you in CAST AI console. During the time of reconciliation, no instant changes to the cluster will be allowed. They can be applied after the reconciliation.

When you’re done with your cluster it can be deleted through CAST AI console. This operation will terminate all VMs and delete cloud resources like attached storage, public IPs, VPN connections, network subnets etc. Basically making your cloud accounts look the same as prior using CAST AI Kubernetes.
    
    