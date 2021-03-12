# AWS

To add AWS credentials you will need: **Access key ID , Secret access key**.

1. Add a new user

     - Open <https://console.aws.amazon.com>
     - Open the IAM service, then go to Users and click on Add user
     - Select **Programmatic access**

2. Create a new group

     - Select the following permissions: **AmazonVPCFullAccess, AmazonEC2FullAccess, IAMFullAccess**

3. Paste cloud credentials

     - Once you reach the last page ("Create user"), copy the **access key ID** and **secret access key**
     - Navigate to [cloud credentials](https://console.cast.ai/cloud-credentials) page in CAST AI console and select AWS
     - Paste keys to the form in CAST AI console and click **create**

[Documentation on AWS Identity and Access Management.](https://docs.aws.amazon.com/eks/latest/userguide/security-iam.html#security_iam_access-manage)

!!! tip ""
    Next step: [create cluster](../../getting-started/create-cluster.md)
