# Azure

## Method 1: Create using `az` cli utility

Prerequisites

- (recommended) Visit <a href="https://portal.azure.com/" target="_blank">Azure Portal</a> and open Cloud Shell at the top right side of menu bar.
- (alternative) You can also use your local <em>az</em> cli installation.
</ul>

### Generate service principal

Run the script displayed below. It will create a new service principal with required roles, enable access to CAST Image
Gallery and print your credentials json.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/castai/docs/main/docs/getting-started/credentials/configuring-azure-credentials/script.sh)"
```

You'll see the following output:

```bash
user@Azure:~$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/castai/docs/main/docs/getting-started/credentials/configuring-azure-credentials/script.sh)"
== Setup
Available subscriptions:
ID                                    NAME        IS_DEFAULT
--                                    ----        ----------
XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX  Free Trial  true

Enter subscription id: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
Press enter to continue..

== Importing CAST.AI image gallery
. Using existing service principal
== Registering app
. Creating app registration
. Using existing service principal
== Assigning roles to the app
. Assigning Contributor role to CAST.AI app
. Assigning Contributor role to CAST.AI shared images app
--------------------------------------------------------------------------------
Save and use the following json to onboard credentials into CAST.AI
{
  "subscriptionId":"XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
  "tenantId":"YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY",
  "clientId":"ZZZZZZZZ-ZZZZ-ZZZZ-ZZZZ-ZZZZZZZZZZZZ",
  "clientSecret":"FX~JXqv~~~uiewDHJKDH9333d~ZZdf"
}
```

Copy the displayed JSON and use it in the *create azure cloud credentials* screen.

## Method 2: Create it manually using the Azure portal

To get started, you need to create an Active Directory (AD) service principal in your Azure account and assign the required permissions.

1. Create App registration
   - Open https://portal.azure.com
   - Go to App registrations, and click on New registration. Enter display name and click Register.
   - Paste in the **Directory (tenant) ID** to the form on the left side.
   - Paste in the **Application (client)** ID to the form on the left side.
   - Select Certificates & secrets in the left sidebar menu.
   - Create a new client secret without expiration.
   - Paste in the new client secret value to the form on the left side, to the **Client Secret** field.
2. Give access to the CAST AI application by requesting a sign-in using a browser
   - Accept CAST AI application.
   - After Sign-in you should see **Permissions requested** window. Click Accept which will allow you to add the CAST AI application role.
3. Assign the roles
   - Open Subscriptions page and go to your subscription.
   - Paste in the **Subscription ID** to the form on the left side.
   - Select the Access Control (IAM) in the left sidebar menu.
   - Add the role assignment with Role: Contributor, and in the Select search field type your Client Secret (created during the first step).
   - Add another role assignment with Role: Contributor, and in the Select input field search for **CAST AI Shared Images** then click save (if the role is not visible please check previous step and try again).

[Documentation on Azure Cloud EKS IAM Policies, Roles, and Permissions.](https://docs.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals)
