# Remove CAST resources from EKS cluster

Based on the way how CAST was used on a cluster there are two options to remove CAST resources from EKS cluster.

## Disconnect EKS cluster

If you connected a cluster to CAST AI to explore Savings report then all you need to do to disconnect is to run following command from your terminal used to access your cluster:

```bash
kubectl delete deployment castai-agent
```

## Removing CAST AI credentials and other resources

When CAST was used to to optimize EKS cluster following resources were created on the cluster:

- CAST AI agent deployment
- Instances (if autoscaler was used)
- User
- Policy
- Roles
- Security group

To remove them follow the steps outlined below.

### Prerequisites

In order to remove these resources first of all:

- Go to CAST AI console → Policies page → Disable all CAST AI policies
- Connect to your cluster from the terminal and run command:

```bash
kubectl delete deployment castai-agent
```

With above mentioned pre-requisites completed please follow next steps in AWS Management Console:

### Delete Instance(s) created by CAST

Go to EC2 dashboard → Security groups → Instances → find CAST created instance(s) “*cluster-name*-cast-#####…”. Terminate instance(s).

If you have you used PODs with attached storage go to Volumes and delete Volumes attached to CAST AI created nodes.

### Delete security group

Go to EC2 dashboard → Security groups → find “cast-*cluster-name*-cluster/CastNodeSecurityGroup”. Delete security group.

### Delete CAST user

Go to AWS console → Identity and Access Management (IAM) → Users → find “cast-eks-*cluster-name*” user. Select the user and click Delete user.

### Delete policy

Go to AWS console → Identity and Access Management (IAM) → Customer managed policies → find CastEKSPolicy. Mark it, go to Policy actions → Delete policy.

### Delete roles

Go to AWS console → Identity and Access Management (IAM) → Roles → find 2 roles:

- cast-*cluster-name*-eks-#######…

- *cluster-name*-lambda-role

Select and delete roles.
