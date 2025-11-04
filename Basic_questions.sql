show tables;

/*List all unique cities where customers are located*/
select distinct customer_city
from customers
order by customer_city;







/*Count the number of orders placed in 2017*/
select count(*) as total_orders_2017
from orders
where year(order_purchase_timestamp) = 2017

/*Find the total sales per category*/
select * from order_items;
select p.`product category`,
sum(oi.price + oi.freight_value) as total_sales
from order_items as oi 
join products p  on oi.product_id = p.product_id
group by p.`product category`
order by total_sales;

/*Calculate the percentage if orders paid in installments*/
select * from payments
select count(*) as total_orders,
round(sum(case when payment_installments > 1 then 1 else 0 end)*100/count(*),2) as percent_installment
from payments;

/*count the number customers of each state*/
select * from customers
select customer_state,
count(*) as total_customers
from customers 
group by customer_state
order by total_customers;