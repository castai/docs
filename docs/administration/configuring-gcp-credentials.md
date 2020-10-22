# Configure Google Cloud credentials

!!! note "TODO: pending documentation"
    Finish merging content from  https://help.cast.ai/en/articles/4365909-adding-the-gcp-access-keys  , add images etc




By following these instructions, you’ll retrieve the Service account JSON credentials. These credentials are required by CAST AI for creating a cluster with GCP resources.

### Project prerequisites

Note that the project where your Service Account is created needs to have the following APIs enabled:

    Compute API
    Resource Manager API

Please follow the GCP guide on how to enable APIs.

### Create service account

1. Open https://console.cloud.google.com/ and select your project (or create a new one) in the top bar.

2. Go to the Navigation bar, select *IAM & Admin*, and then *Service accounts*:

3. Click Create service account

Enter the preferred Service account name and description. Click Create

Add the following roles to the created account:

    roles/compute.admin
    roles/iam.serviceAccountAdmin

Click Continue.

In the last step of the service account creation, click Done without entering any data.

### Create key

The created account will appear in the Service Accounts list. Click on it to access additional options.

In the Keys section, click on Add Key → Create new key.

Select the JSON option and click Create.

You’ll get a file download prompt. The downloaded file will include the Service Account JSON credentials.

