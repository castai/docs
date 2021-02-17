# Configure Google Cloud credentials

By following these instructions, you’ll retrieve the service account JSON credentials. These credentials are required by
CAST AI for creating a cluster with GCP resources.

## Method 1: Create using `gcloud` utility

### Prerequisites

- (recommended) Visit the Google Cloud Platform <https://console.cloud.google.com/> and make sure you have selected the right project. Open Cloud Shell at the top right side of menu bar.
- (alternative) You can also use your local `gcloud` installation. Make sure that you have activated the right project (`gcloud projects list` and `gcloud config set project {{desired-project-id-here}}`)

### Generate service account

Run the script displayed below. It will create a new service account with the required permissions, enable the required APIs, and print your service account key JSON.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/castai/docs/main/docs/getting-started/configuring-gcp-credentials/script.sh)"
```

You'll see the following output:

```bash
user@cloudshell:~ (project)$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/castai/docs/main/docs/getting-started/configuring-gcp-credentials/script.sh)"

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

Copy the displayed JSON and use it in the _create gcp cloud credentials_ screen.

!!! Note
    Cloud Shell will copy a selected text automatically. Don't use `ctrl+c` as `"private_key"` part of the JSON might get corrupted due to word wrapping.

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

   ![](configuring-gcp-credentials/gcp1.png)

3. Go to the Navigation bar, select **IAM & Admin**, and then **Service accounts**:

   ![](configuring-gcp-credentials/gcp2.png)

4. Click **Create service account**:

   ![](configuring-gcp-credentials/gcp3.png)

   Enter the preferred **Service account name** and **description**. Click **Create**

   ![](configuring-gcp-credentials/gcp4.png)

   Add the following roles to the created account:

    ```
    roles/compute.admin
    roles/iam.serviceAccountUser
    roles/iam.serviceAccountAdmin
    roles/iam.roleAdministrator
    roles/iam.serviceAccountKey
    roles/iam.projectIAMAdmin
    ```

   Click **Save**.

   ![](configuring-gcp-credentials/gcp5.png)
   In the last step of the service account creation, click **Done** without entering any data.

   ![](configuring-gcp-credentials/gcp6.png)

### Create key

The created account will appear in the service accounts list. **Click on it** to access additional options.

![](configuring-gcp-credentials/gcp7.png)

In the **Keys** section, click on **Add Key → Create new key**.

![](configuring-gcp-credentials/gcp8.png)

Select the **JSON** option and click **Create**.

![](configuring-gcp-credentials/gcp9.png)

You’ll get a file download prompt. After the JSON file is downloaded, copy its contents to the input field or click on the **Read from file** button to import the file.
