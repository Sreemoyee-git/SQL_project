/*Calculate moving average of order value for each customer over time(3 order moving average)*/
select * from order_items;
select o.customer_id, o.order_id, o.order_purchase_timestamp,
round(avg(p.payment_value) over (partition by o.customer_id order by o.order_purchase_timestamp
rows between 2 preceding and current row),2) as moving_avg_order_value
from orders o 
join payments p on o.order_id = p.order_id
order by o.customer_id, o.order_purchase_timestamp;

/*Calculate the cumulative sales per month of each year*/
select years, months, sales, sum(sales) over(order by years, months) as cumulative_sales
from (select year(o.order_purchase_timestamp) as years, month(o.order_purchase_timestamp) as months, round(sum(p.payment_value),2) as sales
from orders o
join payments p on o.order_id = p.order_id
group by years, months
order by years, months) a;

/*Calculate the number of repest customers*/
select count(*) as repeat_customers
from(select customer_id from orders
group by customer_id
having count(order_id)> 1) as sub;

/*Calculate year-over-year growth rate of total sales*/
select * from payments;
select year(order_purchase_timestamp) as year,
sum(payment_value) as total_sales
from orders o
join payments p on o.order_id = p.order_id
group by year
order by year;
select year(order_purchase_timestamp) as year,
sum(payment_value) as total_sales,
round(sum(p.payment_value) - lag(sum(p.payment_value)) over (order by year(order_purchase_timestamp))) /
lag(sum(p.payment_value)) over (order by year(order_purchase_timestamp)) * 100 as yoy_growth
from orders o 
join payments p on o.order_id = p.order_id
group by year
order by year;

/*Calculate retention rate*/
with first_and_last_orders as (select customer_id, min(order_purchase_timestamp) as first_order,
max(order_purchase_timestamp) as last_order from orders
group by customer_id)
select round(100* sum(case when timestampdiff(month, first_order, last_order) >= 6 then 1 else 0 end)/ count(*),2) as retention_rate
from first_and_last_orders;

/* Top 3 customers who spent the most in each year*/
with yearly_spending as (
select o.customer_id, 
extract(year from o.order_purchase_timestamp) as year,
sum(p.payment_value) as total_spent
from orders o
join payments p on o.order_id = p.order_id
group by o.customer_id, year),
ranked_customers as (select ys.customer_id, ys.year, ys.total_spent,
rank() over (partition by year order by ys.total_spent desc) as ranking
from yearly_spending ys)
select customer_id, year, total_spent,ranking
from ranked_customers
where ranking <= 3
order by year, ranking;
