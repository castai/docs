# GCP GKE

## Connect cluster

To connect your cluster, [login to the CAST AI console](https://console.cast.ai/external-clusters/new) and navigate to **Connect cluster** window, [**GKE**](https://console.cast.ai/external-clusters/new#gke) tab. Follow the instructions in order to provide the required details.

Once all details about your cluster are entered, generation of the onboarding script will be completed. Copy the script and run it your terminal or cloud shell. Make sure that kubectl is installed and can access your cluster.

![img.png](../../screenshots/connect-gke-1.png)

Script will create `castai-agent` namespace and deployment. After the installation, your cluster should appear at the bottom of the screen as well as in the **Clusters** list.

![img.png](../../screenshots/connect-gke-2.png)

From there, you can open **Available savings** report and explore detailed savings estimate based on your cluster configuration.

!!! note ""
    Agent will run in read-only mode providing saving suggestions without any actual modifications.

## Credential onboarding

To unlock all the benefits and enable automatic cost optimization, CAST AI must have access to your cluster. The following
section describes the steps required to onboard the GKE cluster on the CAST AI console. To make it less troublesome, we have created
a script that automates most of the steps.

Prerequisites:

- `gcloud` - A command line tool for working with GKE services using commands in your command-line shell. For more
  information, see [Installing gcloud](https://cloud.google.com/sdk/docs/install).

- `IAM permissions` – The IAM user that you're using must have:
    - Access to project where the cluster is created.
    - Permissions to work with IAM, GKE and Compute resources.
    - The CAST AI agent has to be running on the cluster.

Onboarding steps:

To onboard your cluster, go to the **Available Savings** report and click on the **Start saving** or **Enable CAST AI** button. The button's name will depend on the number of optimizations available from your cluster.

Follow the instruction in the pop-up window to import your GKE service account key (json).

The script will create a new GKE service account with the required roles and print out service account json which then can be added to the CAST AI console and assigned to the corresponding GKE cluster.

The generated user will have the following permissions:

- `/roles/cast.gkeAccess` (created by script) - access to get / update your GKE cluster and manage compute instances.
- `roles/container.developer` - access to resources within the kubernetes cluster.

That’s it! Your cluster is onboarded. You can now enable [policies](https://docs.cast.ai/console-overview/policies/) to keep your cluster configuration optimal.

[Connect your cluster here](https://console.cast.ai/external-clusters/new#gke)

## Disconnect GKE cluster

In order to disconnect your cluster from CAST AI click **Disconnect cluster** button in **Clusters** list and follow the guidance.  Alternatively run following command from your terminal used to access the cluster:

```bash
kubectl delete deployment castai-agent -n castai-agent
```

Once cluster is disconnected its `Status` will change to `Disconnected` and you can choose to remove it from console by pressing **Delete cluster** button.

!!! note ""
    Cluster will continue to run as normal, since **Delete cluster** action only removes it from CAST AI console.
