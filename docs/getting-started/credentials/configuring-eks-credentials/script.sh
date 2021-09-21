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

echo "Fetching cluster information"
CLUSTER=$(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --output json)
CLUSTER_VPC=$(echo "$CLUSTER" | jq --raw-output '.cluster.resourcesVpcConfig.vpcId')

# loads and sets current kubectl context to the cluster
aws eks update-kubeconfig --name "$CLUSTER_NAME"

echo "Validating cluster access"
if ! kubectl describe cm/aws-auth --namespace=kube-system >>/dev/null 2>&1; then
  echo "Error: getting auth ConfigMap: Unauthorized"
  exit 1
fi

USER_NAME=cast-eks-${CLUSTER_NAME}
ACCOUNT_NUMBER=$(aws sts get-caller-identity --output text --query 'Account')
ARN="${REGION}:${ACCOUNT_NUMBER}"

INLINE_POLICY_JSON="{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"RunInstancesTagRestriction\",\"Effect\":\"Allow\",\"Action\":\"ec2:RunInstances\",\"Resource\":\"arn:aws:ec2:${ARN}:instance/*\",\"Condition\":{\"StringEquals\":{\"aws:RequestTag/kubernetes.io/cluster/${CLUSTER_NAME}\":\"owned\"}}},{\"Sid\":\"RunInstancesVpcRestriction\",\"Effect\":\"Allow\",\"Action\":\"ec2:RunInstances\",\"Resource\":\"arn:aws:ec2:${ARN}:subnet/*\",\"Condition\":{\"StringEquals\":{\"ec2:Vpc\":\"arn:aws:ec2:${ARN}:vpc/${CLUSTER_VPC}\"}}},{\"Sid\":\"InstanceActionsTagRestriction\",\"Effect\":\"Allow\",\"Action\":[\"ec2:TerminateInstances\",\"ec2:StartInstances\",\"ec2:StopInstances\",\"ec2:CreateTags\"],\"Resource\":\"arn:aws:ec2:${ARN}:instance/*\",\"Condition\":{\"StringEquals\":{\"ec2:ResourceTag/kubernetes.io/cluster/${CLUSTER_NAME}\":[\"owned\",\"shared\"]}}},{\"Sid\":\"VpcRestrictedActions\",\"Effect\":\"Allow\",\"Action\":[\"ec2:RevokeSecurityGroupIngress\",\"ec2:RevokeSecurityGroupEgress\",\"ec2:AuthorizeSecurityGroupEgress\",\"ec2:AuthorizeSecurityGroupIngress\",\"ec2:DeleteSecurityGroup\"],\"Resource\":\"*\",\"Condition\":{\"StringEquals\":{\"ec2:Vpc\":\"arn:aws:ec2:${ARN}:vpc/${CLUSTER_VPC}\"}}},{\"Sid\":\"AutoscalingActionsTagRestriction\",\"Effect\":\"Allow\",\"Action\":[\"autoscaling:UpdateAutoScalingGroup\",\"autoscaling:DeleteAutoScalingGroup\",\"autoscaling:SuspendProcesses\",\"autoscaling:ResumeProcesses\",\"autoscaling:TerminateInstanceInAutoScalingGroup\"],\"Resource\":\"arn:aws:autoscaling:${ARN}:autoScalingGroup:*:autoScalingGroupName/*\",\"Condition\":{\"StringEquals\":{\"autoscaling:ResourceTag/kubernetes.io/cluster/${CLUSTER_NAME}\":[\"owned\",\"shared\"]}}},{\"Sid\":\"EKS\",\"Effect\":\"Allow\",\"Action\":[\"eks:Describe*\",\"eks:List*\",\"eks:DeleteNodegroup\",\"eks:UpdateNodegroupConfig\"],\"Resource\":[\"arn:aws:eks:${ARN}:cluster/${CLUSTER_NAME}\",\"arn:aws:eks:${ARN}:nodegroup/${CLUSTER_NAME}/*/*\"]}]}"
POLICY_JSON="{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"PassRoleEC2\",\"Action\":\"iam:PassRole\",\"Effect\":\"Allow\",\"Resource\":\"arn:aws:iam::*:role/*\",\"Condition\":{\"StringEquals\":{\"iam:PassedToService\":\"ec2.amazonaws.com\"}}},{\"Sid\":\"PassRoleLambda\",\"Action\":\"iam:PassRole\",\"Effect\":\"Allow\",\"Resource\":\"arn:aws:iam::*:role/*\",\"Condition\":{\"StringEquals\":{\"iam:PassedToService\":\"lambda.amazonaws.com\"}}},{\"Sid\":\"NonResourcePermissions\",\"Effect\":\"Allow\",\"Action\":[\"iam:CreateInstanceProfile\",\"iam:DeleteInstanceProfile\",\"iam:CreateRole\",\"iam:DeleteRole\",\"iam:AttachRolePolicy\",\"iam:DetachRolePolicy\",\"iam:AddRoleToInstanceProfile\",\"iam:RemoveRoleFromInstanceProfile\",\"iam:CreateServiceLinkedRole\",\"iam:DeleteServiceLinkedRole\",\"ec2:CreateSecurityGroup\",\"ec2:CreateKeyPair\",\"ec2:DeleteKeyPair\",\"ec2:CreateTags\"],\"Resource\":\"*\"},{\"Sid\":\"TagOnLaunching\",\"Effect\":\"Allow\",\"Action\":\"ec2:CreateTags\",\"Resource\":\"arn:aws:ec2:*:${ACCOUNT_NUMBER}:instance/*\",\"Condition\":{\"StringEquals\":{\"ec2:CreateAction\":\"RunInstances\"}}},{\"Sid\":\"TagSecurityGroups\",\"Effect\":\"Allow\",\"Action\":\"ec2:CreateTags\",\"Resource\":\"arn:aws:ec2:*:${ACCOUNT_NUMBER}:security-group/*\",\"Condition\":{\"StringEquals\":{\"ec2:CreateAction\":\"CreateSecurityGroup\"}}},{\"Sid\":\"RunInstancesPermissions\",\"Effect\":\"Allow\",\"Action\":\"ec2:RunInstances\",\"Resource\":[\"arn:aws:ec2:*:${ACCOUNT_NUMBER}:network-interface/*\",\"arn:aws:ec2:*:${ACCOUNT_NUMBER}:security-group/*\",\"arn:aws:ec2:*:${ACCOUNT_NUMBER}:volume/*\",\"arn:aws:ec2:*:${ACCOUNT_NUMBER}:key-pair/*\",\"arn:aws:ec2:*::image/*\"]},{\"Sid\":\"CreateLambdaFunctionRestriction\",\"Effect\":\"Allow\",\"Action\":[\"lambda:CreateFunction\",\"lambda:UpdateFunctionCode\",\"lambda:AddPermission\",\"lambda:DeleteFunction\",\"events:PutRule\",\"events:PutTargets\",\"events:DeleteRule\",\"events:RemoveTargets\"],\"Resource\":\"*\"}]}"

