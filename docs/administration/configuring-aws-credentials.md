# Configure AWS credentials

!!! note "TODO: pending documentation"
    Merge https://help.cast.ai/en/articles/4323142-adding-the-aws-access-key


After completing the following instructions, you’ll retrieve Access key ID and Secret access key. These credentials are required by CAST AI for creating a cluster with AWS resources.

Open https://console.aws.amazon.com/.

![](2020-10-28-17-11-44.png)

Go to IAM service.

![](2020-10-28-17-11-59.png)

In the Users section, click on Add user:

![](2020-10-28-17-12-21.png)

Enter the User name, select Programmatic access type, and click next (permissions):

![](2020-10-28-17-12-38.png)

Click Create group, enter the Group name, and select the following permission policies:

* AmazonVPCFullAccess
* AmazonEC2FullAccess
* IAMFullAccess

Click the Create group button again.

![](2020-10-28-17-13-24.png)

Click next (tags) → next (review) → create user.

You will end up on a screen where you can retrieve credentials in AWS GUI or download credentials containing .csv file.


![](2020-10-28-17-13-41.png)