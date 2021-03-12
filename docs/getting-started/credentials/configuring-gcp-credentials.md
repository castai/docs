# GCP

By following these instructions, you’ll retrieve the service account JSON credentials. These credentials are required by
CAST AI for creating a cluster with GCP resources.

## Method 1: Create using `gcloud` utility

### Prerequisites

- (recommended) Visit the Google Cloud Platform <https://console.cloud.google.com/> and make sure you have selected the right project. Project needs to be precreated with billing account linked (can be free $300 trial). Open Cloud Shell at the top right side of menu bar.
- (alternative) You can also use your local `gcloud` installation. Make sure that you have activated the right project (`gcloud projects list` and `gcloud config set project {{desired-project-id-here}}`)

### Generate service account

Run the script displayed below. It will create a new service account with the required permissions, enable the required APIs, and print your service account key JSON.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/castai/docs/main/docs/getting-started/credentials/configuring-gcp-credentials/script.sh)"
```

You'll see the following output:

```bash
user@cloudshell:~ (project)$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/castai/docs/main/docs/getting-started/credentials/configuring-gcp-credentials/script.sh)"

Your active configuration is: [cloudshell-25962]
Operation "operations/acf.p2-294512688956-58cd0d54-dde2-4db3-8114-582e01768453" finished successfully.
Created service account [castai-credentials-1613140179].
created key [89d0debfef9d2e83c967b65615569a24fd8cdad4] of type [json] as [castai-credentials-1613140179.json] for [castai-credentials-1613140179@project.iam.gserviceaccount.com]
Activated service account credentials for: [castai-credentials-1613140179@project.iam.gserviceaccount.com]
{
  "type": "service_account",
  "project_id": "project",
  "private_key_id": "xxxxxxxxxxxxxxxxxxxxxx",
  "private_key": "-----BEGIN PRIVATE KEY-----\nxxxxxxxxxxxxxxxxxxxxxx\n-----END PRIVATE KEY-----\n",
  "client_email": "castai-credentials-1613140179@project.iam.gserviceaccount.com",
  "client_id": "xxxxxxxxxxxxxxxxxxxxxx",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/castai-credentials-1613140179%40project.iam.gserviceaccount.com"
}
```

1. Copy the displayed JSON
2. Open [cloud credentials](https://console.cast.ai/cloud-credentials) in CAST AI console
3. Select Google Cloud Platform
4. Paste it in the Service Account JSON field.

!!! Warning ""
    Cloud Shell will copy a selected text automatically. Don't use `ctrl+c` as `"private_key"` part of the JSON might get corrupted due to word wrapping.

!!! tip ""
    Next step: [create cluster](../../getting-started/create-cluster.md)

## Method 2: Create it manually using the Google Cloud Console

### Project prerequisites

**Note** that the project where you created your service account needs to have the following APIs enabled:

```
IAM API
Compute API
Resource Manager API
```

Please follow the [GCP guide](https://cloud.google.com/apis/docs/getting-started#enabling_apis) to learn more about how to enable APIs.

### Create service account

1. Open <https://console.cloud.google.com/>

2. Select your project (or create a new one) in the top bar.

3. Go to the Navigation bar, select **IAM & Admin**, and then **Service accounts**:

4. Click **Create service account**:

     - Enter the preferred **Service account name** and **description**. Click **Create**

     - Add the following roles to the created account:

          ```
          roles/compute.admin
          roles/iam.serviceAccountUser
          roles/iam.serviceAccountAdmin
          roles/iam.roleAdministrator
          roles/iam.serviceAccountKey
          roles/iam.projectIAMAdmin
          ```

     - Click **Save**.

     - In the last step of the service account creation, click **Done** without entering any data.


### Create key

The created account will appear in the service accounts list. **Click on it** to access additional options.

  - In the **Keys** section, click on **Add Key → Create new key**.

  - Select the **JSON** option and click **Create**.

  - You will get a file download prompt. After the JSON file is downloaded open [cloud credentials](https://console.cast.ai/cloud-credentials) in CAST AI console and select Google Cloud platform

  - Copy file contents to the input field or click on the **Read from file** button to import the file.

!!! tip ""
    Next step: [create cluster](../../getting-started/create-cluster.md)
