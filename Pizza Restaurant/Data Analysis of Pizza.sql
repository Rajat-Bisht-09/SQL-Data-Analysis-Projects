-- Q1: Retrieve the total number of orders placed.
select count(*) as total_orders from orders;

-- Q2: Calculate the total revenue generated from pizza sales.
select round(sum(a.price*b.quantity),2) as total_revenue
from pizzas a 
join order_details b
on a.pizza_id = b.pizza_id;

-- Q3: Identify the highest-priced pizza.
select a.name, b.price
from pizza_types a
join pizzas b
on a.pizza_type_id = b.pizza_type_id
order by b.price desc
limit 1;

-- Q4: Identify the most common pizza size ordered.
select a.size, count(distinct b.order_details_id) as counts
from pizzas a join order_details b
on a.pizza_id = b.pizza_id
group by a.size
order by counts desc;

-- Q5: List the top 5 most ordered pizza types along with their quantities.
select pt.name, sum(o.quantity) as orders
from pizza_types pt join pizzas p on pt.pizza_type_id = p.pizza_type_id
join order_details o on p.pizza_id = o.pizza_id
group by pt.name
order by orders desc
limit 5;

-- Q6: Find the total quantity of each pizza category ordered.
select pt.category, sum(o.quantity) as orders
from pizza_types pt join pizzas p on pt.pizza_type_id = p.pizza_type_id
join order_details o on p.pizza_id = o.pizza_id
group by pt.category
order by orders desc;

-- Q7: Determine the distribution of orders by hour of the day.
select concat(hour(order_time), '-', hour(order_time)+1) as Hours, count(order_id) as Orders from orders
group by Hours
order by Orders desc;

-- Q8: Find the category-wise distribution of pizzas.
select category, count(pizza_type_id) as Distribution from pizza_types
group by category;

-- Q9: Group the orders by date and calculate the average number of pizzas ordered per day.
select o.order_date, sum(od.quantity) as orders_per_day from orders o
join order_details od on o.order_id = od.order_id
group by o.order_date;

select round(avg(orders_per_day)) as Avg_Pizza_Order from
(select o.order_date, sum(od.quantity) as orders_per_day from orders o
join order_details od on o.order_id = od.order_id
group by o.order_date) as d;

-- Q10: Determine the top 3 most ordered pizza types based on revenue.
select pt.name, round(sum(p.price*od.quantity),2) as revenue
from pizza_types pt join pizzas p 
on pt.pizza_type_id = p.pizza_type_id
join order_details od on p.pizza_id = od.pizza_id
group by pt.name
order by revenue desc
limit 3;

-- Q11: Calculate the percentage contribution of each pizza type to total revenue.
with first_table as (
select pt.category, round(sum(p.price*od.quantity),2) as revenue
from pizza_types pt join pizzas p 
on pt.pizza_type_id = p.pizza_type_id
join order_details od on p.pizza_id = od.pizza_id
group by pt.category),
second_table as (
select distinct pt.category, round(sum(p.price*od.quantity) over (),2) as total_revenue
from pizza_types pt join pizzas p 
on pt.pizza_type_id = p.pizza_type_id
join order_details od on p.pizza_id = od.pizza_id)
select a.category, a.revenue, b.total_revenue, round((a.revenue/b.total_revenue)*100,2) as perc_contri
from first_table a join 
second_table b on a.category = b.category;

-- Q12: Analyze the cumulative revenue generated over time.
select distinct o.order_date, round(sum(p.price*od.quantity) over (order by o.order_date),2) as revenue
from pizza_types pt join pizzas p 
on pt.pizza_type_id = p.pizza_type_id
join order_details od on p.pizza_id = od.pizza_id
join orders o on od.order_id = o.order_id;

-- Q13: Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name, revenue from (
select *, dense_rank() over (partition by category order by revenue desc) as rnk from
(select pt.category, pt.name, round(sum(p.price*od.quantity),2) as revenue
from pizza_types pt join pizzas p 
on pt.pizza_type_id = p.pizza_type_id
join order_details od on p.pizza_id = od.pizza_id
group by pt.category, pt.name)a)b
where rnk <= 3;