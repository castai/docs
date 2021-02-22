# Overview

This guide will help you get started and deploy your first cluster with CAST AI.

To start using CAST AI you will need:

- An account - [sign up here](https://console.cast.ai/signup)
- Cloud credentials - [join slack and claim free trial](https://join.slack.com/t/castai-community/shared_invite/zt-kxomy09z-p_tbccVJ61azObIt~GUjXQ)
- An application developed on Kubernetes

Refer to the table of contents on the right side to quickly navigate through this document.

**Estimated time to get started - 5-10 minutes.**

## Add cloud credentials

!!! tip
    You can skip this step if you have a free trial activated.

CAST AI will need your cloud credentials to call cloud APIs, so the platform can create, orchestrate and optimize clusters for you. CAST AI does not store your credentials or password. You can opt-out and remove them any time you want.

If you remove the credentials - you are free to use the Kubernetes provisioned cluster as it is but you will lose all the managed service benefits and features that CAST AI offers.

<details>
<summary>Amazon Web Services credentials</summary>
<p>
To add AWS credentials you will need: <b>Access key ID , Secret access key</b>
<br>
<ol>
<li>Add a new user</li>
<ul><li> Open <a href="https://console.aws.amazon.com">https://console.aws.amazon.com</a></li>
<li> Open the IAM service, then go to Users and click on Add user</li>
<li> Select <b>Programmatic access</b></li>
</ul>
<li>Create a new group
<br>
   <ul><li> Select the following permissions as</li>
   <li><b> AmazonVPCFullAccess, AmazonEC2FullAccess</b> and <b>IAMFullAccess</b></li>
   </ul>
<li>Paste cloud credentials
<br>
   <ul><li> Once you reach the last page ("Create user"), copy the <b>access key ID</b> and <b>secret access key</b>, and paste them to the form in CAST AI console.</li></ul>
   <br>
   <a href="ttps://docs.aws.amazon.com/eks/latest/userguide/security-iam.html#security_iam_access-manage">Documentation on AWS Identity and Access Management.</a>
   </p>
</details>

<details>
  <summary>Azure cloud credentials</summary>
 <p>
To add Azure credentials you will need: <b>Directory (Tenant) ID, Application (Client ID), Client Secret, Subscription ID</b>
<br>
To get started, you need to create an Active Directory (AD) service principal in your Azure account and assign the required permissions.
<ol>
<li>Create App registration
 <ul>
   <li> Open <a href="https://portal.azure.com">https://portal.azure.com</a>
   <li> Go to App registrations -> New registration -> Enter display name -> click Register.
   <li> Paste in the <b>Directory (tenant) ID</b> to the form on the left side.
   <li> Paste in the <b>Application (client) ID</b> to the form on the left side.
   <li> Select Certificates & secrets in the left sidebar menu.
   <li> Create a new client secret without expiration.
   <li> Paste in the new client secret value to the form on the left side, to the <b>Client Secret</b> field.
 </ul>
<li>Give access to the CAST AI application by requesting a sign-in using a browser
 <ul>
   <li> Accept CAST AI application.
   <li> After Sign-in you should see <b>Permissions requested</b> window. Click Accept which will allow you to add the CAST AI application role.
</ul>
<li>Assign the roles
 <ul>
   <li> Open Subscriptions page and go to your subscription.
   <li> Paste in the <b>Subscription ID</b> to the form on the left side.
   <li> Select the Access Control (IAM) in the left sidebar menu.
   <li> Add the role assignment with Role: Contributor, and in the Select search field type your Client Secret (created during the first step).
   <li> Add another role assignment with Role: Contributor, and in the Select input field search for <b>CAST AI Shared Images</b> then click save (if the role is not visible please check previous step and try again).
  </ul>
  </ol>
  <br>
<a href="https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals">Documentation on Azure Cloud EKS IAM Policies, Roles, and Permissions.</a>
 </p>
</details>

<details>
  <summary>Digital Ocean credentials</summary>
 <p>
To add Digital Ocean credentials you will need: <b>Personal Access Token</b>
<br>
To get started, you need to create a Personal Access Token and define its access permissions.
<ol>
<li>Sign into your <a href="https://cloud.digitalocean.com/">Digital Ocean</a> account
<li>Click the <b>API tab</b> on the left sidebar at the bottom
   <ul><li> <a href="https://cloud.digitalocean.com/account/api/tokens">API tokens</a></ul>
<li>Click <b>Generate New Token</b> in the Personal Access Token section
<li>Add a name and select both the <b>read</b> and <b>write</b> scopes
<li>Click <b>Generate Token</b>
<li>The token will be displayed only once under the name you gave it. Paste the token in the credentials form in CAST AI console.
</ol>
 </p>
</details>

<details>
  <summary>Google Cloud Platform credentials</summary>
 <p>
To add GCP credentials you will need: <b>Service Account JSON</b>
<br>
To get started, you need to create a service account in your Google Cloud Platform account and assign the required permissions.
<ol>
<li>Enable APIs for your project
<ul>
   <li> <a href="https://console.cloud.google.com/apis/api/iam.googleapis.com/overview">Identity and Access Management (IAM) API</a>
   <li> <a href="https://console.cloud.google.com/apis/api/cloudresourcemanager.googleapis.com/overview">Resource Manager API</a>
   <li> <a href="https://console.cloud.google.com/apis/api/compute.googleapis.com/overview">Compute Engine API</a>
</ul>
<li>Create Service account
</ol>
<ul>
   <li> Open <a href="https://console.cloud.google.com">https://console.cloud.google.com</a>
   <li> Select IAM & Admin and go to Service accounts
   <li> Create a new service account and assign these roles
   <ul>
     <li> Compute Admin
     <li> +add another role - Service Account User
     <li> +add another role - Service Account Admin
     <li> +add another role - Role Administrator
     <li> +add another role - Service Account Key Admin
     <li> +add another role - Project IAM Admin
     </ul>
   <li> Once you have created a Service Account, open the Service Accounts list view and find your newly created account. Then click on the button in the <b>Actions</b> column and select Create key with Key type set to JSON.
   <li> After the JSON file is downloaded, copy its contents to the input field or click on the Read from file button to import the file.
   </ul>
 </p>
</details>
   
   
## Create cluster

Once you have [cloud credentials](../getting-started/#add-cloud-credentials) - you are ready to create a cluster. In the cluster creation window you will have a few options to lay a base foundation for your cluster, which we will be able to further customize to your needs once a cluster is up and running.

**1. Cluster details**

The new cluster will be created with the name and in the region, you specify here.
After the cluster is created, name and region can’t be changed.

   - Name your cluster (2-50 symbols, only letters, numbers, and hyphens allowed)

   - Select a region. Your cluster will be located in the selected region.
   
**2. Cluster configuration**

Select initial cluster configuration. It may be automatically adjusted based on scaling and cost optimization policies. You will be able to adjust policies once the cluster is created. You may also manually add nodes once the cluster is provisioned.

**3. Cloud providers**

Select the cloud provider(s) you would like to use for this cluster. You will need to select credentials that you would like to use for each provider, please refer to [Adding credentials] section if you have no credentials added.

**4. Cluster virtual private network**

Select preferred encrypted connection type. Cloud provided VPN is a default VPN provided by the respective cloud service providers. WireGuard is a CAST AI integrated choice of VPN that [significantly reduces cloud cost].

- WireGuard VPN: Full Mesh - network traffic is encrypted between all nodes
- WireGuard VPN: Cross Location Mesh - network traffic is encrypted only between nodes in different clouds
- Cloud provided VPN - default network encryption provided by selected CSPs

## Deploy application

CAST AI managed cluster runs on Kubernetes. Once you have a cluster running - you can download a **`kubeconfig` file** of the cluster and deploy your application using **`kubectl`** command-line tool.

![](downloadkubeconfig.png)

For more information please refer to [Kubernetes documentation](https://kubernetes.io/docs/home/).

Relevant for this section:

- [Kubernetes docs - Organizing cluster access using kubeconfig files](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/)

- [Kubernetes docs - Deploy an app using kubectl](https://kubernetes.io/docs/tutorials/kubernetes-basics/deploy-app/deploy-intro/)
