# Configure AWS credentials

After completing the following instructions, you’ll retrieve Access key ID and Secret access key. These credentials are by CAST AI for creating a cluster with AWS resources.

Open https://console.aws.amazon.com/.

![](aws1.png)

Go to IAM service.

![](aws2.png)

In the Users section, click on Add user:

![](aws3.png)

Enter the User name, select Programmatic access type, and click next (permissions):

![](aws4.png)

Click Create group, enter the Group name, and select the following permission policies:

* AmazonVPCFullAccess
* AmazonEC2FullAccess
* IAMFullAccess

Click the Create group button again.

![](aws5.png)

Click next (tags) → next (review) → create user.

You will end up on a screen where you can retrieve credentials in AWS GUI or download credentials containing .csv file.


![](aws6.png)