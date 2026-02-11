create schema if not exists dwh;
---Dimension
--USERS

DROP TABLE IF EXISTS dwh.dim_users CASCADE;
CREATE TABLE dwh.dim_users(
    user_sk     serial PRIMARY KEY,
    user_id     text NOT NULL,
    user_name   text NOT NULL,
    email       varchar(100) NOT NULL,
    gender      text NOT NULL,
    city        text NOT NULL,
    signup_date date NOT NULL,

    CONSTRAINT valid_gender CHECK( gender in ('Male', 'Female', 'Other')),
    CONSTRAINT unique_email UNIQUE(email)
);
CREATE UNIQUE INDEX unique_index_user_id
ON dwh.dim_users(user_id);

--PRODUCTS

DROP TABLE IF EXISTS dwh.dim_products CASCADE;
CREATE TABLE dwh.dim_products(
    product_sk      serial  PRIMARY KEY,
    product_id      text    NOT NULL,
    product_name    text    NOT NULL,
    category        text    NOT NULL,
    brand           text    NOT NULL
);
CREATE UNIQUE INDEX unique_index_product_id
ON dwh.dim_products(product_id);

--DATE

DROP TABLE IF EXISTS dwh.dim_date CASCADE;
CREATE TABLE dwh.dim_date(
    date_id     serial  PRIMARY KEY,
    full_date   date    NOT NULL,
    year        int     NOT NULL,
    quarter     int     NOT NULL,
    month       int     NOT NULL,
    day         int     NOT NULL,

    CONSTRAINT unique_date UNIQUE(full_date)
);

---Facts
--SALES

DROP TABLE IF EXISTS dwh.fact_sales;
CREATE TABLE dwh.fact_sales(
    order_item_id text          PRIMARY KEY,
    order_id      text          NOT NULL,
    user_sk       int           NOT NULL,
    product_sk    int           NOT NULL,
    date_id       int           NOT NULL,
    order_status  text          NOT NULL,
    price         decimal(8,2)  NOT NULL,
    quantity      int           NOT NULL,
    total_amount  decimal(12,2) NOT NULL,

    FOREIGN KEY (user_sk)    REFERENCES dwh.dim_users(user_sk),
    FOREIGN KEY (product_sk) REFERENCES dwh.dim_products(product_sk),
    FOREIGN KEY (date_id)    REFERENCES dwh.dim_date(date_id)
);

--EVENTS

DROP TABLE IF EXISTS dwh.fact_events;
CREATE TABLE dwh.fact_events(
    event_id    text          PRIMARY KEY,
    date_id     int           NOT NULL,
    user_sk     int           NOT NULL,
    product_sk  int           NOT NULL,
    event_type  varchar(10)   NOT NULL,
    event_timestamp timestamp 	  NOT NULL,

    FOREIGN KEY (user_sk)    REFERENCES dwh.dim_users(user_sk),
    FOREIGN KEY (product_sk) REFERENCES dwh.dim_products(product_sk),
    FOREIGN KEY (date_id)    REFERENCES dwh.dim_date(date_id)
);

--REVIEWS

DROP TABLE IF EXISTS dwh.fact_reviews;
CREATE TABLE dwh.fact_reviews(
    review_id   text      PRIMARY KEY,
    date_id     int      NOT NULL,
    user_sk     int      NOT NULL,
    product_sk  int      NOT NULL,
    rating      int      NOT NULL,
    review_text text     NOT NULL,

    CONSTRAINT valid_rating CHECK (rating BETWEEN 1 and 5),

    FOREIGN KEY (user_sk)    REFERENCES dwh.dim_users(user_sk),
    FOREIGN KEY (product_sk) REFERENCES dwh.dim_products(product_sk),
    FOREIGN KEY (date_id)    REFERENCES dwh.dim_date(date_id)
);