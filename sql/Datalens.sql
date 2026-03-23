--revenue
with order_total as(
	select 
        order_id, 
        SUM(price*quantity) as order_total_amount
	from dwh.fact_sales
	where order_status = 'completed'
	group by order_id
)
select sum(order_total_amount) as revenue
from order_total

--AOV
with order_total as(
	select order_id, Max(total_amount) as order_total_amount
	from dwh.fact_sales s
	join dwh.dim_date dd on s.date_id = dd.date_id
	where order_status = 'completed' and 
		dd.full_date BETWEEN {{period_ot}} and  {{period_do}}
	group by order_id
)
select 
	sum(order_total_amount) / count(order_id) as avg_revenue
from order_total

--conversion rate
WITH total_users AS (
    SELECT COUNT(*) AS total_cnt
    FROM dwh.dim_users
    where signup_date BETWEEN {{period_ot}} and  {{period_do}} --параметры периода
),
paying_users as (
    SELECT COUNT(DISTINCT user_sk) as paying_cnt
    from dwh.fact_sales s
    join dwh.dim_date dd on s.date_id = dd.date_id
    where order_status = 'completed' AND
        dd.full_date BETWEEN {{period_ot}} and  {{period_do}} --параметры периода
)
select paying_cnt::decimal / total_cnt as CR
from total_users, paying_users

--ARPU, ARPPU
with order_t as (
	select 
		order_id,
		Max(total_amount) as order_total_amount
	from dwh.fact_sales
	where order_status = 'completed'
	group by order_id
),
users_cnt as (
	select count(distinct user_sk) as user_cnt
	from dwh.fact_sales
),
purchase_users as (
    select 
        Count(Distinct user_sk) as paying_users
    from dwh.fact_sales s 
    where order_status = 'completed'
)
select SUM(order_total_amount) / user_cnt as arpu,
       SUM(order_total_amount) / paying_users as arppu
from order_t o, users_cnt, purchase_users
group by user_cnt, paying_users;

--revenue trend
SELECT sum(total_amount), date_trunc({{scale}}, dd.full_date) as date --scale - параметр
from  dwh.fact_sales s join dwh.dim_date dd ON s.date_id = dd.date_id
where order_status = 'completed'
group by date

--count orders 
select count(order_id), date_trunc({{scale}}, dd.full_date) as date --scale - параметр
from  dwh.fact_sales s join dwh.dim_date dd ON s.date_id = dd.date_id
where order_status = 'completed'
group by date
