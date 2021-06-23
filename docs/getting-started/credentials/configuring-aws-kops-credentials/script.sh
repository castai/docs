#!/bin/bash
set -e

export AWS_PAGER=""

if [ -z $CLUSTER_NAME ]; then
  echo "CLUSTER_NAME environment variable is not defined"
  exit 1
fi

if [ -z $REGION ]; then
  echo "REGION environment variable is not defined"
  exit 1
fi

if ! [ -x "$(command -v aws)" ]; then
  echo "Error: aws cli is not installed"
  exit 1
fi

echo "Validating cluster"
if [[ "$(aws ec2 describe-instances --region $REGION --filter Name=tag:KubernetesCluster,Values=$CLUSTER_NAME --output text --query 'length(Reservations[*])')" == "0" ]]; then
  echo "Error: failed to find cluster '${CLUSTER_NAME}' resources, please check cluster name"
  exit 1
fi

USER_NAME=cast-kops-${CLUSTER_NAME}
POLICY_NAME='CastKopsPolicy'
ACCOUNT_NUMBER=$(aws sts get-caller-identity --output text --query 'Account')

POLICY_JSON="{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"PassRoleEC2\",\"Action\":\"iam:PassRole\",\"Effect\":\"Allow\",\"Resource\":\"arn:aws:iam::*:role/*\",\"Condition\":{\"StringEquals\":{\"iam:PassedToService\":\"ec2.amazonaws.com\"}}},{\"Sid\":\"PassRoleLambda\",\"Action\":\"iam:PassRole\",\"Effect\":\"Allow\",\"Resource\":\"arn:aws:iam::*:role/*\",\"Condition\":{\"StringEquals\":{\"iam:PassedToService\":\"lambda.amazonaws.com\"}}},{\"Sid\":\"NonResourcePermissions\",\"Effect\":\"Allow\",\"Action\":[\"iam:CreateInstanceProfile\",\"iam:DeleteInstanceProfile\",\"iam:CreateRole\",\"iam:DeleteRole\",\"iam:AttachRolePolicy\",\"iam:DetachRolePolicy\",\"iam:AddRoleToInstanceProfile\",\"iam:RemoveRoleFromInstanceProfile\",\"iam:CreateServiceLinkedRole\",\"iam:DeleteServiceLinkedRole\",\"ec2:CreateSecurityGroup\",\"ec2:RunInstances\",\"ec2:TerminateInstances\",\"ec2:StartInstances\",\"ec2:StopInstances\",\"ec2:CreateTags\",\"ec2:CreateKeyPair\",\"ec2:DeleteKeyPair\",\"ec2:RevokeSecurityGroupIngress\",\"ec2:RevokeSecurityGroupEgress\",\"ec2:AuthorizeSecurityGroupEgress\",\"ec2:AuthorizeSecurityGroupIngress\",\"ec2:DeleteSecurityGroup\",\"autoscaling:UpdateAutoScalingGroup\",\"autoscaling:DeleteAutoScalingGroup\",\"autoscaling:SuspendProcesses\",\"autoscaling:ResumeProcesses\",\"autoscaling:TerminateInstanceInAutoScalingGroup\"],\"Resource\":\"*\"},{\"Sid\":\"TagOnLaunching\",\"Effect\":\"Allow\",\"Action\":\"ec2:CreateTags\",\"Resource\":\"arn:aws:ec2:*:${ACCOUNT_NUMBER}:instance/*\",\"Condition\":{\"StringEquals\":{\"ec2:CreateAction\":\"RunInstances\"}}},{\"Sid\":\"TagSecurityGroups\",\"Effect\":\"Allow\",\"Action\":\"ec2:CreateTags\",\"Resource\":\"arn:aws:ec2:*:${ACCOUNT_NUMBER}:security-group/*\",\"Condition\":{\"StringEquals\":{\"ec2:CreateAction\":\"CreateSecurityGroup\"}}},{\"Sid\":\"RunInstancesPermissions\",\"Effect\":\"Allow\",\"Action\":\"ec2:RunInstances\",\"Resource\":[\"arn:aws:ec2:*:${ACCOUNT_NUMBER}:network-interface/*\",\"arn:aws:ec2:*:${ACCOUNT_NUMBER}:security-group/*\",\"arn:aws:ec2:*:${ACCOUNT_NUMBER}:volume/*\",\"arn:aws:ec2:*:${ACCOUNT_NUMBER}:key-pair/*\",\"arn:aws:ec2:*::image/*\"]},{\"Sid\":\"LambdaPermissions\",\"Effect\":\"Allow\",\"Action\":[\"lambda:CreateFunction\",\"lambda:UpdateFunctionCode\",\"lambda:AddPermission\",\"lambda:DeleteFunction\",\"events:PutRule\",\"events:PutTargets\",\"events:DeleteRule\",\"events:RemoveTargets\"],\"Resource\":\"*\"}]}"

if aws iam get-user --user-name $USER_NAME >>/dev/null 2>&1; then
  echo "User already exists: '$USER_NAME'"
  USER_ARN=$(aws iam get-user --user-name $USER_NAME --output text --query 'User.Arn')
else
  echo "Creating new user: '$USER_NAME'"
  USER_ARN=$(aws iam create-user --user-name $USER_NAME --output text --query 'User.Arn')
fi

echo "Attaching policies"
POLICY_ARN="arn:aws:iam::${ACCOUNT_NUMBER}:policy/${POLICY_NAME}"
if aws iam get-policy --policy-arn $POLICY_ARN >>/dev/null 2>&1; then

  VERSIONS=$(aws iam list-policy-versions --policy-arn $POLICY_ARN --query 'length(Versions[*])')
  if [ "$VERSIONS" -gt "4" ]; then
    LAST_VERSION_ID=$(aws iam list-policy-versions --policy-arn $POLICY_ARN --output text --query 'Versions[-1].VersionId')
    aws iam delete-policy-version --policy-arn $POLICY_ARN --version-id $LAST_VERSION_ID
  fi

  aws iam create-policy-version --policy-arn $POLICY_ARN --policy-document $POLICY_JSON --set-as-default >>/dev/null 2>&1
else
  POLICY_ARN=$(aws iam create-policy --policy-name $POLICY_NAME --policy-document $POLICY_JSON --description "Policy to manage kops cluster used by CAST console" --output text --query 'Policy.Arn')
fi

policies=(arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess arn:aws:iam::aws:policy/AmazonEventBridgeReadOnlyAccess arn:aws:iam::aws:policy/IAMReadOnlyAccess arn:aws:iam::aws:policy/AWSLambda_ReadOnlyAccess arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess $POLICY_ARN)
for i in "${policies[@]}"; do
  aws iam attach-user-policy --user-name $USER_NAME --policy-arn $i
done

echo "Creating access keys"
aws iam create-access-key --user-name $USER_NAME --output table --query 'AccessKey.{AccessKeyId:AccessKeyId,SecretAccessKey:SecretAccessKey}'
