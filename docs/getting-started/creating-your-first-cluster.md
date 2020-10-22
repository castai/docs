# Creating your first cluster

!!! note "TODO: pending documentation"
    Merge contents of https://help.cast.ai/en/articles/4500904

This guide covers very basics of creating your first Kubernetes cluster on Cast AI.

## Setting up cloud credentials

Before you're able to create your first cluster, you'll need to provide Cast AI access to your cloud accounts. Our platform will perform actions on your cloud account, like setting up network, security groups, creating VMs and Kubernetes cluster itself.

You'll need at least one set of credentials per each cloud you want to use in your multicloud cluster.

View, add and delete credentials in console on [Cloud Credentials](https://console.cast.ai/cloud-credentials) list; you can also add new credentials directly while [creating a new cluster](https://console.cast.ai/clusters:new).


-how-to-create-your-first-cluster
!!! note "TODO: pending documentation"
    Expand with screenshots
    
## Creating cluster

!!! note "TODO: pending documentation"
    Walk through basics
    
    * options
    * selecting clouds
    * observing progress
    
## Inspecting created cluster

!!! note "TODO: pending documentation"
    Cover what you get out of the box: dashboards, metrics, kubernetes UI


## Setting up kubectl

!!! note "TODO: pending documentation"
    Walk through basic setup: 
    
    * download kubeconfig and point kubectl to it; 
    * provide basic commands to inspect cluster from within, e.g. `get nodes`;
    * deploy sample application
    
    merge contents of:
    
    * https://help.cast.ai/en/articles/4387550-how-to-deploy-the-application
    

    
