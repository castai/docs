---
description: Time to say goodbye? You can choose from two different options to remove CAST resources based on how you used CAST AI in your cluster.
---

# Remove CAST resources from kOps cluster

Based on the way how CAST was used on a cluster there are two options to remove CAST resources.

## Disconnect kOps cluster

In order to disconnect your cluster from CAST AI click **Disconnect cluster** button in **Clusters** list and follow the guidance.  Alternatively run following command from your terminal used to access the cluster:

```bash
kubectl delete deployment castai-agent -n castai-agent
```

On top of that, also delete following kubernetes objects related to `castai-agent` agent:

- namespace
- serviceaccount and secret
- clusterrole and clusterrolebinding
- role and rolebinding
- resourcequota
- configmap

Once cluster is disconnected its `Status` will change to `Disconnected` and you can choose to remove it from console by pressing **Delete cluster** button.

!!! note ""
    Cluster will continue to run as normal, since **Delete cluster** action only removes it from CAST AI console.

## Removing CAST AI credentials and other resources

When CAST was used to to optimize kOps cluster following resources were created:

- CAST AI agent deployment
- User
- Policies
- Roles
- Lambda function
- Instances
- Security group

To remove them follow the steps outlined below.

### Prerequisites

In order to remove these resources first of all:

- Go to CAST AI console → **Autoscaler** page → Disable all CAST AI policies
- Connect to your cluster from the terminal and run command:

```bash
kubectl delete deployment castai-agent -n castai-agent
```

With above mentioned pre-requisites completed please follow next steps in AWS Management Console to remove CAST resources from your running cluster:

### Delete user

Go to AWS console → Identity and Access Management (IAM) → Users → find `cast-kops-*cluster-name*`  user. Select the user and click Delete user.

### Delete policies

Go to AWS console → Identity and Access Management (IAM) → Customer managed policies → find `CASTKopsPolicyV2` and `CASTKopsRestrictedaccess`. Mark it, go to Policy actions → Delete policy.

### Delete Lambda role

Go to AWS console → Identity and Access Management (IAM) → Roles → find lambda role `CastLambdaRoleForSpot`, delete it.

### Delete Lambda function

Go to AWS console → Services → Lambda → find Lambda function `cast-ai-ec2-events-handler` and delete it.

In case you are planning to delete the cluster, complete these additional steps before proceeding with deletion:

### Delete instances

Go to EC2 dashboard → Security groups → Instances → find CAST created instance(s) `*cluster-name*-cast-#####…`. Terminate instance(s).

If you have you used PODs with attached storage go to Volumes and delete Volumes attached to CAST AI created nodes.

### Delete security group

Go to EC2 dashboard → Security groups → find `cast-*cluster-name*-cluster/CastNodeSecurityGroup`. Delete security group.
