COPY aisles
FROM 's3://pfizer-immersion-day/aisles.csv' 
CREDENTIALS 'aws_iam_role=arn:aws:iam::649537638751:role/redshift-iam-role' 
DELIMITER ',' REGION 'ap-southeast-2'
FORMAT AS CSV
IGNOREHEADER 1;

COPY departments
FROM 's3://pfizer-immersion-day/departments.csv' 
CREDENTIALS 'aws_iam_role=arn:aws:iam::649537638751:role/redshift-iam-role' 
DELIMITER ',' REGION 'ap-southeast-2'
FORMAT AS CSV
IGNOREHEADER 1

COPY orders
FROM 's3://pfizer-immersion-day/orders.csv' 
CREDENTIALS 'aws_iam_role=arn:aws:iam::649537638751:role/redshift-iam-role' 
DELIMITER ',' REGION 'ap-southeast-2'
FORMAT AS CSV
IGNOREHEADER 1

COPY products
FROM 's3://pfizer-immersion-day/products.csv' 
CREDENTIALS 'aws_iam_role=arn:aws:iam::649537638751:role/redshift-iam-role' 
DELIMITER ',' REGION 'ap-southeast-2'
FORMAT AS CSV
IGNOREHEADER 1

COPY order_products__prior
FROM 's3://pfizer-immersion-day/order_products__prior.csv' 
CREDENTIALS 'aws_iam_role=arn:aws:iam::649537638751:role/redshift-iam-role' 
DELIMITER ',' REGION 'ap-southeast-2'
FORMAT AS CSV
IGNOREHEADER 1

COPY order_products__train
FROM 's3://pfizer-immersion-day/order_products__train.csv' 
CREDENTIALS 'aws_iam_role=arn:aws:iam::649537638751:role/redshift-iam-role' 
DELIMITER ',' REGION 'ap-southeast-2'
FORMAT AS CSV
IGNOREHEADER 1