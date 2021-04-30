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

if ! [ -x "$(command -v eksctl)" ]; then
  echo "Error: eksctl is not installed"
  exit 1
fi

echo "Fetching cluster information"
eksctl get cluster --region $REGION $CLUSTER_NAME -C false -v 2

echo "Validating cluster access"
if ! eksctl get iamidentitymapping --cluster $CLUSTER_NAME --region $REGION -v 0 >>/dev/null 2>&1; then
  echo "Error: getting auth ConfigMap: Unauthorized"
  exit 1
fi

USER_NAME=cast-eks-${CLUSTER_NAME}
VPC=$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --output text --query 'cluster.resourcesVpcConfig.vpcId')
ACCOUNT_NUMBER=$(aws sts get-caller-identity --output text --query 'Account')
ARN="${REGION}:${ACCOUNT_NUMBER}"

INLINE_POLICY_JSON="{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"RunInstancesTagRestriction\",\"Effect\":\"Allow\",\"Action\":\"ec2:RunInstances\",\"Resource\":\"arn:aws:ec2:${ARN}:instance/*\",\"Condition\":{\"StringEquals\":{\"aws:RequestTag/kubernetes.io/cluster/${CLUSTER_NAME}\":\"owned\"}}},{\"Sid\":\"CreateLambdaFunctionRestriction\",\"Effect\":\"Allow\",\"Action\":[\"lambda:CreateFunction\",\"lambda:UpdateFunctionCode\",\"lambda:AddPermission\",\"events:PutRule\",\"events:PutTargets\"],\"Resource\":\"*\"},{\"Sid\":\"RunInstancesVpcRestriction\",\"Effect\":\"Allow\",\"Action\":\"ec2:RunInstances\",\"Resource\":\"arn:aws:ec2:${ARN}:subnet/*\",\"Condition\":{\"StringEquals\":{\"ec2:Vpc\":\"arn:aws:ec2:${ARN}:vpc/${VPC}\"}}},{\"Sid\":\"InstanceActionsTagRestriction\",\"Effect\":\"Allow\",\"Action\":[\"ec2:TerminateInstances\",\"ec2:StartInstances\",\"ec2:StopInstances\"],\"Resource\":\"arn:aws:ec2:${ARN}:instance/*\",\"Condition\":{\"StringEquals\":{\"ec2:ResourceTag/kubernetes.io/cluster/${CLUSTER_NAME}\":\"owned\"}}},{\"Sid\":\"AutoscalingActionsTagRestriction\",\"Effect\":\"Allow\",\"Action\":[\"autoscaling:UpdateAutoScalingGroup\",\"autoscaling:DeleteAutoScalingGroup\",\"autoscaling:TerminateInstanceInAutoScalingGroup\"],\"Resource\":\"arn:aws:autoscaling:${ARN}:autoScalingGroup:*:autoScalingGroupName/*\",\"Condition\":{\"StringEquals\":{\"autoscaling:ResourceTag/kubernetes.io/cluster/${CLUSTER_NAME}\":\"owned\"}}},{\"Sid\":\"EKS\",\"Effect\":\"Allow\",\"Action\":[\"eks:Describe*\",\"eks:List*\",\"eks:DeleteNodegroup\",\"eks:UpdateNodegroupConfig\"],\"Resource\":[\"arn:aws:eks:${ARN}:cluster/${CLUSTER_NAME}\",\"arn:aws:eks:${ARN}:nodegroup/${CLUSTER_NAME}/*/*\"]}]}"
POLICY_JSON="{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"PassRoleEC2\",\"Action\":\"iam:PassRole\",\"Effect\":\"Allow\",\"Resource\":\"arn:aws:iam::*:role/*\",\"Condition\":{\"StringEquals\":{\"iam:PassedToService\":\"ec2.amazonaws.com\"}}},{\"Sid\":\"PassRoleLambda\",\"Action\":\"iam:PassRole\",\"Effect\":\"Allow\",\"Resource\":\"arn:aws:iam::*:role/*\",\"Condition\":{\"StringEquals\":{\"iam:PassedToService\":\"lambda.amazonaws.com\"}}},{\"Sid\":\"IAMAccess\",\"Effect\":\"Allow\",\"Action\":[\"iam:CreateInstanceProfile\",\"iam:CreateRole\",\"iam:AttachRolePolicy\",\"iam:AddRoleToInstanceProfile\"],\"Resource\":\"*\"},{\"Sid\":\"TagOnLaunching\",\"Effect\":\"Allow\",\"Action\":\"ec2:CreateTags\",\"Resource\":\"arn:aws:ec2:${ARN}:instance/*\",\"Condition\":{\"StringEquals\":{\"ec2:CreateAction\":\"RunInstances\"}}},{\"Sid\":\"RunInstancesPermissions\",\"Effect\":\"Allow\",\"Action\":\"ec2:RunInstances\",\"Resource\":[\"arn:aws:ec2:${ARN}:network-interface/*\",\"arn:aws:ec2:${ARN}:security-group/*\",\"arn:aws:ec2:${ARN}:volume/*\",\"arn:aws:ec2:${ARN}:key-pair/*\",\"arn:aws:ec2:${REGION}::image/*\"]}]}"

if aws iam get-user --user-name $USER_NAME >>/dev/null 2>&1; then
  echo "User already exists: '$USER_NAME'"
  USER_ARN=$(aws iam get-user --user-name $USER_NAME --output text --query 'User.Arn')
else
  echo "Creating new user: '$USER_NAME'"
  USER_ARN=$(aws iam create-user --user-name $USER_NAME --output text --query 'User.Arn')
fi

echo "Attaching policies"
POLICY_ARN="arn:aws:iam::${ACCOUNT_NUMBER}:policy/CastEKSPolicy"
if ! aws iam get-policy --policy-arn $POLICY_ARN  >>/dev/null 2>&1; then
  POLICY_ARN=$(aws iam create-policy --policy-name CastEKSPolicy --policy-document $POLICY_JSON --description "Policy to manage EKS cluster used by CAST console" --output text --query 'Policy.Arn')
fi

policies=(arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess arn:aws:iam::aws:policy/IAMReadOnlyAccess arn:aws:iam::aws:policy/AWSLambda_ReadOnlyAccess $POLICY_ARN)
for i in "${policies[@]}"; do
  aws iam attach-user-policy --user-name $USER_NAME --policy-arn $i
done

aws iam put-user-policy --user-name $USER_NAME --policy-name CastEKSRestrictedAccess --policy-document $INLINE_POLICY_JSON

echo "Adding user to cluster '$CLUSTER_NAME'"
if ! eksctl get iamidentitymapping --cluster $CLUSTER_NAME --region $REGION --arn $USER_ARN -v 0 >>/dev/null 2>&1; then
  eksctl create iamidentitymapping --cluster $CLUSTER_NAME --region $REGION --arn ${USER_ARN} --group system:masters --username $USER_NAME -C false -v 2
fi

echo "Creating access keys"
aws iam create-access-key --user-name $USER_NAME --output table --query 'AccessKey.{AccessKeyId:AccessKeyId,SecretAccessKey:SecretAccessKey}'
