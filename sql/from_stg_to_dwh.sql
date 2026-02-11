--INSERT dim_date

truncate table dwh.dim_date CASCADE;
INSERT INTO dwh.dim_date (full_date, year, quarter, month, day)
SELECT DISTINCT
    d::date                                  AS full_date,
    EXTRACT(YEAR FROM d)                     AS year,
    EXTRACT(QUARTER FROM d)                  AS quarter,
    EXTRACT(MONTH FROM d)                    AS month,
    EXTRACT(DAY FROM d)                      AS day
FROM (
    SELECT signup_date::date as d from stg.users_raw
    UNION
    SELECT order_date::date as d from stg.orders_raw
    UNION
    SELECT review_date::date as d from stg.reviews_raw
);

--INSERT dim_users
truncate table dwh.dim_users CASCADE;
INSERT INTO dwh.dim_users (user_id, user_name, email, gender, city, signup_date)
SELECT DISTINCT
    user_id,
    user_name,
    email,
    gender,
    city,
    signup_date::date
FROM stg.users_raw;

--INSERT dim_products
truncate table dwh.dim_products CASCADE;
INSERT INTO dwh.dim_products (product_id, product_name, category, brand)
SELECT DISTINCT 
	product_id,
	product_name,
	category,
	brand
FROM stg.products_raw;

--INSERT fact_sales
truncate table dwh.fact_sales;
INSERT INTO dwh.fact_sales (
    order_item_id,
    order_id,
    user_sk,
    product_sk,
    date_id,
    order_status,
    price,
    quantity,
    total_amount
)
SELECT 
	ord_it.order_item_id,
	ord_it.order_id,
	du.user_sk,
	dp.product_sk,
	dd.date_id,
	o.order_status,
	ord_it.item_price as price,
	ord_it.quantity,
	o.total_amount
FROM stg.order_items_raw ord_it
JOIN stg.orders_raw o ON ord_it.order_id = o.order_id
JOIN dwh.dim_users du ON ord_it.user_id = du.user_id
JOIN dwh.dim_products dp ON ord_it.product_id = dp.product_id 
JOIN dwh.dim_date dd ON dd.full_date = o.order_date::date;

--INSERT fact_reviews
truncate table dwh.fact_reviews;
INSERT INTO dwh.fact_reviews (
	review_id,
    date_id,
    user_sk,
    product_sk,
    rating,
    review_text
)
SELECT
	r.review_id,
	dd.date_id,
	du.user_sk,
	dp.product_sk,
	r.rating,
	r.review_text
FROM stg.reviews_raw r
JOIN dwh.dim_date dd ON dd.full_date = r.review_date::date
JOIN dwh.dim_users du ON du.user_id = r.user_id
JOIN dwh.dim_products dp ON dp.product_id = r.product_id;

--INSERT dwh.fact_events
truncate table dwh.fact_events;
INSERT INTO dwh.fact_events (
	event_id,
    date_id,
    user_sk,
    product_sk,
    event_type,
    event_timestamp
)
SELECT 
	e.event_id,
	dd.date_id,
	du.user_sk,
	dp.product_sk,
	e.event_type,
	e.event_timestamp::timestamp
FROM stg.events_raw e
JOIN dwh.dim_date dd ON dd.full_date = e.event_timestamp::date
JOIN dwh.dim_users du ON du.user_id = e.user_id
JOIN dwh.dim_products dp ON dp.product_id = e.product_id;


