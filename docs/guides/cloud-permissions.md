---
description: What Cloud Providers' permissions CAST AI components use
---

# Permissions Setup Used In Cloud Providers

When cluster is promoted to Phase 2 (cost optimisation is enabled) then CAST AI central system is able to perform operations on Cloud Provider level (like for example request a node and add it to a cluster).
Such operations require relevant Cloud Provider specific credentials and permissions.
Below there is a description of permission setup done for the support Cloud Providers.


## AWS User used by CAST AI

[Phase 2 on-boarding script](https://api.cast.ai/v1/scripts/eks/onboarding.sh) creates a dedicated AWS user used by CAST AI to request and manage AWS resources on customer's behalf.
This user follows `cast-eks-<cluster name>` convention:
```shell
» aws iam list-users --output text|grep cast-eks-
USERS	arn:aws:iam::123456789012:user/cast-eks-some-cluster	2022-05-12T12:48:47+00:00	/	123456789012345678901	cast-eks-some-cluster
```


## AWS permissions used by CAST AI

Once user is created, following policies are attached to the AWS user:

| API Group                       | Type               | Description                                                                           |
|---------------------------------|:-------------------|---------------------------------------------------------------------------------------|
| AmazonEC2ReadOnlyAccess         | AWS managed policy | Used to fetch details about Virtual Machines                                          |
| IAMReadOnlyAccess               | AWS managed policy | Used to fetch required data from IAM                                                  |
| CastEKSPolicy                   | Managed policy     | CAST AI policy for creating and removing Virtual Machines when managing Cluster nodes |
| CastEKSRestrictedAccess         | Inline policy      | CAST AI policy for Cluster Pause / Resume functionality                               |

These policies may be validated by combining results from the following commands (please look up AWS documentation about the details how to used that):
```shell
aws iam list-user-policies --user-name <user name>
aws iam list-attached-user-policies --user-name <user name>
aws iam list-groups-for-user --user-name <user name>
```

The result also contains policies' arn's which is required for inspecting permissions, which can be done using following commands:

```shell
» aws iam list-policy-versions --policy-arn arn:aws:iam::123456789012:policy/CastEKSPolicy
{
    "Versions": [
        {
            "VersionId": "v83",
            "IsDefaultVersion": true,
            "CreateDate": "2022-05-12T12:49:01+00:00"
        },
        {
            "VersionId": "v82",
            "IsDefaultVersion": false,
            "CreateDate": "2022-05-12T09:53:58+00:00"
        }
    ]
}
```
... and then:

```shell
» aws iam get-policy-version --policy-arn arn:aws:iam::123456789012:policy/CastEKSPolicy --version-id v83
{
    "PolicyVersion": {
        "Document": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "PassRoleEC2",
                    "Action": "iam:PassRole",
                    "Effect": "Allow",
                    "Resource": "arn:aws:iam::*:role/*",
                    "Condition": {
                        "StringEquals": {
                            "iam:PassedToService": "ec2.amazonaws.com"
                        }
                    }
                },
                {
                    "Sid": "NonResourcePermissions",
                    "Effect": "Allow",
                    "Action": [
                        "iam:DeleteInstanceProfile",
                        "iam:RemoveRoleFromInstanceProfile",
                        "iam:DeleteRole",
                        "iam:DetachRolePolicy",
                        "iam:CreateServiceLinkedRole",
                        "iam:DeleteServiceLinkedRole",
                        "ec2:CreateSecurityGroup",
                        "ec2:CreateKeyPair",
                        "ec2:DeleteKeyPair",
                        "ec2:CreateTags",
                        "ec2:ImportKeyPair"
                    ],
                    "Resource": "*"
                },
                {
                    "Sid": "RunInstancesPermissions",
                    "Effect": "Allow",
                    "Action": "ec2:RunInstances",
                    "Resource": [
                        "arn:aws:ec2:*:028075177508:network-interface/*",
                        "arn:aws:ec2:*:028075177508:security-group/*",
                        "arn:aws:ec2:*:028075177508:volume/*",
                        "arn:aws:ec2:*:028075177508:key-pair/*",
                        "arn:aws:ec2:*::image/*"
                    ]
                }
            ]
        },
        "VersionId": "v83",
        "IsDefaultVersion": true,
        "CreateDate": "2022-05-12T12:49:01+00:00"
    }
}
```


## AWS permissions when access is granted using Cross-account IAM role

When enabling cost optimisation (Phase 2) for a connected cluster, there is an option to grant permissions using Cross-account IAM role.
This feature allows creating a dedicated cluster user in CAST AI AWS account with a trust policy to be able to 'assume role' defined in customer's AWS account.
Keeping role definition and users in separate AWS accounts allows keeping user's credentials on CAST AI side without handing them over when running on-boarding script, which provides higher security level.
From customer perspective used role contains the same set of permissions as in case of regular flow (when user is created in customer's AWS account), this can be verified using following command:
```shell
aws iam list-attached-role-policies --role-name <role name>
aws iam list-role-policies --role-name <role name>
```

Additional a trust relationship is created like following:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::123456789012:user/cast-crossrole-f8f82b9c-d375-40d2-9483-123456789012"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```
