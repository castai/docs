#!/bin/bash
set -e

export AWS_PAGER=""

if [ -z $CLUSTER_NAME ]; then
    echo "CLUSTER_NAME environment variable is not defined"
    exit 1;
fi

if [ -z $REGION ]; then
    echo "REGION environment variable is not defined"
    exit 1;
fi

if ! [ -x "$(command -v eksctl)" ]; then
  echo "Error: eksctl is not installed"
  exit 1
fi

echo "Fetching cluster information"
eksctl get cluster --region $REGION $CLUSTER_NAME -C false -v 2

echo "Validating cluster access"
if ! eksctl get iamidentitymapping --cluster $CLUSTER_NAME --region $REGION -v 0 >> /dev/null 2>&1; then
    echo "Error: getting auth ConfigMap: Unauthorized"
    exit 1
fi

USER_NAME=cast-eks-${CLUSTER_NAME}
EKS_POLICY_JSON="{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"CastEKSFullAccess\",\"Effect\":\"Allow\",\"Action\":\"eks:*\",\"Resource\":\"*\"}]}"

if aws iam get-user --user-name $USER_NAME >> /dev/null 2>&1; then
    echo "User already exists: '$USER_NAME'"
    USER_ARN=$(aws iam get-user --user-name $USER_NAME --output text --query 'User.Arn')
  else
    echo "Creating new user: '$USER_NAME'"
    USER_ARN=$(aws iam create-user --user-name $USER_NAME --output text --query 'User.Arn')
fi

echo "Attaching policies"
policies=( arn:aws:iam::aws:policy/AmazonEC2FullAccess arn:aws:iam::aws:policy/IAMFullAccess )
for i in "${policies[@]}"
do
  aws iam attach-user-policy --user-name $USER_NAME --policy-arn $i
done

aws iam put-user-policy --user-name cast-eks-testuzas --policy-name CastEKSFullAccess --policy-document $EKS_POLICY_JSON

echo "Adding user to cluster '$CLUSTER_NAME'"
if ! eksctl get iamidentitymapping --cluster $CLUSTER_NAME --region $REGION --arn $USER_ARN -v 0 >> /dev/null 2>&1; then
    eksctl create iamidentitymapping --cluster $CLUSTER_NAME --region $REGION --arn ${USER_ARN} --group system:masters --username $USER_NAME -C false -v 2
fi

echo "Creating access keys"
aws iam create-access-key --user-name $USER_NAME --output table --query 'AccessKey.{AccessKeyId:AccessKeyId,SecretAccessKey:SecretAccessKey}'
