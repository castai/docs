#!/bin/bash
set -e

if [ -z $PROJECT_ID ]; then
  echo "PROJECT_ID environment variable is not defined"
  exit 1
fi

if [ -z $REGION ]; then
  echo "REGION environment variable is not defined"
  exit 1
fi

if [ -z $CLUSTER_NAME ]; then
  echo "CLUSTER_NAME environment variable is not defined"
  exit 1
fi

if ! [ -x "$(command -v gcloud)" ]; then
  echo "Error: gcloud is not installed"
  exit 1
fi

echo 'Fetching cluster information'
if ! gcloud container clusters describe $CLUSTER_NAME --region=$REGION --no-user-output-enabled >>/dev/null 2>&1; then
  echo "Error: cluster $CLUSTER_NAME in $REGION does not exist"
  exit 1
fi

PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT_ID=cast-gke-${CLUSTER_NAME}
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com"
CUSTOM_ROLE_ID=cast.gkeAccess
CUSTOM_ROLE_PERMISSIONS=(
  'container.clusters.get'
  'container.clusters.update'
  'compute.instances.get'
  'compute.instances.list'
  'compute.instances.create'
  'compute.instances.start'
  'compute.instances.stop'
  'compute.instances.delete'
  'compute.instances.setLabels'
  'compute.instances.setServiceAccount'
  'compute.instances.setMetadata'
  'compute.instanceGroupManagers.get'
  'compute.networks.use'
  'compute.networks.useExternalIp'
  'compute.subnetworks.get'
  'compute.subnetworks.use'
  'compute.subnetworks.useExternalIp'
  'compute.addresses.use'
  'compute.disks.use'
  'compute.disks.create'
  'compute.disks.setLabels'
  'compute.images.useReadOnly'
  'compute.instanceTemplates.get'
  'compute.instanceTemplates.list'
  'compute.instanceTemplates.create'
  'compute.instanceTemplates.delete'
  'compute.instances.setTags'
)

if gcloud iam service-accounts describe $SERVICE_ACCOUNT_EMAIL >>/dev/null 2>&1; then
  echo "Service account already exists: '$SERVICE_ACCOUNT_EMAIL'"
else
  echo "Creating service account: '$SERVICE_ACCOUNT_EMAIL'"
  gcloud iam service-accounts create "$SERVICE_ACCOUNT_ID" --display-name "Service account to manage GKE cluster via CAST" --no-user-output-enabled
fi

if gcloud iam roles describe --project=$PROJECT_ID $CUSTOM_ROLE_ID >>/dev/null 2>&1; then
  echo "Updating existing role: '$CUSTOM_ROLE_ID'"
  echo "y" | gcloud iam roles update $CUSTOM_ROLE_ID \
    --title='Role to manage GKE cluster via CAST' \
    --description='Role to manage GKE cluster via CAST' \
    --permissions=$(
      IFS=,
      echo "${CUSTOM_ROLE_PERMISSIONS[*]}"
    ) \
    --project=$PROJECT_ID \
    --stage=ALPHA
else
  echo "Creating a new role: '$CUSTOM_ROLE_ID'"
  gcloud iam roles create $CUSTOM_ROLE_ID \
    --title='Role to manage GKE cluster via CAST' \
    --description='Role to manage GKE cluster via CAST' \
    --permissions=$CUSTOM_ROLE_PERMISSIONS \
    --project=$PROJECT_ID \
    --stage=ALPHA
fi

echo "Assigning roles to the service account"
for ROLE in \
  projects/$PROJECT_ID/roles/$CUSTOM_ROLE_ID \
  roles/container.developer \
  roles/iam.serviceAccountUser; do
  echo "- Assigning $ROLE"
  gcloud projects add-iam-policy-binding "$PROJECT_ID" --role="$ROLE" --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" --condition=None --no-user-output-enabled
done

echo "Generating service account key"
gcloud iam service-accounts keys create "${SERVICE_ACCOUNT_ID}.json" --iam-account "$SERVICE_ACCOUNT_EMAIL" --no-user-output-enabled

echo "Service account key json:"
cat "${SERVICE_ACCOUNT_ID}.json"
