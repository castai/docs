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
  * observing


Start by logging into your account. You can create a new cluster in two ways:

1) Click on this button in top right corner:
   ![](2020-10-28-17-05-33.png)
2) Find a pop-up in the middle of the screen where you can also click and add a new cluster.

At this point, we will ask you to enter your cluster name and select its region of multi-cloud providers. Make sure that the cluster name starts with a letter and use hyphens between the letters (no numbers or other characters are allowed).

![](2020-10-28-17-06-12.png)

Now you can select your preferred cluster configuration. Note that this is just an initial configuration and it will be adjusted by the scaling and cost optimization policies.

![](2020-10-28-17-07-00.png)

The last step is to select a cloud provider and give CAST AI permission to manage your cluster automatically.

Click on one of these links to get your key adding instructions for:

* [GCP](https://help.cast.ai/en/articles/4365909-adding-the-gcp-access-keys)

* [AZURE](https://help.cast.ai/en/articles/4366116-adding-the-azure-access-keys)

* [AWS](https://help.cast.ai/en/articles/4323142-adding-the-aws-access-key)

After finishing this step, simply click on this button and wait a few minutes for the cluster to initialize.



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





