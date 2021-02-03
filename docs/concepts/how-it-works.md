# How it works

Long story short, the CAST AI engine uses your Cloud Service Provider (CSP) accounts to create the required cloud resources and set up a multi-cloud cluster for you. You can start using multi-cloud Kubernetes with just a few clicks.

## To get a bit more technical

CAST AI uses your owned and provided CSP accounts to create VPCs or Resource Groups (depending on which cloud services you use). Next, CAST AI creates the required network (like subnets, public IPs, and VPNs). This will be used to ensure a uniform network across created VPCs, which is required for a seamless Kubernetes operation. There are certain processes in place to help non-compatible clouds merge into a single flat network.

CAST AI selects regions with network latency in mind. For your applications and the cluster to function as expected, cross-cloud latency shouldn't go above 10 ms in normal operation. The CAST AI regions were measured to operate in a 5-7 ms range.

## Enter Kubernetes

Once we have the network in place, VMs are added to take the role of Kubernetes Masters and Workers. You can add or remove Worker nodes later on, based on your needs. But currently, the count and size of Master nodes are set during cluster creation. Later on, the same CAST AI engine reconciles the created cluster every hour to make sure that it’s still in the desired state. In this context, reconciling means going through all your cloud resources and ensuring the required configuration.

If you delete any resources from the provided CSP accounts manually, CAST AI recreates them to the specification provided by you in the console. During the time of reconciliation, no instant changes to the cluster are allowed. You can only apply them after the reconciliation.

## No mess to clean up

When you’re done with your cluster, you can delete it via the CAST AI console. This operation will terminate all VMs and delete cloud resources like the attached storage, public IPs, VPN connections, network subnets, etc. Basically, this makes your cloud accounts look like prior to using CAST AI Kubernetes.
