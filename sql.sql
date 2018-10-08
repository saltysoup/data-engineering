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