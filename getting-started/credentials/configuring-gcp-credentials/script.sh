PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT_ID=castai-credentials-$(date +%s)
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "Setting up GCP cloud credentials"
echo "PROJECT_ID=$PROJECT_ID"
echo "SERVICE_ACCOUNT_ID=$SERVICE_ACCOUNT_ID"
echo "SERVICE_ACCOUNT_EMAIL=$SERVICE_ACCOUNT_EMAIL"

echo "Enabling required google cloud apis"
gcloud services enable --no-user-output-enabled \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com \
  compute.googleapis.com \
  cloudbilling.googleapis.com

echo "Creating service account"
gcloud iam service-accounts create "$SERVICE_ACCOUNT_ID" --display-name "Service account used for CAST.AI clusters" --no-user-output-enabled

echo "Generating service account key"
gcloud iam service-accounts keys create "${SERVICE_ACCOUNT_ID}.json" --iam-account "$SERVICE_ACCOUNT_EMAIL" --no-user-output-enabled

echo "Assigning required roles to $SERVICE_ACCOUNT_EMAIL service account"
for ROLE in roles/compute.admin \
  roles/iam.serviceAccountUser \
  roles/iam.serviceAccountAdmin \
  roles/iam.roleAdmin \
  roles/iam.serviceAccountKeyAdmin \
  roles/resourcemanager.projectIamAdmin; do
  echo "- Assigning $ROLE"
  gcloud projects add-iam-policy-binding "$PROJECT_ID" --role="$ROLE" --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" --condition=None --no-user-output-enabled
done

echo "Activating $SERVICE_ACCOUNT_EMAIL service account"
gcloud auth activate-service-account --key-file="${SERVICE_ACCOUNT_ID}.json" --no-user-output-enabled

echo "Service account key json:"

cat "${SERVICE_ACCOUNT_ID}.json"
