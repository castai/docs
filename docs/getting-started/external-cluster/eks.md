# AWS EKS

## Connect cluster

To connect your EKS cluster, login to the CAST console and navigate to `Connect cluster` window. Copy following script
and run it your terminal or cloud shell. Make sure that kubectl is installed and that it can access your cluster.

![img.png](../screenshots/connect-cluster-2.png)

After installation, your EKS cluster should appear in cluster list. From there you can open cluster details and explore
detailed savings estimate based on your cluster configuration.

![img.png](../screenshots/connect-cluster-3.png)

!!! note ""
    Agent will run in read-only mode providing saving suggestions without any actual modifications.

## Credential onboarding

To unlock all benefits and enable automatic cost optimization CAST AI must have access to your cluster. Following
section will describe steps needed to onboard EKS cluster on CAST console. To make it less troublesome we have created
script that automates most of the steps.

Prerequisites:

- `AWS CLI` - A command line tool for working with AWS services using commands in your command-line shell. For more
  information, see [Installing AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).

- `eksctl` – A command line tool for working with EKS clusters that automates many individual tasks. This guide requires
  that you use version 0.43.0 or later. For more information,
  see [The eksctl command line utility](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html).

- **IAM permissions** – The IAM security principal that you're using must have permissions to work with AWS EKS, AWS IAM
  and related resources. Additionally, you should have access to EKS cluster that you wish to onboard on CAST console.

When you create an Amazon EKS cluster, the IAM entity user or role, such as a federated user that creates the cluster,
is automatically granted `system:masters` permissions in the cluster's RBAC configuration in the control plane. To grant
additional AWS users or roles the ability to interact with your cluster, you must edit the `aws-auth` ConfigMap within
Kubernetes. For more information,
see [Managing users or IAM roles for your cluster](https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html)

Run following script to reduce number of manual steps mentioned above.

```bash
REGION=<region> CLUSTER_NAME=<name> /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/castai/docs/main/docs/getting-started/credentials/configuring-eks-credentials/script.sh)"
```

It will create a new AWS user with the required permissions, modify `aws-auth` ConfigMap, and print AWS `AccessKeyId`
and `SecretAccessKey` which then can be added to CAST console and assigned to corresponding EKS cluster.
