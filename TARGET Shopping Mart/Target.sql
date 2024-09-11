select * from customers;
select * from geolocation;
select * from order_items;
select * from order_reviews;
select * from orders;
select * from payments;
select * from products;

--Q1.
SELECT column_name,data_type 
FROM shopping_mart.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'customers'

SELECT MIN(CAST(ORDER_PURCHASE_TIMESTAMP AS date)) AS Start_Date, MAX(CAST(ORDER_PURCHASE_TIMESTAMP AS date)) AS End_Date
FROM ORDERS;

--Q2.
SELECT COUNT(DISTINCT c.customer_city) AS City, COUNT(DISTINCT c.customer_state) AS State
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id

--Q3.
SELECT DATEPART(YEAR, order_purchase_timestamp) AS Years, COUNT(order_id) AS Order_Placed
FROM orders
GROUP BY DATEPART(YEAR, order_purchase_timestamp)

--Q4.
SELECT DATEPART(MONTH, order_purchase_timestamp) AS Months, COUNT(order_id) AS Order_Placed
FROM orders
GROUP BY DATEPART(MONTH, order_purchase_timestamp)
ORDER BY DATEPART(MONTH, order_purchase_timestamp)

--Q5.
SELECT CASE WHEN DATEPART(HOUR, order_purchase_timestamp) BETWEEN 0 AND 6 THEN 'Dawn'
			WHEN DATEPART(HOUR, order_purchase_timestamp) BETWEEN 7 AND 12 THEN 'Morning'
			WHEN DATEPART(HOUR, order_purchase_timestamp) BETWEEN 13 AND 18 THEN 'Afternoon'
			WHEN DATEPART(HOUR, order_purchase_timestamp) BETWEEN 19 AND 24 THEN 'Night'
			ELSE 'Unknown' END AS 'Hours', 
		COUNT(order_id) AS Orders
FROM orders
GROUP BY CASE WHEN DATEPART(HOUR, order_purchase_timestamp) BETWEEN 0 AND 6 THEN 'Dawn'
			WHEN DATEPART(HOUR, order_purchase_timestamp) BETWEEN 7 AND 12 THEN 'Morning'
			WHEN DATEPART(HOUR, order_purchase_timestamp) BETWEEN 13 AND 18 THEN 'Afternoon'
			WHEN DATEPART(HOUR, order_purchase_timestamp) BETWEEN 19 AND 24 THEN 'Night'
			ELSE 'Unknown' END
ORDER BY Orders DESC

--Q6.
SELECT c.customer_state AS State, DATEPART(MONTH, o.order_purchase_timestamp) as Months, COUNT(o.order_id) AS Orders
FROM orders o
INNER JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY c.customer_state, DATEPART(MONTH, o.order_purchase_timestamp)
ORDER BY c.customer_state, DATEPART(MONTH, o.order_purchase_timestamp)

--Q7.
SELECT customer_state, COUNT(DISTINCT customer_unique_id) AS Customers
FROM customers
GROUP BY customer_state
ORDER BY Customers DESC

--Q8.
WITH FINAL_TABLE AS 
(SELECT DATEPART(YEAR, CAST(o.order_purchase_timestamp AS date)) AS Years, ROUND(SUM(p.payment_value),2) AS Cost_of_Orders
FROM orders o
INNER JOIN payments p ON o.order_id = p.order_id
WHERE DATEPART(YEAR, CAST(ORDER_PURCHASE_TIMESTAMP AS date)) BETWEEN 2017 AND 2018
AND DATEPART(MONTH, CAST(ORDER_PURCHASE_TIMESTAMP AS date)) BETWEEN 1 AND 8
GROUP BY DATEPART(YEAR, CAST(o.order_purchase_timestamp AS date)))
SELECT *, ROUND(((Cost_of_Orders - Previous_Cost)/Previous_Cost)*100,2)
FROM
(SELECT *, LAG(Cost_of_Orders) OVER (ORDER BY Years) AS Previous_Cost
FROM FINAL_TABLE
)A

--OR--

SELECT *, ROUND(((Cost_of_Orders - Previous_Cost)/Previous_Cost)*100,2) AS Perc_Inc
FROM
(SELECT *, LAG(Cost_of_Orders) OVER (ORDER BY Years) AS Previous_Cost
FROM
(SELECT DATEPART(YEAR, CAST(o.order_purchase_timestamp AS date)) AS Years, ROUND(SUM(p.payment_value),2) AS Cost_of_Orders
FROM orders o
INNER JOIN payments p ON o.order_id = p.order_id
WHERE DATEPART(YEAR, CAST(ORDER_PURCHASE_TIMESTAMP AS date)) BETWEEN 2017 AND 2018
AND DATEPART(MONTH, CAST(ORDER_PURCHASE_TIMESTAMP AS date)) BETWEEN 1 AND 8
GROUP BY DATEPART(YEAR, CAST(o.order_purchase_timestamp AS date)))A)B

--Q9.
select c.customer_state, round(sum(p.payment_value),2) as Total_Price, round(AVG(p.payment_value),2) as Avg_Price
from customers c 
inner join orders o
on c.customer_id = o.customer_id
inner join payments p
on o.order_id = p.order_id
group by c.customer_state
order by sum(p.payment_value) desc

--Q10.
select c.customer_state, round(SUM(oi.freight_value),2) as Total_Freight, round(AVG(oi.freight_value),2) as Avg_Freight
from customers c
inner join orders o
on c.customer_id = o.customer_id
inner join order_items oi
on o.order_id = oi.order_id
group by c.customer_state
order by SUM(oi.freight_value) desc

--Q11. 
select order_id, DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date) as delivered_time_taken,
DATEDIFF(day, order_estimated_delivery_date, order_delivered_customer_date) as diff_delivery_time
from orders
order by delivered_time_taken desc

--Q12.
select customer_state, freight_val from
(select c.customer_state, round(AVG(oi.freight_value),2) as freight_val,
ROW_NUMBER() over (order by AVG(oi.freight_value) desc) as h_rnk,
ROW_NUMBER() over (order by AVG(oi.freight_value) asc) as l_rnk
from customers c
inner join orders o
on c.customer_id = o.customer_id
inner join order_items oi
on o.order_id = oi.order_id
group by c.customer_state)a
where h_rnk <= 5 or l_rnk <= 5

--Q13.
select customer_state, avg_delivery
from
(select c.customer_state, avg(DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)) as avg_delivery,
ROW_NUMBER() over (order by avg(DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)) desc) as h_rnk,
ROW_NUMBER() over (order by avg(DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)) asc) as l_rnk
from customers c
inner join orders o
on c.customer_id = o.customer_id
group by c.customer_state)a
where h_rnk <=5 or l_rnk <= 5

--Q14.
select c.customer_state,
avg(DATEDIFF(day, o.order_estimated_delivery_date,o.order_delivered_customer_date)) as fastest_delivery
from customers c
inner join orders o
on c.customer_id = o.customer_id
group by c.customer_state
order by fastest_delivery

--Q15.
select p.payment_type, datepart(month, CAST(o.order_purchase_timestamp as date)) as Month, COUNT(o.order_id) as Orders
from orders o
inner join payments p on
o.order_id = p.order_id
group by p.payment_type, datepart(month, CAST(o.order_purchase_timestamp as date))
order by p.payment_type, datepart(month, CAST(o.order_purchase_timestamp as date)) asc

--Q16. 
select p.payment_installments, COUNT(o.order_id) as Orders
from orders o
inner join payments p on
o.order_id = p.order_id
where p.payment_installments >=1
group by p.payment_installments
order by p.payment_installments