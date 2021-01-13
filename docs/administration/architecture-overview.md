TODO

* Overview
* Cloud credentials
* Reconcile mechanism
* Telemetry
* Addons
* Telemetry


# Your cluster: architecture overview

This chapter summarizes the overall design of your Kubernetes cluster and how it interacts with CAST AI platform.

# Provisioning

You initiate creation of the cluster by providing CAST AI with:

* Access to your Cloud accounts - CAST AI uses these to call cloud APIs to build your infrastructure for you;
* Initial configuration of your cluster, like region or size of the control plane. We aim to keep these options to a minimum and use our own opinionated setup where appropriate.

# Autoscaling 

You'll notice that CAST AI clusters don't have a "node pool" concept you might be familiar with. Instead



zones

open ports


traffic

## AWS

node roles

## GCP

No node permissions