if aws iam get-user --user-name $USER_NAME >>/dev/null 2>&1; then
  echo "User already exists: '$USER_NAME'"
  USER_ARN=$(aws iam get-user --user-name $USER_NAME --output text --query 'User.Arn')
else
  echo "Creating new user: '$USER_NAME'"
  USER_ARN=$(aws iam create-user --user-name $USER_NAME --output text --query 'User.Arn')
fi

echo "Attaching policies"
POLICY_ARN="arn:aws:iam::${ACCOUNT_NUMBER}:policy/CastEKSPolicy"
if aws iam get-policy --policy-arn $POLICY_ARN >>/dev/null 2>&1; then

  VERSIONS=$(aws iam list-policy-versions --policy-arn $POLICY_ARN --output text --query 'length(Versions[*])')
  if [ "$VERSIONS" -gt "4" ]; then
    LAST_VERSION_ID=$(aws iam list-policy-versions --policy-arn $POLICY_ARN --output text --query 'Versions[-1].VersionId')
    aws iam delete-policy-version --policy-arn $POLICY_ARN --version-id $LAST_VERSION_ID
  fi

  aws iam create-policy-version --policy-arn $POLICY_ARN --policy-document $POLICY_JSON --set-as-default >>/dev/null 2>&1
else
  POLICY_ARN=$(aws iam create-policy --policy-name CastEKSPolicy --policy-document $POLICY_JSON --description "Policy to manage EKS cluster used by CAST console" --output text --query 'Policy.Arn')
fi

policies=(arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess arn:aws:iam::aws:policy/AmazonEventBridgeReadOnlyAccess arn:aws:iam::aws:policy/IAMReadOnlyAccess arn:aws:iam::aws:policy/AWSLambda_ReadOnlyAccess $POLICY_ARN)
for i in "${policies[@]}"; do
  aws iam attach-user-policy --user-name $USER_NAME --policy-arn $i
done

aws iam put-user-policy --user-name $USER_NAME --policy-name CastEKSRestrictedAccess --policy-document $INLINE_POLICY_JSON

echo "Adding user to cluster '$CLUSTER_NAME'"
CAST_CLUSTER_USER="- groups:\n  - system:masters\n  userarn: ${USER_ARN}\n  username: ${USER_NAME}\n"
AWS_CLUSTER_USERS=$(kubectl get -n=kube-system cm/aws-auth -o json | jq '.data.mapUsers | select(. != null and . != "" and . != "[]" and . != "[]\n")')
if [ -z "$AWS_CLUSTER_USERS" ]; then
  kubectl patch -n=kube-system cm/aws-auth --patch "{\"data\":{\"mapUsers\": \"${CAST_CLUSTER_USER}\"}}"
elif [[ "$AWS_CLUSTER_USERS" == *"$CAST_CLUSTER_USER"* ]]; then
  echo "cast user already exists in configmap/aws-auth"
else
  kubectl patch -n=kube-system cm/aws-auth --patch "{\"data\":{\"mapUsers\": \"${AWS_CLUSTER_USERS}${CAST_CLUSTER_USER}\"}}"
fi

echo "Creating access keys"
CREDENTIALS=$(aws iam create-access-key --user-name $USER_NAME --output json --query 'AccessKey.{accessKeyId:AccessKeyId,secretAccessKey:SecretAccessKey}')

echo $CREDENTIALS

if [ -z $CASTAI_API_TOKEN ] || [ -z $CASTAI_API_URL ]; then
  echo "Skipped sending credentials to CAST AI console (CASTAI_API_TOKEN and CASTAI_API_URL variables were not provided)"
else
  echo "Sending credentials to CAST AI console"
  curl -fsS -X POST -H "X-API-Key: $CASTAI_API_TOKEN" $CASTAI_API_URL -d "$(jq -c -n --arg CREDENTIALS "$CREDENTIALS" '{credentials:$CREDENTIALS}')"
fi
