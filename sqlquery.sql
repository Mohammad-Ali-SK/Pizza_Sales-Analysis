-- Basic:

-- Q1. Retrieve the total number of orders placed.
select count(order_id) as total_order from orders


-- Q2. Calculate the total revenue generated from pizza sales.

select round(sum(order_detail.quantity * pizzas.price)::numeric,2) as total_revenue from order_detail
join pizzas on pizzas.pizza_id = order_detail.pizza_id

select * from pizzas

-- Q3. Identify the highest-priced pizza.
select pizza_type.name,pizzas.price from pizzas
join pizza_type on pizza_type.pizza_type_id = pizzas.pizza_type_id
order by price desc limit 1



-- Q4. Identify the most common pizza size ordered.
select pizzas.size as size, count(order_detail.order_details_id) as c from pizzas
join order_detail on pizzas.pizza_id = order_detail.pizza_id
group by size
order by c desc limit 1



-- Q5. List the top 5 most ordered pizza types along with their quantities.
select pizza_type.name as pizza_name, sum(order_detail.quantity) as quantity
from pizza_type
join pizzas on pizzas.pizza_type_id = pizza_type.pizza_type_id
join order_detail on order_detail.pizza_id = pizzas.pizza_id
group by pizza_name order by quantity desc limit 5


-- Intermediate:

-- Q1. Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_type.category as category, sum(order_detail.quantity) as quantity
from pizza_type
join pizzas on pizzas.pizza_type_id = pizza_type.pizza_type_id
join order_detail on order_detail.pizza_id = pizzas.pizza_id
group by category
order by quantity desc



-- Q2. Determine the distribution of orders by hour of the day.
SELECT 
    EXTRACT(HOUR FROM orders.time::TIME) AS ord_time, 
    COUNT(order_detail.order_id) AS ord_count 
FROM 
    orders
JOIN 
    order_detail ON order_detail.order_id = orders.order_id
GROUP BY 
    ord_time
ORDER BY 
    ord_count DESC 
LIMIT 10;




-- Q3. Join relevant tables to find the category-wise distribution of pizzas.

select pizza_type.category as category, count(name) from pizza_type
group by category



-- Q4. Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(quantity)::numeric) from
(select orders.date as date, sum(order_detail.quantity) as quantity from orders
join order_detail on order_detail.order_id = orders.order_id
group by date
order by quantity desc
) as quantity_ord;


-- Q5. Determine the top 3 most ordered pizza types based on revenue.
select pizza_type.name as name, round(sum(order_detail.quantity*pizzas.price)::numeric,2) as revenue from pizza_type
join pizzas on pizzas.pizza_type_id = pizza_type.pizza_type_id
join order_detail on order_detail.pizza_id  = pizzas.pizza_id
group by name
order by revenue desc limit 3

-- Advanced:

-- Q1. Calculate the percentage contribution of each pizza type to total revenue.

select pizza_type.category as name, round((round(sum(order_detail.quantity*pizzas.price)::numeric,2)/(select round(sum(order_detail.quantity*pizzas.price)::numeric,2) from pizzas
join order_detail on order_detail.pizza_id = pizzas.pizza_id))*100,2) as revenue from pizza_type
join pizzas on pizzas.pizza_type_id = pizza_type.pizza_type_id
join order_detail on order_detail.pizza_id  = pizzas.pizza_id
group by pizza_type.category
order by revenue desc


-- (select round(sum(order_detail.quantity*pizzas.price)::numeric,2) from pizzas
-- join order_detail on order_detail.pizza_id = pizzas.pizza_id)



-- Q2. Analyze the cumulative revenue generated over time.
select *,sum(revenue) over(order by time) as cumulative from 
(select orders.date as time, round(sum(order_detail.quantity*pizzas.price)::numeric,0) as revenue from orders
join order_detail on order_detail.order_id = orders.order_id
join pizzas on pizzas.pizza_id = order_detail.pizza_id
group by orders.date) as a

-- Q3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select * from 
(select * , dense_rank() over(partition by category order by revenue desc) as ranks
from 
(select pizza_type.name as pizza_name, pizza_type.category as category ,
round(sum(order_detail.quantity*pizzas.price)::numeric,2) as revenue
from pizza_type
join pizzas on pizzas.pizza_type_id = pizza_type.pizza_type_id
join order_detail on order_detail.pizza_id = pizzas.pizza_id
group by pizza_type.name, pizza_type.category
order by revenue desc) as a
)
where ranks <= 3








































































