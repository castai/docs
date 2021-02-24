PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT_ID=castai-credentials-$(date +%s)
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com"

# enable google cloud apis
gcloud services enable \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com \
  compute.googleapis.com

# create service account
gcloud iam service-accounts create "$SERVICE_ACCOUNT_ID" --display-name "Service account used for CAST.AI clusters"

# generate service account key
gcloud iam service-accounts keys create "${SERVICE_ACCOUNT_ID}.json" --iam-account "$SERVICE_ACCOUNT_EMAIL"

# assign required roles to the service account
for ROLE in roles/compute.admin \
  roles/iam.serviceAccountUser \
  roles/iam.serviceAccountAdmin \
  roles/iam.roleAdmin \
  roles/iam.serviceAccountKeyAdmin \
  roles/resourcemanager.projectIamAdmin; do
  gcloud projects add-iam-policy-binding "$PROJECT_ID" --role="$ROLE" --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" --no-user-output-enabled
done

# activate the service account
gcloud auth activate-service-account --key-file="${SERVICE_ACCOUNT_ID}.json"

# print service account key
cat "${SERVICE_ACCOUNT_ID}.json"
