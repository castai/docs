# Remove CAST resources from EKS cluster

Based on the way how CAST was used on a cluster there are two options to remove CAST resources.

## Disconnect EKS cluster

If you connected a cluster to CAST AI to explore Savings report then all you need to do to disconnect is to run following command from your terminal used to access your cluster:

```bash
kubectl delete deployment castai-agent -n castai-agent
```

## Removing CAST AI credentials and other resources

When CAST was used to to optimize EKS cluster following resources were created:

- CAST AI agent deployment
- User
- Policy
- Roles
- Lambda function
- Instances
- Security group

To remove them follow the steps outlined below.

### Prerequisites

In order to remove these resources first of all:

- Go to CAST AI console → Policies page → Disable all CAST AI policies
- Connect to your cluster from the terminal and run command:

```bash
kubectl delete deployment castai-agent -n castai-agent
```

With above mentioned pre-requisites completed please follow next steps in AWS Management Console to remove CAST resources from your running cluster:

### Delete user

Go to AWS console → Identity and Access Management (IAM) → Users → find “cast-eks-*cluster-name*” user. Select the user and click Delete user.

### Delete policy

Go to AWS console → Identity and Access Management (IAM) → Customer managed policies → find CastEKSPolicy. Mark it, go to Policy actions → Delete policy.

### Delete Lambda role

Go to AWS console → Identity and Access Management (IAM) → Roles → find lambda role "*cluster-name*-lambda-role", delete it.

- cast-*cluster-name*-eks-#######…

### Delete Lambda function

Go to AWS console → Services → Lambda → find Lambda function "eks-*cluster-name*-events-listener" and delete it.

In case you are planning to delete the cluster, complete these additional steps before proceeding with deletion:

### Delete CAST role

Go to AWS console → Identity and Access Management (IAM) → Roles → find role "cast-*cluster-name*-eks-#######", delete it.

### Delete instances

Go to EC2 dashboard → Security groups → Instances → find CAST created instance(s) “*cluster-name*-cast-#####…”. Terminate instance(s).

If you have you used PODs with attached storage go to Volumes and delete Volumes attached to CAST AI created nodes.

### Delete security group

Go to EC2 dashboard → Security groups → find “cast-*cluster-name*-cluster/CastNodeSecurityGroup”. Delete security group.
