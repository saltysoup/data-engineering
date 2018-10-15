# Module 3 - Redshift Spectrum

## Background
In this module, you will learn how to use AWS Glue to create a data catalog, and use Redshift Spectrum to query data in Amazon S3.

## Implementation Instructions

Each of the following sections provides an implementation overview and detailed, step-by-step instructions. The overview should provide enough context for you to complete the implementation if you're already familiar with the AWS Management Console or you want to explore the services yourself without following a walkthrough.

# Step 1: Set Up IAM Role Prerequisites<a name="rs-gsg-prereq"></a>

## References
1. [Setting up IAM Permissions for AWS Glue](http://docs.aws.amazon.com/glue/latest/dg/getting-started-access.html)
1. [Setting up IAM Permissions for Amazon Redshift Spectrum](http://docs.aws.amazon.com/redshift/latest/dg/c-spectrum-iam-policies.html)

### High-Level Instructions

Create 2 x new IAM roles for the AWS Glue and Redshift service to interact with your S3 resource. The suggested mananaged polices for the Glue role are `AWSGlueServiceRole`, `AWSGlueServiceNotebookRole` and `AmazonS3FullAccess`. The suggested managed policies for the Redshift role are `AWSGlueServiceRole`, `AmazonS3ReadOnlyAccess` and `AmazonAthenaFullAccess`.

<details>
<summary><strong>Step-by-step instructions (expand for details)</strong></summary><p>

## Setup IAM Permissions for AWS Glue
1. Access the IAM console and select **Users**. Then select your username

1. Click **Add Permissions** button

1. From the list of managed policies, attach the following:

    + AWSGlueConsoleFullAccess
    + CloudWatchLogsReadOnlyAccess
    + AWSCloudFormationReadOnlyAccess

## Setup AWS Glue default service role
1. From the IAM console click **Roles** and create a new role

1. Select **Glue** from the list of services and click the **Next:Permissions** button
![Glue IAM](http://amazonathenahandson.s3-website-us-east-1.amazonaws.com/images/glue_role.png)

1. From the list of managed policies, attach the following by searching for their name and click **Next:Review** when done.

    + AWSGlueServiceRole
    + AWSGlueServiceNotebookRole
    + AmazonS3FullAccess

1. Give your role a name, such as **AWSGlueServiceRole** and click **Create Role**

![Glue Service Role](http://amazonathenahandson.s3-website-us-east-1.amazonaws.com/images/glue_role_final.png)

## Setup Amazon Redshift Spectrum service role
1. From the IAM console click **Roles** and create a new role

1. Select **Redshift** from the list of services followed by **Redshift - Customizable** use case and click the **Next:Permissions** button

![Redshift IAM](http://amazonathenahandson.s3-website-us-east-1.amazonaws.com/images/spectrum_role.png)

1. From the list of managed policies, attach the following by searching for their name and click **Next:Review** when done.
    + AWSGlueServiceRole
    + AmazonS3ReadOnlyAccess
    + AmazonAthenaFullAccess

![Spectrum roles](http://amazonathenahandson.s3-website-us-east-1.amazonaws.com/images/spectrum_role_review.png)

1. Give your role a name, such as **SpectrumServiceRole** and click Create Role

1. Once created, navigate back to the **Roles** section of IAM console and search for the role we just created. Select your role and copy the **Role ARN** to your clipboard

1. If you already have a Redshift cluster follow these [instructions](http://docs.aws.amazon.com/redshift/latest/dg/c-getting-started-using-spectrum-add-role.html) to attach the new role to it. If you do not have a cluster go ahead and create one making sure to associate this new role with the cluster at creation time.


</p></details>


# Step 2: Crawling and Data Catalog <a name="rs-gsg-ctq"></a>

## References
1. [AWS Glue Crawler](https://docs.aws.amazon.com/glue/latest/dg/add-crawler.html)

## The Data Source
We will use a public data set provided by [Instacart in May 2017](https://tech.instacart.com/3-million-instacart-orders-open-sourced-d40d29ead6f2) to look at Instcart's customers' shopping pattern. You can find the data dictionary for the data set [here](https://gist.github.com/jeremystan/c3b39d947d9b88b3ccff3147dbcf6c6b)

## Crawling the data set
`Ensure that the Glue Crawler is in the same region as your S3 bucket and Redshift cluster`

### High-Level Instructions
Create a new Glue crawler that will catalog the **S3 bucket from Module 1** that contains your parquet format files. If you don't have these files, you can use the files within **s3://pfizer-immersion-day/parquet/**.

Verify that the newly created Glue Data Catalog has detected the correct classification and schema for the files.

<details>
<summary><strong>Step-by-step instructions (expand for details)</strong></summary><p>

## Crawling the data set
1. Open the AWS Glue console

1. Select **Crawler** and click **Add Crawler**

1. Give your crawler a name and choose the Glue IAM role we created in Step 1 **AWSGlueServiceRole**

1. Select **S3** as the **Data Source** and specify a path in **my account**. Use the **location containing your parquet files from Module 1**, or use **s3://pfizer-immersion-day/parquet/** as the S3 path.

1. Do not add any additional data sources and select **Run On Demand** for frequency.

1. Create a new database called **spectrum** and hit next after leaving the **table prefix** blank.

1. Click **Finish** to complete creating the crawler

1. Run the new crawler

</p></details>

## Verifying the Data Catalog

### High-Level Instructions

Verify that the catalog is correctly classified as parquet, with the same schema as the files. To view the parquet file, you will need to use a tool such as Pandas data frame in Python.

<details>
<summary><strong>Step-by-step instructions (expand for details)</strong></summary><p>

1. From the Glue console select the **spectrum** database, and open **Tables in spectrum**.

1. Verify that the **Classification** field for the tables are detected as **parquet**, and the schema within the table has the correct **Column Name** and **Data Type**

1. To view the contents of the parquet file, install the **pandas** module in python and use the **read_parquet** function

1. Install pandas module using pip

    ``` shell
    pip install pandas
    ```

1. To use pandas in python, open a new python console session

    ``` python
    import pandas as pd

    pd.read_parquet("your/path/file.parquet")
    ```

</p></details>

# Step 3: Using Redshift Spectrum <a name="rs-gsg-spectrum"></a>

## References

1. [External Schema for Spectrum](https://docs.aws.amazon.com/redshift/latest/dg/c-spectrum-external-schemas.html)

Now that we have a Glue Data Catalog, we can create a new External Schema in Redshift and use this to query data in S3 using Spectrum. Note that in the previous Module, we defined the schema, then copied the CSV data into the Redshift Cluster. In this exercise, we can query the data without needing a local copy in Redshift.

### High-Level Instructions

On your SQL Client tool or the Redshift Query Editor console, create a new external schema using the Glue data catalog that you created in Step 2. Run sample queries to test that Spectrum is able to pull data out from S3.

<details>
<summary><strong>Step-by-step instructions (expand for details)</strong></summary><p>


### SQL Client
To run queries on Redshift you will need a SQL tool such as SQL Workbench/J. You can find instructions to set it up [here](http://docs.aws.amazon.com/redshift/latest/mgmt/connecting-using-workbench.html)

### Redshift Query Editor NEW!
If your Redshift cluster is compatible with the new Query Editor feature, you can use connect to your Redshift and use SQL queries on the AWS console.


1. Before we can query data in S3 using Spectrum we need to create an external schema configured to interface with the Glue Data Catalog. Open up SQL Workbench/J or a similar tool and run the following commands in sequence:

    ``` sql
    SET autocommit ON
    ```

    ``` sql
    CREATE EXTERNAL SCHEMA spectrum
    FROM data catalog 
    DATABASE 'spectrum' 
    IAM_ROLE 'YOUR-SPECTRUM-ROLE-ARN'
    CREATE EXTERNAL DATABASE IF NOT EXISTS;
    
    /* For example
    CREATE EXTERNAL SCHEMA spectrum
    FROM data catalog 
    DATABASE 'spectrum' 
    IAM_ROLE 'arn:aws:iam::288678441234:role/redshift-spectrum'
    CREATE EXTERNAL DATABASE IF NOT EXISTS;
    */
    ```


    In the above statement we create an external schema within Redshift to tell it that database `spectrum` and all its tables are managed by the Glue Data Catalog. Also make sure to use the IAM role ARN you created in the first section of this Module.

    Now we have an external Redshift schema defined pointing to our database in Glue Data Catalog we can start running some queries.

1. Still from within SQL Workbench/J, lets verify that our fact tables (products and departments) were created in Redshift
    
    ``` sql
    -- List the first 20 product names in the products table
    SELECT product_name
    FROM spectrum.products
    LIMIT 20

    -- Find how many products are in each department.
    SELECT DISTINCT(department) AS Departments, COUNT(product_id) AS items
    FROM   spectrum.departments LEFT OUTER JOIN spectrum.products on departments.department_id = products.department_id 
    GROUP BY department
    
    -- Find the top 20 best selling items from both redshift and spectrum tables
    SELECT product_name, COUNT(order_products_prior.product_id) AS Number_Of_Orders
    FROM spectrum.products LEFT OUTER JOIN order_products_prior on products.product_id = order_products_prior.product_id
    GROUP BY product_name
    ORDER BY Number_Of_Orders DESC
	LIMIT 20

    ```

</p></details>