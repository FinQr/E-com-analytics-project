--ABC
CREATE OR REPLACE VIEW dwh.product_revenue
AS SELECT product_sk,
    sum(quantity * price) AS revenue
   FROM dwh.fact_sales
  WHERE order_status = 'completed'
  GROUP BY product_sk
  ORDER BY revenue DESC;

CREATE OR REPLACE VIEW dwh.revenue_total
AS SELECT sum(revenue) AS total_revenue
   FROM dwh.product_revenue;

CREATE OR REPLACE VIEW dwh.abc_calc
AS 
SELECT 
	product_sk,
    revenue,
    revenue / total_revenue AS revenue_share,
    sum(revenue / total_revenue) OVER (ORDER BY revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_share
FROM dwh.product_revenue, dwh.revenue_total;

CREATE MATERIALIZED VIEW dwh.abc
AS 
SELECT 
	product_sk,
    revenue,
    cum_share,
    CASE
        WHEN (cum_share * 100) <= 80 THEN 'A'
        WHEN (cum_share * 100) > 80 AND (cum_share * 100) < 95 THEN 'B'
        ELSE 'C'
    END AS abc_group
FROM dwh.abc_calc;


--XYZ
create OR REPLACE view dwh.product_sale
AS
select
	product_sk, 
	date_trunc('month', dd.full_date) as month,
	SUM(quantity) as sum_qu
from dwh.fact_sales t 
join dwh.dim_date dd on t.date_id = dd.date_id
where order_status = 'completed'
group by product_sk, dd.date_id
order by dd.full_date;

create MATERIALIZED VIEW dwh.xyz
AS
with covar as(
select 
	product_sk,
	ROUND(STDDEV(sum_qu) / AVG(sum_qu) * 100, 2) as cov
from dwh.product_sale
group by product_sk
)
select 
	product_sk,
	case 
		when cov <= 10 then 'X'
		when cov >10 and cov <=25 then 'Y'
		else 'Z'
	end as xyz
from covar;