# Module 1. RDS to S3 with Glue
## Background
In this module, we will move the data stored in our DBMS (MSSQL) to S3 using AWS Glue for raw data storage. AWS Glue is a fully managed extract, transform, and load (ETL) service that makes it easy for you to prepare and load your data for analytics.  You simply point AWS Glue to your data stored on AWS, and AWS Glue discovers your data and stores the associated metadata (e.g. table definition and schema) in the AWS Glue Data Catalog. Once cataloged, your data is immediately searchable, queryable, and available for ETL. AWS Glue generates the code to execute your data transformations and data loading processes. 


## Dataset
The dataset for the immersion day is a relational set of files describing [instacart](https://www.instacart.com) customers' orders over time. The dataset is anonymized and contains a sample of over 3 million grocery orders from more than 200,000 Instacart users. Between 4 and 100 orders are provided for each user, with the sequence of products purchased in each order. The week and hour of day the order was placed is also provided, with a relative measure of time between orders. For more information, see the following link: https://www.kaggle.com/c/instacart-market-basket-analysis/data

In our lab environment, the dataset is stored in a Microsoft SQL database.

## Lab Architecture 


## Pre-requisites
Each AWS account already has the following deployed:
- A [Virtual Private Cloud](https://aws.amazon.com/vpc/) to host deployed resources
- A Microsoft SQL Database Server in [AWS' Relational Database Service (RDS)](https://aws.amazon.com/rds/) to host the Instacart dataset
- Required networking setup. Subnets, routing tables, security groups and endpoints
- [Identity and Access Management](https://aws.amazon.com/iam/) Roles

These resources have been provisioned to reduce the time taken to perform the labs. It is worth reviewing these resources at a later time to understand how they're used in the solution.

## Implementation Instructions
Each of the following sections provides an implementation overview and detailed, step-by-step instructions. The overview should provide enough context for you to complete the implementation if you're already familiar with the AWS Management Console or you want to explore the services yourself without following a walkthrough.

If you're using the latest version of the Chrome, Firefox, or Safari web browsers the step-by-step instructions won't be visible until you expand the section.

### Region Selection
All labs will be performed in the AWS <span style="color:red">**Sydney (ap-southeast-2)**</span> region.

### 1. Create an S3 bucket 
To begin, we need to create the S3 buckets that will contain the exported raw CSV and parquet files of your dataset from your SQL server.

#### High-Level Instructions
Use the console or AWS CLI to create two Amazon S3 buckets. Keep in mind that your bucket names must be globally unique across all regions and customers. We recommend using the names, `datalab-raw-[account_id]` and `datalab-analytics-[account_id]`.

<details>
<summary><strong>Step-by-step instructions (expand for details)</strong></summary><p>

1. In the AWS Management Console choose **Services** then select **S3** under Storage.

2. Choose **+ Create Bucket**

3. Provide a globally unique name for your bucket such as `datalab-raw-[account_id]`.

4. Select the Region for this workshop from the dropdown.

5. Choose **Create** in the lower left of the dialog without selecting a bucket to copy settings from.

6. Choose **+ Create Bucket**

7. Provide a globally unique name for your bucket such as `datalab-analytics-[account_id]`.

8. Select the Region for this workshop from the dropdown.

9. Choose **Create** in the lower left of the dialog without selecting a bucket to copy settings from.

</p></details>


### 2. Create JDBC Connection 
Before cataloging and extracting the data from the database, we need to create a JDBC connection to the SQL server. To do this, follow the instructions below.

#### High-Level Instructions
Use the console or AWS CLI to create a JDBC connection in AWS Glue for the AWS RDS SQL Server that resides in the region being used for the lab. The details for the JDBC connection are provided in the step-by-step instructions below.

<details>
<summary><strong>Step-by-step instructions (expand for details)</strong></summary><p>

1. In the AWS Management Console choose **Services** then select **Glue**. Ensure that the region is set to **ap-southeast-2**.

2. To add a connection in the AWS Glue console, choose **Add Connection**. The wizard guides you through adding the properties that are required to create a JDBC connection to a data store. Use the following properties:

| Property                   | Value                  |
| -------------------------- |:----------------------:|
| Connection name            | SQL Server             |
| Connection type            | Amazon RDS             |
| Database engine            | Microsoft SQL Server   |
| Require SSL connection     | False                  |

Click **Next**

| Property         | Value                      |
| ---------------- |:--------------------------:|
| Instance         | `select the only option`   |
| Database Name    | instacart                  |
| Username         | dataadmin                  |
| Password         | `ask me`                   |

3. On the review page, take note of the Security Group ID. Click **Next** then **Finish**.

4. Select the newly created connection and choose **Test Connection**. This should come back successful.
</details>

### 3. Create a Data Catalog
Now that the JDBC connection has been created, we can create a data catalogue for the data in our SQL database by using an AWS Glue Crawler. The AWS Glue Data Catalog that will be built, will contains references to data that is used when determining the source and target of your extract, transform, and load (ETL) jobs in AWS Glue.

#### High-Level Instructions
Use the console or AWS CLI to create a cralwer in AWS Glue for the AWS RDS SQL Server that resides in the region being used for the lab. Once the crawler has been created, run it and check that the tables have been created in the catalog successfully.

<details>
<summary><strong>Step-by-step instructions (expand for details)</strong></summary><p>

1. Click on **Crawlers** on the left side of the page, and select **Add crawler**. 

2. For the crawler name, specify `instacart-rds` then select **Next**.

3. Choose **JDBC** as the datastore. Select the SQL Server connection created earlier. Under the include path, type `instacart` (the database name), then select **Next**.

4. Select **No**, then click **Next**.

5. Under the **IAM Role**, select **Choose an existing IAM role** select `AWSGlueServiceRole-DataLab`, then select **Next**.

6. Under **Frequency**, select **Run On Demand** then select **Next**.

7. Select **Add Database** and choose the name `instacart-rds` then select **Next**, then **Finsh**.

8. Select the `instacart-rds` crawler and click **Run crawler**.

9. Once the crawler completes, note the number of tables added. Click on **Tables** and note the new tables created.
</details>

### 4. Extract SQL data to S3 as CSV
After the tables have been catalogued, we now need to create a Glue ETL job to extract the data to S3. 

#### High-Level Instructions
Create an S3 folder per table in the raw S3 bucket, and create a Glue ETL job to extract and dump the instacart database to the S3 bucket.

<details>
<summary><strong>Step-by-step instructions (expand for details)</strong></summary><p>

1. In the AWS Management Console choose **Services** then select **S3** under Storage.

2. Select the **S3** bucket `datalab-raw-[account_id]` then create the following folders:
    - aisles
    - departments
    - order_products_prior
    - order_products_train
    - orders
    - products

3. Navigate back to the **Glue** service, click on **Jobs** on the left side of the page, and select **Add job**. 

4. For the Job name, specify `rds2csv` and choose `AWSGlueServiceRole-DataLab`. Select **A new script to be authored by you**, then select **Python** as the **ETL Language**. Leave everything else as default, then select **Next**.

5. Select the **SQL Server** connection then select **Next**. Select **Save job and edit script**. Copy and paste the following, while changing the s3bucket variable.
 
 ```Python
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

job.init(args['JOB_NAME'], args)

s3bucket = "datalab-raw-12345678912"

#Aisles
datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "instacart-rds", table_name = "instacart_dbo_aisles", transformation_ctx = "datasource0")
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("aisle_id", "long", "aisle_id", "long"), ("aisle", "string", "aisle", "string")], transformation_ctx = "applymapping1")
datasink2 = glueContext.write_dynamic_frame.from_options(frame = applymapping1, connection_type = "s3", connection_options = {"path": "s3://" + s3bucket +  "/" + "aisles" }, format = "csv", transformation_ctx = "datasink2")

#Departments
datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "instacart-rds", table_name = "instacart_dbo_departments", transformation_ctx = "datasource0")
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("department_id", "long", "department_id", "long"), ("department", "string", "department", "string")], transformation_ctx = "applymapping1")
datasink2 = glueContext.write_dynamic_frame.from_options(frame = applymapping1, connection_type = "s3", connection_options = {"path": "s3://" + s3bucket +  "/" + "departments"}, format = "csv", transformation_ctx = "datasink2")

#Order Products Prior
datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "instacart-rds", table_name = "instacart_dbo_order_products__prior", transformation_ctx = "datasource0")
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("order_id", "long", "order_id", "long"), ("product_id", "long", "product_id", "long"), ("add_to_cart_order", "long", "add_to_cart_order", "long"), ("reordered", "long", "reordered", "long")], transformation_ctx = "applymapping1")
datasink2 = glueContext.write_dynamic_frame.from_options(frame = applymapping1, connection_type = "s3", connection_options = {"path": "s3://" + s3bucket +  "/" + "order_products_prior"}, format = "csv", transformation_ctx = "datasink2")

#Order Products Train
datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "instacart-rds", table_name = "instacart_dbo_order_products__train", transformation_ctx = "datasource0")
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("order_id", "long", "order_id", "long"), ("product_id", "long", "product_id", "long"), ("add_to_cart_order", "long", "add_to_cart_order", "long"), ("reordered", "long", "reordered", "long")], transformation_ctx = "applymapping1")
datasink2 = glueContext.write_dynamic_frame.from_options(frame = applymapping1, connection_type = "s3", connection_options = {"path": "s3://" + s3bucket +  "/" + "order_products_train"}, format = "csv", transformation_ctx = "datasink2")

#Orders
datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "instacart-rds", table_name = "instacart_dbo_orders", transformation_ctx = "datasource0")
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("order_id", "long", "order_id", "long"), ("user_id", "long", "user_id", "long"), ("eval_set", "string", "eval_set", "string"), ("order_number", "long", "order_number", "long"), ("order_dow", "long", "order_dow", "long"), ("order_hour_of_day", "long", "order_hour_of_day", "long"), ("days_since_prior_order", "double", "days_since_prior_order", "double")], transformation_ctx = "applymapping1")
datasink2 = glueContext.write_dynamic_frame.from_options(frame = applymapping1, connection_type = "s3", connection_options = {"path": "s3://" + s3bucket +  "/" + "orders"}, format = "csv", transformation_ctx = "datasink2")

#Products
datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "instacart-rds", table_name = "instacart_dbo_products", transformation_ctx = "datasource0")
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("product_id", "long", "product_id", "long"), ("product_name", "string", "product_name", "string"), ("aisle_id", "long", "aisle_id", "long"), ("department_id", "long", "department_id", "long")], transformation_ctx = "applymapping1")
datasink2 = glueContext.write_dynamic_frame.from_options(frame = applymapping1, connection_type = "s3", connection_options = {"path": "s3://" + s3bucket +  "/" + "products"}, format = "csv", transformation_ctx = "datasink2")

job.commit()
 ```

6. Click **Save** then click the **X** on the far top right corner to close the window.

7. Select the ETL job created and selection **Action** -> **Run Job**. 

8. Select the ETL job and view the job history

9. Once the job completes, go to the **S3** service, select the raw bucket, and analyze the contents of each folder. You should see files that have been created.

</details>

### 5. Convert CSV to Parquet
We've done a raw dump to S3 of the data in the instacart database, but now we want to optimise the file type to get better performance from our RedShift Athena queries. To do this, we need to convert our files to parquet, which is a columnar format. 

#### High-Level Instructions
Create an S3 folder per table in the analytics S3 bucket, and create a Glue ETL job to extract and dump the CSV data in the raw bucket to Parquet in the analytics bucket.

<details>
<summary><strong>Step-by-step instructions (expand for details)</strong></summary><p>

1. Click on **Crawlers** on the left side of the page, and select **Add crawler**. 

2. For the crawler name, specify `instacart-csv` then select **Next**.

3. Choose **S3** as the datastore. Select to crawl data in the **Specified path in my account**, and specify the raw bucket. i.e. s3://datalab-raw-12345678912/. Select **Next**.

4. Select **No**, then click **Next**.

5. Under the **IAM Role**, select **Choose an existing IAM role** select `AWSGlueServiceRole-DataLab`, then select **Next**.

6. Under **Frequency**, select **Run On Demand** then select **Next**.

7. Select **Add Database** and choose the name `instacart-csv` then select **Next**, then **Finsh**.

8. Select the `instacart-csv` crawler and click **Run crawler**.

9. Once the crawler completes, note the number of tables added. Click on **Tables** and note the new tables created.

10. In the AWS Management Console choose **Services** then select **S3** under Storage.

11. Select the **S3** bucket `datalab-analytics-[account_id]` then create the following folders:
    - aisles
    - departments
    - order_products_prior
    - order_products_train
    - orders
    - products

3. Navigate back to the **Glue** service, click on **Jobs** on the left side of the page, and select **Add job**. 

4. For the Job name, specify `csv2parq` and choose `AWSGlueServiceRole-DataLab`. Select **A new script to be authored by you**, then select **Python** as the **ETL Language**. Leave everything else as default, then select **Next**.

5. Select **Next** under *Connections** then select **Save job and edit script**. Copy and paste the following, while changing the s3bucket variable.
 
 ```Python
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

job.init(args['JOB_NAME'], args)

s3bucket = "datalab-analytics-12345678912"

datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "instacart-s3", table_name = "aisles", transformation_ctx = "datasource0")
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("aisle_id", "long", "aisle_id", "long"), ("aisle", "string", "aisle", "string")], transformation_ctx = "applymapping1")
datasink2 = glueContext.write_dynamic_frame.from_options(frame = applymapping1, connection_type = "s3", connection_options = {"path": "s3://" + s3buckets + "/" + "aisles" }, format = "parquet", transformation_ctx = "datasink2")

datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "instacart-s3", table_name = "departments", transformation_ctx = "datasource0")
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("department_id", "long", "department_id", "long"), ("department", "string", "department", "string")], transformation_ctx = "applymapping1")
datasink2 = glueContext.write_dynamic_frame.from_options(frame = applymapping1, connection_type = "s3", connection_options = {"path": "s3://" + s3buckets + "/" + "departments"}, format = "parquet", transformation_ctx = "datasink2")

datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "instacart-s3", table_name = "order_products_prior", transformation_ctx = "datasource0")
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("order_id", "long", "order_id", "long"), ("product_id", "long", "product_id", "long"), ("add_to_cart_order", "long", "add_to_cart_order", "long"), ("reordered", "long", "reordered", "long")], transformation_ctx = "applymapping1")
datasink2 = glueContext.write_dynamic_frame.from_options(frame = applymapping1, connection_type = "s3", connection_options = {"path": "s3://datalab-analytics-467751274256/" + "order_products_prior"}, format = "parquet", transformation_ctx = "datasink2")

datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "instacart-s3", table_name = "order_products_train", transformation_ctx = "datasource0")
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("order_id", "long", "order_id", "long"), ("product_id", "long", "product_id", "long"), ("add_to_cart_order", "long", "add_to_cart_order", "long"), ("reordered", "long", "reordered", "long")], transformation_ctx = "applymapping1")
datasink2 = glueContext.write_dynamic_frame.from_options(frame = applymapping1, connection_type = "s3", connection_options = {"path": "s3://datalab-analytics-467751274256/" + "order_products_train"}, format = "parquet", transformation_ctx = "datasink2")

datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "instacart-s3", table_name = "orders", transformation_ctx = "datasource0")
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("order_id", "long", "order_id", "long"), ("user_id", "long", "user_id", "long"), ("eval_set", "string", "eval_set", "string"), ("order_number", "long", "order_number", "long"), ("order_dow", "long", "order_dow", "long"), ("order_hour_of_day", "long", "order_hour_of_day", "long"), ("days_since_prior_order", "double", "days_since_prior_order", "double")], transformation_ctx = "applymapping1")
datasink2 = glueContext.write_dynamic_frame.from_options(frame = applymapping1, connection_type = "s3", connection_options = {"path": "s3://datalab-analytics-467751274256/" + "orders"}, format = "parquet", transformation_ctx = "datasink2")

datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "instacart-s3", table_name = "products", transformation_ctx = "datasource0")
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("product_id", "long", "product_id", "long"), ("product_name", "string", "product_name", "string"), ("aisle_id", "long", "aisle_id", "long"), ("department_id", "long", "department_id", "long")], transformation_ctx = "applymapping1")
datasink2 = glueContext.write_dynamic_frame.from_options(frame = applymapping1, connection_type = "s3", connection_options = {"path": "s3://datalab-analytics-467751274256/" + "products"}, format = "parquet", transformation_ctx = "datasink2")

job.commit()
```

6. Click **Save** then click the **X** on the far top right corner to close the window.

7. Select the ETL job created and selection **Action** -> **Run Job**. 

8. Once complete, go to the **S3** service, select the analysis bucket, and analyze the contents of each folder. You should see files that have been created.

</details>
