## Overview

This guide will help you get started and deploy your first cluster with CAST AI.

To start using CAST AI you will need:
- An account - [sign up here](https://console.cast.ai/signup)
- Cloud credentials - [join slack and claim free trial](https://join.slack.com/t/castai-community/shared_invite/zt-kxomy09z-p_tbccVJ61azObIt~GUjXQ)
- An application developed on Kubernetes

Refer to the table of contents on the right side to quickly navigate through this document.

**Estimated time to get started - 5 minutes.**

## Adding cloud credentials

You can skip this step if you have a free trial activated.

CAST AI will need your cloud credentials to call cloud APIs, so the platform can create, orchestrate and optimize clusters for you. CAST AI does not store your credentials anywhere, and you can opt out and remove them any time you want. If you remove the credentials - you are free to use the Kubernetes provisioned cluster as it is but you will lose all the managed service benefits and features that CAST AI offers.

### Amazon Web Services credentials

To add AWS credentials you will need: **Access key ID**, **Secret access key**

1. Add a new user
   - Open https://console.aws.amazon.com
   - Open the IAM service, then go to Users and click on Add user
   - Select **Programmatic access**
2. Create a new group
   - Select the following permissions as
   - **AmazonVPCFullAccess**, **AmazonEC2FullAccess** and **IAMFullAccess**
3. Paste cloud credentials
   - Once you reach the last page ("Create user"), copy the **access key ID** and **secret access key**, and paste them to the form in CAST AI console.
   
 [Documentation on AWS Identity and Access Management](https://docs.aws.amazon.com/eks/latest/userguide/security-iam.html#security_iam_access-manage)
   
### Azure cloud credentials

To add Azure credentials you will need: **Directory (Tenant) ID, Application (Client ID), Client Secret, Subscription ID**

To get started, you need to create an Active Directory (AD) service principal in your Azure account and assign the required permissions.

1. Create App registration
   - Open https://portal.azure.com
   - Go to App registrations -> New registration -> Enter display name -> click Register.
   - Paste in the **Directory (tenant) ID** to the form on the left side.
   - Paste in the **Application (client) ID** to the form on the left side.
   - Select Certificates & secrets in the left sidebar menu.
   - Create a new client secret without expiration.
   - Paste in the new client secret value to the form on the left side, to the **Client Secret** field.
2. Give access to the CAST AI application by requesting a sign-in using a browser
   - Accept CAST AI application.
   - After Sign-in you should see **Permissions requested** window. Click Accept which will allow you to add the CAST AI application role.
3. Assign the roles
   - Open Subscriptions page and go to your subscription.
   - Paste in the **Subscription ID** to the form on the left side.
   - Select the Access Control (IAM) in the left sidebar menu.
   - Add the role assignment with Role: Contributor, and in the Select search field type your Client Secret (created during the first step).
   - Add another role assignment with Role: Contributor, and in the Select input field search for **CAST AI Shared Images** then click save (if the role is not visible please check previous step and try again).
   
[Documentation on Azure Cloud EKS IAM Policies, Roles, and Permissions.](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals)

### Digital Ocean credentials

To add Digital Ocean credentials you will need: **Personal Access Token**

To get started, you need to create a Personal Access Token and define its access permissions.
1. Sign into your [Digital Ocean](https://cloud.digitalocean.com/) account
2. Click the **API tab** on the left sidebar at the bottom
   - [API tokens](https://cloud.digitalocean.com/account/api/tokens)
3. Click **Generate New Token** in the Personal Access Token section
4. Add a name and select both the **read** and **write** scopes
5. Click **Generate Token**
6. The token will be displayed only once under the name you gave it. Paste the token in the credentials form in CAST AI console.

### Google Cloud Platform credentials

To add GCP credentials you will need: **Service Account JSON**

To get started, you need to create a service account in your Google Cloud Platform account and assign the required permissions.
1. Enable APIs for your project
   - [Identity and Access Management (IAM) API](https://console.cloud.google.com/apis/api/iam.googleapis.com/overview)
   - [Resource Manager API](https://console.cloud.google.com/apis/api/cloudresourcemanager.googleapis.com/overview)
   - [Compute Engine API](https://console.cloud.google.com/apis/api/compute.googleapis.com/overview)
2. Create Service account
   - Open https://console.cloud.google.com
   - Select IAM & Admin and go to Service accounts
   - Create a new service account and assign these roles
     - Compute Admin
     - +add another role - Service Account User
     - +add another role - Service Account Admin
     - +add another role - Role Administrator
     - +add another role - Service Account Key Admin
     - +add another role - Project IAM Admin
   - Once you've created a Service Account, open the Service Accounts list view and find your newly created account. Then click on the button in the **Actions** column and select Create key with Key type set to JSON.
   - After the JSON file is downloaded, copy its contents to the input field or click on the Read from file button to import the file.
   
## Create cluster

Once you have cloud credentials - you are ready to create a cluster. In cluster creation window you will have a few options to lay a base foundation for your cluster, which we will be able to further customize to your needs once a cluster is up and running.

**1. Cluster details**

The new cluster will be created with the name and in the region you specify here.
After the cluster is created, name and region can’t be changed.

   - Name your cluster (2-50 symbols, only letters, numbers and hyphens allowed)

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

## Deploying application

CAST AI managed cluster runs on Kubernetes. Once you have a cluster running - you can download a **KubeConfig file** of the cluster and deploy your application using **kubectl** command-line tool.

[screenshot]

For more information please refer to [Kubernetes documentation](https://kubernetes.io/docs/home/).

Relevant for this section:

- [Organizing cluster access using kubeconfig files](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/)

- [Deploy an app using kubectl](https://kubernetes.io/docs/tutorials/kubernetes-basics/deploy-app/deploy-intro/)
