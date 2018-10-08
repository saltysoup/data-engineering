# Module 3 - Redshift

## Background
In this module, you will learn how to create a Redshift cluster, connect to it using a SQL client and load sample data to run some queries.

## Implementation Instructions

Each of the following sections provides an implementation overview and detailed, step-by-step instructions. The overview should provide enough context for you to complete the implementation if you're already familiar with the AWS Management Console or you want to explore the services yourself without following a walkthrough.

# Step 1: Set Up Prerequisites<a name="rs-gsg-prereq"></a>

### High-Level Instructions

Before you begin setting up an Amazon Redshift cluster, make sure that you complete the following prerequisites in this section: 

+ [Sign Up for AWS](#rs-gsg-prereq-signup)

+ [Install SQL Client Drivers and Tools](#rs-gsg-prereq-sql-client)

+ [Determine Firewall Rules](#rs-gsg-prereq-firewall-rules)


<details>
<summary><strong>Step-by-step instructions (expand for details)</strong></summary><p>


## Sign Up for AWS<a name="rs-gsg-prereq-signup"></a>

If you don’t already have an AWS account, you must sign up for one\. If you already have an account, you can skip this prerequisite and use your existing account\.

1. Open [https://aws\.amazon\.com/](https://aws.amazon.com/), and then choose **Create an AWS Account**\.
**Note**  
This might be unavailable in your browser if you previously signed into the AWS Management Console\. In that case, choose **Sign in to a different account**, and then choose **Create a new AWS account**\.

1. Follow the online instructions\.

    Part of the sign\-up procedure involves receiving a phone call and entering a PIN using the phone keypad\.

## Install SQL Client Drivers and Tools<a name="rs-gsg-prereq-sql-client"></a>

`Redshift has released a new feature for an AWS Console based [Query Editor](https://docs.aws.amazon.com/redshift/latest/mgmt/query-editor.html) interface on the 8th of October 2018`

You can use most SQL client tools with Amazon Redshift JDBC or ODBC drivers to connect to an Amazon Redshift cluster\. In this tutorial, we show you how to connect using SQL Workbench/J, a free, DBMS\-independent, cross\-platform SQL query tool\. If you plan to use SQL Workbench/J to complete this tutorial, follow the steps below to get set up with the Amazon Redshift JDBC driver and SQL Workbench/J\. For more complete instructions for installing SQL Workbench/J, go to [Setting Up the SQL Workbench/J Client](http://docs.aws.amazon.com/redshift/latest/mgmt/connecting-using-workbench.html) in the *Amazon Redshift Cluster Management Guide*\. If you use an Amazon EC2 instance as your client computer, you will need to install SQL Workbench/J and the required drivers on the instance\.

**Note**  
You must install any third\-party database tools that you want to use with your clusters; Amazon Redshift does not provide or install any third\-party tools or libraries\.

### To Install SQL Workbench/J on Your Client Computer<a name="rs-gsg-how-to-install-sql-client-drivers-and-tools"></a>

1. Review the [SQL Workbench/J software license](http://www.sql-workbench.net/manual/license.html#license-restrictions)\.

1. Go to the [SQL Workbench/J website](http://www.sql-workbench.net/) and download the appropriate package for your operating system\.

1. Go to the [Installing and starting SQL Workbench/J page](http://www.sql-workbench.net/manual/install.html) and install SQL Workbench/J\.
**Important**  
Note the Java runtime version prerequisites for SQL Workbench/J and ensure you are using that version, otherwise, this client application will not run\.

1. Go to [Configure a JDBC Connection](http://docs.aws.amazon.com/redshift/latest/mgmt/configure-jdbc-connection.html) and download an Amazon Redshift JDBC driver to enable SQL Workbench/J to connect to your cluster\.

For more information about using the Amazon Redshift JDBC or ODBC drivers, see [Configuring Connections in Amazon Redshift](http://docs.aws.amazon.com/redshift/latest/mgmt/configuring-connections.html)\.

## Determine Firewall Rules<a name="rs-gsg-prereq-firewall-rules"></a>

As part of this tutorial, you will specify a port when you launch your Amazon Redshift cluster\. You will also create an inbound ingress rule in a security group to allow access through the port to your cluster\.

If your client computer is behind a firewall, you need to know an open port that you can use so you can connect to the cluster from a SQL client tool and run queries\. If you do not know this, you should work with someone who understands your network firewall rules to determine an open port in your firewall\. Though Amazon Redshift uses port 5439 by default, the connection will not work if that port is not open in your firewall\. Because you cannot change the port number for your Amazon Redshift cluster after it is created, make sure that you specify an open port that will work in your environment during the launch process\.

</p></details>

# Step 2: Create an IAM Role for Redshift<a name="rs-gsg-create-an-iam-role"></a>

For any operation that accesses data on another AWS resource, such as using a COPY command to load data from Amazon S3, your cluster needs permission to access the resource and the data on the resource on your behalf\. You provide those permissions by using AWS Identity and Access Management, either through an IAM role that is attached to your cluster or by providing the AWS access key for an IAM user that has the necessary permissions\. 

To best protect your sensitive data and safeguard your AWS access credentials, we recommend creating an IAM role and attaching it to your cluster\. For more information about providing access permissions, see [Permissions to Access Other AWS Resources](http://docs.aws.amazon.com/redshift/latest/dg/copy-usage_notes-access-permissions.html)\.

### High-Level Instructions

Create a new IAM role that enables Amazon Redshift to load data from Amazon S3 buckets (read only). Attach the IAM role to your Redshift cluster.


<details>
<summary><strong>Step-by-step instructions (expand for details)</strong></summary><p>


1. Sign in to the AWS Management Console and open the IAM console at [https://console\.aws\.amazon\.com/iam/](https://console.aws.amazon.com/iam/)\.

1. In the left navigation pane, choose **Roles**\.

1. Choose **Create role**

1. In the **AWS Service** group, choose **Redshift\.** 

1. Under **Select your use case**, choose **Redshift \- Customizable** then choose **Next: Permissions**\.

1. On the **Attach permissions policies** page, choose **AmazonS3ReadOnlyAccess**, and then choose **Next: Review**\.

1. For **Role name**, type a name for your role\. For this tutorial, type `myRedshiftRole`\. 

1. Review the information, and then choose **Create Role**\.

1. Choose the role name for new role\.

1. Copy the **Role ARN** to your clipboard—this value is the Amazon Resource Name \(ARN\) for the role that you just created\. You will use that value when you use the COPY command to load data in Step 6.

1. Attach the new role to your cluster\. You can attach the role when you launch a new cluster or you can attach it to an existing cluster\. In the next step, you'll attach the role to a new cluster\.

</p></details>

# Step 3: Launch a Sample Amazon Redshift Cluster<a name="rs-gsg-launch-sample-cluster"></a>

**The cluster you'll launch will be live and incur the standard Amazon Redshift usage fees for the cluster until you delete it.** Please don't forget to clean up any resources after the Module.


### High-Level Instructions
Create a new `publicly accessible` Redshift cluster in a region of your choice. For the node configuration, choose a `dc2.large` and `single node` cluster type with `1 compute node`.


<details>
<summary><strong>Step-by-step instructions (expand for details)</strong></summary><p>

1. Sign in to the AWS Management Console and open the Amazon Redshift console at [https://console\.aws\.amazon\.com/redshift/](https://console.aws.amazon.com/redshift/)\.
**Important**  
If you use IAM user credentials, ensure that the user has the necessary permissions to perform the cluster operations\. For more information, go to [Controlling Access to IAM Users](http://docs.aws.amazon.com/redshift/latest/mgmt/iam-redshift-user-mgmt.html) in the *Amazon Redshift Cluster Management Guide*\.

1. In the main menu, select the region in which you want to create the cluster\. For the purposes of this tutorial, select **Sydney**.  

1. On the Amazon Redshift Dashboard, choose **Launch Cluster**\.

The Amazon Redshift Dashboard looks similar to the following:  
![Redshift Console](http://docs.aws.amazon.com/redshift/latest/gsg/images/rs-gsg-clusters-launch-cluster-10.png)

1. On the Cluster Details page, enter the following values and then choose **Continue**:

   + **Cluster Identifier**: type `<yourName>-cluster`

   + **Database Name**: leave this box blank\. Amazon Redshift will create a default database named `dev`\

   + **Database Port**: type the port number on which the database will accept connections\. You should have determined the port number in the prerequisite step of this tutorial\. You cannot change the port after launching the cluster, so make sure that you have an open port number in your firewall so that you can connect from SQL client tools to the database in the cluster\.

   + **Master User Name**: type `masteruser`\. You will use this username and password to connect to your database after the cluster is available\.

   + **Master User Password** and **Confirm Password**: type a password for the master user account\.  
![Cluster Config](http://docs.aws.amazon.com/redshift/latest/gsg/images/rs-gsg-clusters-launch-cluster-wizard-10.png)

1. On the Node Configuration page, select the following values and then choose **Continue**:

   + **Node Type**: **dc2\.large**

   + **Cluster Type**: **Single Node**  
![Node Configuration](http://docs.aws.amazon.com/redshift/latest/gsg/images/rs-gsg-clusters-launch-cluster-wizard-20.png)


1. Use the following values if you are launching your cluster in the EC2\-VPC platform:

   + **Cluster Parameter Group**: select the default parameter group\.

   + **Encrypt Database**: **None**\.

   + **Choose a VPC**: **Default VPC \(vpc\-xxxxxxxx\)**

   + **Cluster Subnet Group**: **default**

   + **Publicly Accessible**: **Yes**

   + **Choose a Public IP Address**: **No**

   + **Enhanced VPC Routing**: **No**

   + **Availability Zone**: **No Preference**

   + **VPC Security Groups**: **default \(sg\-xxxxxxxx\)**

   + **Create CloudWatch Alarm**: **No**

1. Associate an IAM role with the cluster

   For **AvailableRoles**, choose **myRedshiftRole** (configured in Step 2) and then choose **Continue**\.  
![Redshift IAM Role](http://docs.aws.amazon.com/redshift/latest/gsg/images/rs-gsg-clusters-launch-cluster-wizard-45.png)

1. On the Clusters page, choose the cluster that you just launched and review the **Cluster Status** information\. Make sure that the **Cluster Status** is **available** and the **Database Health** is **healthy** before you try to connect to the database later in this tutorial\.  
![Redshift Health Console](http://docs.aws.amazon.com/redshift/latest/gsg/images/rs-gsg-clusters-config-cluster-status.png)

</p></details>


# Step 4: Authorize Access to the Cluster<a name="rs-gsg-authorize-cluster-access"></a>

In the previous step, you launched your Amazon Redshift cluster\. Before you can connect to the cluster, you need to configure a security group to authorize access: 


### High-Level Instructions
Whitelist your IP address to provide network access in your Redshift cluster's security group.


<details>
<summary><strong>Step-by-step instructions (expand for details)</strong></summary><p>

1. In the Amazon Redshift console, in the navigation pane, choose **Clusters**\.

1. Choose `your cluster` to open it, and make sure you are on the **Configuration** tab\.

1. Under **Cluster Properties**, for **VPC Security Groups**, choose your security group\.  
![Security Group](http://docs.aws.amazon.com/redshift/latest/gsg/images/rs-gsg-clusters-config-vpc-security-group.png)

1. After your security group opens in the Amazon EC2 console, choose the **Inbound** tab\.  
![SG inbound](http://docs.aws.amazon.com/redshift/latest/gsg/images/rs-gsg-security-vpc-security-group-select.png)

1. Choose **Edit**, and enter the following, then choose **Save**: 

   + **Type**: **Custom TCP Rule**\.

   + **Protocol**: **TCP**\.

   + **Port Range**: type the same port number that you used when you launched the cluster\. The default port for Amazon Redshift is `5439`, but your port might be different\.

   + **Source**: select **My IP**
</p></details>

# Step 5: Connect to the Sample Cluster<a name="rs-gsg-connect-to-cluster"></a>

### High-Level Instructions

Connect to your Redshift cluster using your SQL client tool and run a simple query to test the connection.

<details>
<summary><strong>Step-by-step instructions (expand for details)</strong></summary><p>

+ [To Get Your Connection String](#rs-gsg-how-to-get-connection-string)

+ [To Connect from SQL Workbench/J to Your Cluster](#rs-gsg-how-to-connect-from-workbench)

### To Get Your Connection String<a name="rs-gsg-how-to-get-connection-string"></a>

1. In the Amazon Redshift console, in the navigation pane, choose **Clusters**\.

1. Choose `your-cluster` to open it, and make sure you are on the **Configuration** tab\.

1. On the **Configuration** tab, under **Cluster Database Properties**, copy the JDBC URL of the cluster\. 
**Note**  
The endpoint for your cluster is not available until the cluster is created and in the available state\.  
![JDBC URL](http://docs.aws.amazon.com/redshift/latest/gsg/images/rs-mgmt-clusters-cluster-database-properties-jdbc.png)

### To Connect from SQL Workbench/J to Your Cluster<a name="rs-gsg-how-to-connect-from-workbench"></a>

This step assumes you installed SQL Workbench/J in Step 1, otherwise use your application specific settings to connect to your cluster.

1. Open SQL Workbench/J\.

1. Choose **File**, and then choose **Connect window**\.

1. Choose **Create a new connection profile**\.

1. In the **New profile** text box, type a name for the profile\.

1. Choose **Manage Drivers**\. The **Manage Drivers** dialog opens\.

1. Choose the **Create a new entry** button\. In the **Name** text box, type a name for the driver\.  
![Driver](http://docs.aws.amazon.com/redshift/latest/gsg/images/jdbc-manage-drivers.png)

Choose the folder icon next to the **Library** box, navigate to the location of the driver, select it, and then choose **Open**\.  
![JDBC Driver](http://docs.aws.amazon.com/redshift/latest/gsg/images/redshift_jdbc_file.png)

If the **Please select one driver** dialog box displays, select **com\.amazon\.redshift\.jdbc4\.Driver** or **com\.amazon\.redshift\.jdbc41\.Driver** and choose **OK**\. SQL Workbench/J automatically completes the **Classname** box\. Leave the **Sample URL** box blank, and then choose **OK**\. 

1. In the **Driver** box, choose the driver you just added\.

1. In **URL**, copy the JDBC URL from the Amazon Redshift console and paste it here\.

1. In **Username**, type *masteruser*\.

1. In **Password**, type the password associated with the master user account\.

1. Choose the **Autocommit** box\. 

1. Choose the **Save profile list** icon, as shown below:  
![Profile](http://docs.aws.amazon.com/redshift/latest/gsg/images/sql_workbench_save.png)

1. Choose **OK**\.  
![Overall](http://docs.aws.amazon.com/redshift/latest/gsg/images/redshift_driver_sql_workbench.png)

</p></details>


# Step 6: Load Sample Data from Amazon S3<a name="rs-gsg-create-sample-db"></a>
At this point you have a database called `dev` and you are connected to it\. Now you will create a new database and tables, upload data to the tables, and try a query\. For your convenience, the sample data you will load is available in an Amazon S3 bucket\. 

### High-Level Instructions

Download all of the sample delimited data (6 x CSV files) from s3://pfizer-immersion-day/csv/ and examine the data structure. Create a total of 6 new tables for the different data types and run some sample queries. 


<details>
<summary><strong>Step-by-step instructions (expand for details)</strong></summary><p>


**Note**  
Before you proceed, ensure that your SQL Workbench/J client is connected to the cluster\.

1. Create a new database called **instacart_redshift**

    ``` sql
    CREATE DATABASE instacart_redshift
    ```

1. Create new tables within the **instacart_redshift** database\.

   Copy and execute the following create table statements to create tables in the `dev` database\. For more information about the syntax, go to [CREATE TABLE](http://docs.aws.amazon.com/redshift/latest/dg/r_CREATE_TABLE_NEW.html) in the *Amazon Redshift Database Developer Guide*\.

    ``` sql
    create table aisles(
    aisleid integer not null distkey sortkey,
    aisle varchar(30)
    );

    create table departments(
        department_id integer not null distkey sortkey,
        department varchar(30)
    );

    create table orders(
        order_id integer not null distkey sortkey,
        user_id integer not null,
        eval_set varchar(30),
        order_number integer not null,
        order_dow integer not null,
        order_hour_of_day smallint not null,
        days_since_prior_order float
    );

    create table products(
        product_id integer not null distkey sortkey,
        product_name varchar(255),
        aisle_id integer not null,
        department_id integer not null
    );

    create table order_products__prior(
        order_id integer not null distkey sortkey,
        product_id integer not null,
        add_to_cart_order integer,
        reordered smallint
    );

    create table order_products__train(
        order_id integer not null distkey sortkey,
        product_id integer not null,
        add_to_cart_order integer,
        reordered smallint
    );
    ```

1.  Load sample data from Amazon S3 by using the COPY command\. 

    **Note**
    We recommend using the COPY command to load large datasets into Amazon Redshift from Amazon S3 or DynamoDB\. For more information about COPY syntax, see [COPY](http://docs.aws.amazon.com/redshift/latest/dg/r_COPY.html) in the *Amazon Redshift Database Developer Guide*\. 

    The sample data for this tutorial is provided in an Amazon S3 bucket that is owned by Amazon Redshift\. The bucket permissions are configured to allow all authenticated AWS users read access to the sample data files\. 

    To load the sample data, you must provide authentication for your cluster to access Amazon S3 on your behalf\. You can provide either role\-based authentication or key\-based authentication\. We recommend using role\-based authentication\. For more information about both types of authentication, see [CREDENTIALS](http://docs.aws.amazon.com/redshift/latest/dg/copy-parameters-credentials.html) in the Amazon Redshift Database Developer Guide\.

    For this step, you will provide authentication by referencing the IAM role you created and then attached to your cluster in previous steps\.
    **Note**  
    If you don’t have proper permissions to access Amazon S3, you receive the following error message when running the COPY command: `S3ServiceException: Access Denied`\.

    The COPY commands include a placeholder for the IAM role ARN, as shown in the following example\.

    ``` sql
    COPY aisles
    FROM 's3://pfizer-immersion-day/aisles.csv' 
    CREDENTIALS 'aws_iam_role=<iam-role-arn>'
    DELIMITER ',' REGION 'ap-southeast-2'
    FORMAT AS CSV
    IGNOREHEADER 1;
    ```
    
    To authorize access using an IAM role, replace *<iam\-role\-arn>* in the CREDENTIALS parameter string with the role ARN for the IAM role you created in [Step 2: Create an IAM Role](rs-gsg-create-an-iam-role.md)\. IGNOREHEADER 1 will tell Redshift to ignore *n* rows as column headers.


    To load the sample data, replace *<iam\-role\-arn>* in the following COPY commands with your role ARN\. Then run the commands in your SQL client tool\.

    ``` sql
    COPY aisles
    FROM 's3://pfizer-immersion-day/csv/aisles.csv' 
    CREDENTIALS 'aws_iam_role=<iam-role-arn>'
    DELIMITER ',' REGION 'ap-southeast-2'
    FORMAT AS CSV
    IGNOREHEADER 1;

    COPY departments
    FROM 's3://pfizer-immersion-day/csv/departments.csv' 
    CREDENTIALS 'aws_iam_role=<iam-role-arn>'
    DELIMITER ',' REGION 'ap-southeast-2'
    FORMAT AS CSV
    IGNOREHEADER 1

    COPY orders
    FROM 's3://pfizer-immersion-day/csv/orders.csv' 
    CREDENTIALS 'aws_iam_role=<iam-role-arn>'
    DELIMITER ',' REGION 'ap-southeast-2'
    FORMAT AS CSV
    IGNOREHEADER 1

    COPY products
    FROM 's3://pfizer-immersion-day/csv/products.csv' 
    CREDENTIALS 'aws_iam_role=<iam-role-arn>'
    DELIMITER ',' REGION 'ap-southeast-2'
    FORMAT AS CSV
    IGNOREHEADER 1

    COPY order_products__prior
    FROM 's3://pfizer-immersion-day/csv/order_products__prior.csv' 
    CREDENTIALS 'aws_iam_role=<iam-role-arn>'
    DELIMITER ',' REGION 'ap-southeast-2'
    FORMAT AS CSV
    IGNOREHEADER 1

    COPY order_products__train
    FROM 's3://pfizer-immersion-day/csv/order_products__train.csv' 
    CREDENTIALS 'aws_iam_role=<iam-role-arn>'
    DELIMITER ',' REGION 'ap-southeast-2'
    FORMAT AS CSV
    IGNOREHEADER 1
    ```

1. Now try the example queries\. For more information, go to [SELECT](http://docs.aws.amazon.com/redshift/latest/dg/r_SELECT_synopsis.html) in the *Amazon Redshift Developer Guide*\.

    ``` sql
    -- Get definition for the aisles table.
    SELECT *    
    FROM pg_table_def    
    WHERE tablename = 'aisles';    

    -- Find how many products are in each department.
    SELECT DISTINCT(departments.department) AS Departments, COUNT(products.product_id) AS items
    FROM   departments LEFT OUTER JOIN products on departments.department_id = products.department_id 
    GROUP BY departments.department
    
    ```

1. You can optionally go the Amazon Redshift console to review the queries you executed\. The **Queries** tab shows a list of queries that you executed over a time period you specify\. By default, the console displays queries that have executed in the last 24 hours, including currently executing queries\. 

   + Sign in to the AWS Management Console and open the Amazon Redshift console at [https://console\.aws\.amazon\.com/redshift/](https://console.aws.amazon.com/redshift/)\.

   + In the cluster list in the right pane, choose `your-cluster`\.

   + Choose the **Queries** tab\. 

    The console displays list of queries you executed as shown in the example below\.  
![queries](http://docs.aws.amazon.com/redshift/latest/gsg/images/cmdws-cluster-query-list.png)

   + To view more information about a query, choose the query ID link in the **Query** column or choose the magnifying glass icon\. 

    The following example shows the details of a query you ran in a previous step\.   
    ![query_result](http://docs.aws.amazon.com/redshift/latest/gsg/images/cmdws-cluster-query.png)

</p></details>