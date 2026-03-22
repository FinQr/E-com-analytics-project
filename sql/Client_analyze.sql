--Cohort
create materialized view cohort 
as
with first_purchase as (
select 
	user_sk,
	MIN(dd.full_date) OVER(partition by user_sk) as f_purchase,
	date_trunc('month', full_date) as order_month
from dwh.fact_sales t 
join dwh.dim_date dd on t.date_id = dd.date_id 
where order_status = 'completed'
order by f_purchase
),
cohort as (
	select
		user_sk,
		date_trunc('month', f_purchase)::date as cohort_month
	from first_purchase
)
select
    c.cohort_month,
    DATE_PART('month', AGE(fp.order_month, c.cohort_month)) AS month_number,
    Count(distinct fp.user_sk)::decimal / Max(Count(distinct fp.user_sk)) over(partition by cohort_month) as retention
from first_purchase fp
join cohort c on fp.user_sk = c.user_sk
group by c.cohort_month, order_month;

--RFM
create materialized view dwh.client_rfm
as
with orders_customer as (
select
	user_sk,
	full_date as order_date,
	SUM(price*quantity) as order_amount
from dwh.fact_sales t 
join dim_date dd USING(date_id)
group by user_sk, order_id, full_date
order by user_sk, full_date
),
finally_date as (
	select MAX(full_date) as max_date
	from dim_date dd 
),
last_purchase as (
	select user_sk, MAX(order_date) as last_order_date
	from orders_customer
	group by user_sk
)
select 
	user_sk,
	date_part('day', Age(max_date, last_order_date)) as recency,
	COUNT(user_sk) as frequency,
	SUM(order_amount) as monetary
from orders_customer
join last_purchase USING(user_sk)
cross join finally_date
group by user_sk, max_date, last_order_date