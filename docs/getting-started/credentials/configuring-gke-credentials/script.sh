#!/bin/bash
set -e

if [ -z $PROJECT_ID ]; then
  echo "PROJECT_ID environment variable is not defined"
  exit 1
fi

if [ -z $LOCATION ]; then
  echo "LOCATION environment variable is not defined"
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
if ! gcloud container clusters describe $CLUSTER_NAME --region=$LOCATION --project=$PROJECT_ID --no-user-output-enabled >>/dev/null 2>&1; then
  echo "Error: cluster $CLUSTER_NAME in $LOCATION does not exist"
  exit 1
fi

if out=$(gcloud container clusters describe $CLUSTER_NAME --region=$LOCATION --project=$PROJECT_ID --format="value(shieldedNodes.Enabled)") && [ ! -z $out ]; then
  echo "Error: shielded GKE nodes not supported (https://docs.cast.ai/guides/external-clusters/#shielded-gke-nodes)"
  exit 1
fi

echo 'Enabling required google cloud services'
gcloud services enable \
  serviceusage.googleapis.com \
  cloudresourcemanager.googleapis.com \
  iam.googleapis.com \
  container.googleapis.com \
  compute.googleapis.com \
  --no-user-output-enabled \
  --async \
  --project $PROJECT_ID

SERVICE_ACCOUNT_ID=castai-gke-$(echo -n $CLUSTER_NAME | shasum | cut -c 1-8)
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com"
CUSTOM_ROLE_ID=castai.gkeAccess
CUSTOM_ROLE_PERMISSIONS=(
  'container.clusters.get'
  'container.clusters.update'
  'container.certificateSigningRequests.approve'
  'compute.instances.get'
  'compute.instances.list'
  'compute.instances.create'
  'compute.instances.start'
  'compute.instances.stop'
  'compute.instances.delete'
  'compute.instances.setLabels'
  'compute.instances.setServiceAccount'
  'compute.instances.setMetadata'
  'compute.instances.setTags'
  'compute.instanceGroupManagers.get'
  'compute.instanceGroupManagers.update'
  'compute.instanceGroups.get'
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
  'compute.zones.list'
  'compute.zones.get'
  'serviceusage.services.list'
)

if gcloud iam service-accounts describe $SERVICE_ACCOUNT_EMAIL --project $PROJECT_ID >>/dev/null 2>&1; then
  echo "Service account already exists: '$SERVICE_ACCOUNT_EMAIL'"
else
  echo "Creating service account: '$SERVICE_ACCOUNT_EMAIL'"
  gcloud iam service-accounts create "$SERVICE_ACCOUNT_ID" --display-name "Service account to manage $CLUSTER_NAME GKE cluster via CAST" --no-user-output-enabled --project $PROJECT_ID
fi

if gcloud iam roles describe --project=$PROJECT_ID $CUSTOM_ROLE_ID >>/dev/null 2>&1; then
  echo "Updating existing role: '$CUSTOM_ROLE_ID'"
  gcloud iam roles update $CUSTOM_ROLE_ID \
    --title='Role to manage GKE cluster via CAST AI' \
    --description='Role to manage GKE cluster via CAST AI' \
    --permissions=$(
      IFS=,
      echo "${CUSTOM_ROLE_PERMISSIONS[*]}"
    ) \
    --project=$PROJECT_ID \
    --stage=ALPHA \
    --no-user-output-enabled \
    --quiet
else
  echo "Creating a new role: '$CUSTOM_ROLE_ID'"
  gcloud iam roles create $CUSTOM_ROLE_ID \
    --title='Role to manage GKE cluster via CAST AI' \
    --description='Role to manage GKE cluster via CAST AI' \
    --permissions=$(
      IFS=,
      echo "${CUSTOM_ROLE_PERMISSIONS[*]}"
    ) \
    --project=$PROJECT_ID \
    --stage=ALPHA \
    --no-user-output-enabled \
    --quiet
fi

echo "Assigning roles to the service account"
for ROLE in \
  projects/$PROJECT_ID/roles/$CUSTOM_ROLE_ID \
  roles/container.developer \
  roles/iam.serviceAccountUser; do
  echo "- Assigning $ROLE"
  gcloud projects add-iam-policy-binding "$PROJECT_ID" --role="$ROLE" --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" --condition=None --no-user-output-enabled --project $PROJECT_ID
done

echo "Generating service account key"
gcloud iam service-accounts keys create "${SERVICE_ACCOUNT_ID}.json" --iam-account "$SERVICE_ACCOUNT_EMAIL" --no-user-output-enabled --project $PROJECT_ID

CREDENTIALS=$(cat "${SERVICE_ACCOUNT_ID}.json")

echo "Service account key json:"
echo $CREDENTIALS

if [ -z $CASTAI_API_TOKEN ] || [ -z $CASTAI_API_URL ]; then
  echo "Skipped sending credentials to CAST AI console (CASTAI_API_TOKEN and CASTAI_API_URL variables were not provided)"
else
  echo "Sending credentials to CAST AI console"
  curl -X POST -H "X-API-Key: $CASTAI_API_TOKEN" $CASTAI_API_URL -d "$(jq -n --arg CREDENTIALS "$CREDENTIALS" '{credentials:$CREDENTIALS}')"
fi
