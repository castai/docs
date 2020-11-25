# Configure Azure credentials

The instructions we provide in this section will guide you in creating an external app registration. After completing
the instructions, you’ll get keys similar to the following that allow CAST AI to access your Azure Subscription
resources:

```
tenant id: 355069b9-fbb7-yyyy-xxxx-83d5a8709111
client id: 2d970aa5-4dde-yyyy-xxxx-36581dfff222
client secret: xvKds90f83&&#$$qwerty
subscription id: 697e39d3-4b01-yyyy-xxxx-75266e90c333
```

Open <https://portal.azure.com/> and go to the **App registrations** section:

![](configuring-azure-credentials/azure1.png)

Click on **New registration** and complete the registration by entering the **Name** and selecting **Multi-tenant**
access.

![](configuring-azure-credentials/azure2.png)

Once you complete the registration, you’ll end up on the App Overview page.

Save the Application (client) ID and Directory (tenant) ID from this page. They represent **Tenant ID** and
**Client ID** keys from the required outputs of these instructions.

Click on **Certificates & secrets** in the **Manage** tab and click **New client secret**.

![](configuring-azure-credentials/azure3.png)

![](configuring-azure-credentials/azure4.png)

Enter meaningful **descriptions** and select **secret expiry time**. Click **Add**.

![](configuring-azure-credentials/azure5.png)

Copy the secret **value** you have created. It will be used as **Client Secret** when you enter it into CAST AI console.

![](configuring-azure-credentials/azure6.png)

## Give access to the CAST AI application by requesting a sign-in using a browser

1 - Make sure to click the link on our console where you have pasted the keys.

![](configuring-azure-credentials/2020-11-23-16-28-43.png)

2 - After login, you should see the **Permissions requested** window. Click Accept which will allow adding CAST AI
application role.

![](configuring-azure-credentials/2020-11-23-16-31-46.png)

You should see it like this:

![](configuring-azure-credentials/2020-11-23-16-32-46.png)

## Assigning the roles

Go to **Subscriptions**
![](configuring-azure-credentials/azure8.png)
Select **subscription** to which you want to give CAST AI access

![](configuring-azure-credentials/azure9.png)

Take note of the **Subscription ID**. This is the last item required for your Azure app credentials.

We have one more step left here. Create a Role assignment between the previously created App registration and this
Subscription.

Go to **Access control (IAM)**.

![](configuring-azure-credentials/azure10.png)
Click on **Add → Add role assignment**

![](configuring-azure-credentials/azure11.png)

The following sidebar will appear

![](configuring-azure-credentials/azure12.png)

In the **Role** dropdown, select **Contributor**. In the **Select** field type your **Client Secret** (created app secret during the first step).

 Also you need **CAST AI Shared Images** as a selected member. Then click save (if the role is not visible please check previous step and try again).

![](2020-11-24-09-12-13.png)

This is it. After taking all of the steps above, you should have the required keys to create your first azure cluster!
