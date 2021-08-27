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

# Tag old roles so we can delete those in the future.
for rolename in $(aws iam list-roles --query 'Roles[?ends_with(RoleName,`-lambda-role`)][].[RoleName]' --output text); do
  aws iam tag-role --role-name $rolename --tags Key=cast:managed-by,Value=cast.ai
done

USER_NAME=cast-kops-${CLUSTER_NAME}
OLD_POLICY_NAME='CastKopsPolicy'
POLICY_NAME='CastKopsPolicyV2'
LAMBDA_ROLE_NAME='CastLambdaRoleForSpot'
ACCOUNT_NUMBER=$(aws sts get-caller-identity --output text --query 'Account')

LAMBDA_ASSUME_ROLE_JSON="{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":[\"states.amazonaws.com\",\"events.amazonaws.com\",\"lambda.amazonaws.com\",\"apigateway.amazonaws.com\"]},\"Action\":\"sts:AssumeRole\"}]}"
POLICY_JSON="{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"PassRoleEC2\",\"Action\":\"iam:PassRole\",\"Effect\":\"Allow\",\"Resource\":\"arn:aws:iam::*:role/*\",\"Condition\":{\"StringEquals\":{\"iam:PassedToService\":\"ec2.amazonaws.com\"}}},{\"Sid\":\"PassRoleLambda\",\"Action\":\"iam:PassRole\",\"Effect\":\"Allow\",\"Resource\":\"arn:aws:iam::*:role/*\",\"Condition\":{\"StringEquals\":{\"iam:PassedToService\":\"lambda.amazonaws.com\"}}},{\"Sid\":\"NonResourcePermissions\",\"Effect\":\"Allow\",\"Action\":[\"iam:DetachRolePolicy\",\"iam:CreateServiceLinkedRole\",\"iam:DeleteServiceLinkedRole\",\"ec2:CreateTags\",\"ec2:CreateKeyPair\",\"ec2:DeleteKeyPair\"],\"Resource\":\"*\"},{\"Sid\":\"TagRestrictedIAMPermissions\",\"Effect\":\"Allow\",\"Action\":\"iam:DeleteRole\",\"Resource\":\"*\",\"Condition\":{\"StringEquals\":{\"aws:ResourceTag/cast:managed-by\":\"cast.ai\"}}},{\"Sid\":\"TagOnLaunching\",\"Effect\":\"Allow\",\"Action\":\"ec2:CreateTags\",\"Resource\":\"arn:aws:ec2:*:${ACCOUNT_NUMBER}:instance/*\",\"Condition\":{\"StringEquals\":{\"ec2:CreateAction\":\"RunInstances\"}}},{\"Sid\":\"RunInstancesPermissions\",\"Effect\":\"Allow\",\"Action\":\"ec2:RunInstances\",\"Resource\":[\"arn:aws:ec2:*:${ACCOUNT_NUMBER}:network-interface/*\",\"arn:aws:ec2:*:${ACCOUNT_NUMBER}:security-group/*\",\"arn:aws:ec2:*:${ACCOUNT_NUMBER}:volume/*\",\"arn:aws:ec2:*:${ACCOUNT_NUMBER}:key-pair/*\",\"arn:aws:ec2:*:${ACCOUNT_NUMBER}:subnet/*\",\"arn:aws:ec2:*::image/*\"]},{\"Sid\":\"LambdaPermissions\",\"Effect\":\"Allow\",\"Action\":[\"lambda:CreateFunction\",\"lambda:UpdateFunctionCode\",\"lambda:AddPermission\",\"lambda:DeleteFunction\",\"events:PutRule\",\"events:PutTargets\",\"events:DeleteRule\",\"events:RemoveTargets\"],\"Resource\":\"*\"}]}"
INLINE_POLICY_JSON="{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"RunInstancesTagRestriction\",\"Effect\":\"Allow\",\"Action\":\"ec2:RunInstances\",\"Resource\":\"arn:aws:ec2:*:${ACCOUNT_NUMBER}:instance/*\",\"Condition\":{\"StringEquals\":{\"aws:RequestTag/KubernetesCluster\":\"${CLUSTER_NAME}\"}}},{\"Sid\":\"InstanceActionsTagRestriction\",\"Effect\":\"Allow\",\"Action\":[\"ec2:TerminateInstances\",\"ec2:StartInstances\",\"ec2:StopInstances\",\"ec2:ModifyInstanceAttribute\"],\"Resource\":\"arn:aws:ec2:*:${ACCOUNT_NUMBER}:instance/*\",\"Condition\":{\"StringEquals\":{\"ec2:ResourceTag/KubernetesCluster\":\"${CLUSTER_NAME}\"}}},{\"Sid\":\"AutoscalingActionsTagRestriction\",\"Effect\":\"Allow\",\"Action\":[\"autoscaling:UpdateAutoScalingGroup\",\"autoscaling:DeleteAutoScalingGroup\",\"autoscaling:SuspendProcesses\",\"autoscaling:ResumeProcesses\",\"autoscaling:TerminateInstanceInAutoScalingGroup\"],\"Resource\":\"arn:aws:autoscaling:*:${ACCOUNT_NUMBER}:autoScalingGroup:*:autoScalingGroupName/*\",\"Condition\":{\"StringEquals\":{\"autoscaling:ResourceTag/KubernetesCluster\":\"${CLUSTER_NAME}\"}}}]}"

if ! aws iam get-role --role-name $LAMBDA_ROLE_NAME >>/dev/null 2>&1; then
  echo "Creating IAM role for lambda: '$LAMBDA_ROLE_NAME'"
  aws iam create-role --role-name $LAMBDA_ROLE_NAME --assume-role-policy-document $LAMBDA_ASSUME_ROLE_JSON --tags Key=cast:managed-by,Value=cast.ai --description 'Lambda role used by CAST AI to handle Spot interrupts.' >>/dev/null 2>&1
fi

lambdaPolicies=(arn:aws:iam::aws:policy/CloudWatchLogsFullAccess arn:aws:iam::aws:policy/service-role/AWSLambdaRole)
for i in "${lambdaPolicies[@]}"; do
  aws iam attach-role-policy --role-name $LAMBDA_ROLE_NAME --policy-arn $i
done

if aws iam get-user --user-name $USER_NAME >>/dev/null 2>&1; then
  echo "User already exists: '$USER_NAME'"
  USER_ARN=$(aws iam get-user --user-name $USER_NAME --output text --query 'User.Arn')
else
  echo "Creating new user: '$USER_NAME'"
  USER_ARN=$(aws iam create-user --user-name $USER_NAME --output text --query 'User.Arn')
fi

echo "Attaching policies"
POLICY_ARN="arn:aws:iam::${ACCOUNT_NUMBER}:policy/${POLICY_NAME}"
OLD_POLICY_ARN="arn:aws:iam::${ACCOUNT_NUMBER}:policy/${OLD_POLICY_NAME}"
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

# Remove old policy from the user
if aws iam get-policy --policy-arn $OLD_POLICY_ARN >>/dev/null 2>&1; then
  aws iam detach-user-policy --user-name $USER_NAME --policy-arn $OLD_POLICY_ARN >>/dev/null 2>&1 || true
fi

policies=(arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess arn:aws:iam::aws:policy/AmazonEventBridgeReadOnlyAccess arn:aws:iam::aws:policy/IAMReadOnlyAccess arn:aws:iam::aws:policy/AWSLambda_ReadOnlyAccess arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess $POLICY_ARN)
for i in "${policies[@]}"; do
  aws iam attach-user-policy --user-name $USER_NAME --policy-arn $i
done

aws iam put-user-policy --user-name $USER_NAME --policy-name CastKopsRestrictedAccess --policy-document $INLINE_POLICY_JSON

echo "Creating access keys"
CREDENTIALS=$(aws iam create-access-key --user-name $USER_NAME --output json --query 'AccessKey.{accessKeyId:AccessKeyId,secretAccessKey:SecretAccessKey}')

echo $CREDENTIALS

if [ -z $CASTAI_API_TOKEN ] || [ -z $CASTAI_API_URL ]; then
  echo "Skipped sending credentials to CAST AI console (CASTAI_API_TOKEN and CASTAI_API_URL variables were not provided)"
else
  echo "Sending credentials to CAST AI console"
  curl -fsS -X POST -H "X-API-Key: $CASTAI_API_TOKEN" $CASTAI_API_URL -d "$(jq -n --arg CREDENTIALS "$CREDENTIALS" '{credentials:$CREDENTIALS}')"
fi
