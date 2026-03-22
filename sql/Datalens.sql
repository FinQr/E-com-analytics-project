--total revenue
SELECT sum(total_amount) from dwh.fact_sales
where order_status = 'completed'

--avg revenue
select avg(total_amount) as avg_revenue from dwh.fact_sales
where order_status = 'completed'

--total units sold
select SUM(quantity)
from dwh.fact_sales

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
