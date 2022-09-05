---
description: What Cloud Providers' (AWS / GCP / Azure) permissions CAST AI components use
---

# Permissions Setup Used In Cloud Providers (AWS / GCP / Azure)

When cluster is promoted to Phase 2 (cost optimisation is enabled) then CAST AI central system is able to perform operations on Cloud Provider (AWS / GCP / Azure) level (like for example request a node and add it to a cluster).
Such operations require relevant Cloud Provider specific credentials and permissions.
Below there is a description of the permission setup done for AWS and GCP Cloud Provider (similar description for Azure will be released shortly as well).

## AWS

### AWS User used by CAST AI

[Phase 2 on-boarding script](https://api.cast.ai/v1/scripts/eks/onboarding.sh){target="_blank"} creates a dedicated AWS user used by CAST AI to request and manage AWS resources on customer's behalf.
This user follows `cast-eks-<cluster name>` convention:

```shell
» aws iam list-users --output text|grep cast-eks-
USERS   arn:aws:iam::123456789012:user/cast-eks-some-cluster   2022-05-12T12:48:47+00:00   /   123456789012345678901   cast-eks-some-cluster
```

### AWS permissions used by CAST AI

Once user is created, following policies are attached to the AWS user:

| API Group               | Type               | Description                                                                           |
|-------------------------|:-------------------|---------------------------------------------------------------------------------------|
| AmazonEC2ReadOnlyAccess | AWS managed policy | Used to fetch details about Virtual Machines                                          |
| IAMReadOnlyAccess       | AWS managed policy | Used to fetch required data from IAM                                                  |
| CastEKSPolicy           | Managed policy     | CAST AI policy for creating and removing Virtual Machines when managing Cluster nodes |
| CastEKSRestrictedAccess | Inline policy      | CAST AI policy for Cluster Pause / Resume functionality                               |

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

### AWS permissions when access is granted using Cross-account IAM role

When enabling cost optimisation (Phase 2) for a connected cluster, there is an option to grant permissions using Cross-account IAM role.
This feature allows creating a dedicated cluster user in CAST AI AWS account with a trust policy to be able to 'assume role' defined in customer's AWS account.
Keeping role definition and users in separate AWS accounts allows keeping user's credentials on CAST AI side without handing them over when running on-boarding script, which provides higher security level.
From customer perspective used role contains the same set of permissions as in case of regular flow (when user is created in customer's AWS account), this can be verified using following command:

```shell
aws iam list-attached-role-policies --role-name <role name>
aws iam list-role-policies --role-name <role name>
```

Additionally, a trust relationship is created as follows:

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

## GCP

### Overview of GCP permissions used by CAST AI

[Phase 2 on-boarding script](https://api.cast.ai/v1/scripts/gke/onboarding.sh){target="_blank"} performs several actions to get required permissions to manage GKE and GCP resources on customer's behalf:

* Enables required GCP services and APIs for the project
* Creates IAM service account and assigns required roles to it
* Generates IAM service account key which is used by Cast AI components to manage GKE and GCP resources on customer's behalf

### GCP Services and APIs used by CAST AI

CAST AI enables following GCP services and APIs for the project on which customer's GKE cluster is running:

| GCP Service / API Group                                                                                            | Description                                                          |
|--------------------------------------------------------------------------------------------------------------------|:---------------------------------------------------------------------|
| [`serviceusage.googleapis.com`](https://cloud.google.com/service-usage/docs/reference/rest){target="_blank"}       | API to list, enable and disable GCP services                         |
| [`iam.googleapis.com`](https://cloud.google.com/iam/docs/reference/rest){target="_blank"}                          | API to manage identity and access control for GCP resources          |
| [`cloudresourcemanager.googleapis.com`](https://cloud.google.com/resource-manager/reference/rest){target="_blank"} | API to create, read, and update metadata for GCP resource containers |
| [`container.googleapis.com`](https://cloud.google.com/kubernetes-engine/docs/reference/rest){target="_blank"}      | API to manage GKE                                                    |
| [`compute.googleapis.com`](https://cloud.google.com/compute/docs/reference/rest/v1){target="_blank"}               | API to manage GCP virtual machines                                   |

### GCP Service Account used by CAST AI

[Phase 2 on-boarding script](https://api.cast.ai/v1/scripts/gke/onboarding.sh){target="_blank"} creates a dedicated GCP service account used by CAST AI to request and manage GCP resources on customer's behalf.
The Service Account follows `castai-gke-<cluster-name-hash>` convention. Service account can be verified by:

```shell
gcloud iam service-accounts describe castai-gke-<cluster-name-hash>@<your-gcp-project>.iam.gserviceaccount.com
```

CAST AI created Service Account has the following roles attached:

| Role name                | Description                                                                                                         |
|--------------------------|:--------------------------------------------------------------------------------------------------------------------|
| `castai.gkeAccess`       | CAST AI managed role used to manage Cast AI add/delete node operations, full list of permissions can be found below |
| `container.developer`    | GCP managed role for full access to Kubernetes API objects inside Kubernetes cluster                                |
| `iam.serviceAccountUser` | GCP managed role to allow run operations as the service account                                                     |

Full list of `castai.gkeAccess` role permissions:

```shell
» gcloud iam roles describe --project=<your-project-name> castai.gkeAccess

description: Role to manage GKE cluster via CAST AI
etag: example-tag
includedPermissions:
- compute.addresses.use
- compute.disks.create
- compute.disks.setLabels
- compute.disks.use
- compute.images.useReadOnly
- compute.instanceGroupManagers.get
- compute.instanceGroupManagers.update
- compute.instanceGroups.get
- compute.instanceTemplates.create
- compute.instanceTemplates.delete
- compute.instanceTemplates.get
- compute.instanceTemplates.list
- compute.instances.create
- compute.instances.delete
- compute.instances.get
- compute.instances.list
- compute.instances.setLabels
- compute.instances.setMetadata
- compute.instances.setServiceAccount
- compute.instances.setTags
- compute.instances.start
- compute.instances.stop
- compute.networks.use
- compute.networks.useExternalIp
- compute.subnetworks.get
- compute.subnetworks.use
- compute.subnetworks.useExternalIp
- compute.zones.get
- compute.zones.list
- container.certificateSigningRequests.approve
- container.clusters.get
- container.clusters.update
- container.operations.get
- serviceusage.services.list
name: projects/<your-project-name>/roles/castai.gkeAccess
stage: ALPHA
title: Role to manage GKE cluster via CAST AI
```
