create schema if not exists stg;

---STAGING слой хранит данные из csv без ограничений и связей
--Users

DROP TABLE IF EXISTS stg.users_raw;
CREATE TABLE stg.users_raw (
    user_id 	text,
    user_name   text,
    email   	text,
    gender  	text,
    city    	text,
    signup_date date
);

--Products

DROP TABLE IF EXISTS stg.products_raw;
CREATE TABLE stg.products_raw (
    product_id      text,
    product_name    text,
    category        text,
    brand           text,
    price           decimal(8,2),
    rating          int
);


--Orders

DROP TABLE IF EXISTS stg.orders_raw;
CREATE TABLE stg.orders_raw (
    order_id     text,
    user_id      text,
    order_date   date,
    order_status text,
    total_amount decimal(12,2)
);

--Order Items

DROP TABLE IF EXISTS stg.order_items_raw;
CREATE TABLE stg.order_items_raw (
    order_item_id   text,
    order_id        text,
    product_id      text,
    user_id			text,
    quantity        int,
    item_price      decimal(8,2),
    item_total      decimal(8,2)
);

--Reviews

DROP TABLE IF EXISTS stg.reviews_raw;
CREATE TABLE stg.reviews_raw (
    review_id    text,
    order_id	 text,
    user_id      text,
    product_id   text,
    rating       int,
    review_text  text,
    review_date  date
);

DROP TABLE IF EXISTS stg.events_raw;
CREATE TABLE stg.events_raw (
    event_id    text,
    user_id     text,
    product_id  text,
    event_type  text,
    event_timestamp timestamp
);