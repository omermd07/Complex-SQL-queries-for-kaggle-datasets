'These problems are primarily sourced from LinkedIn challenges, where many popular blogs have mentioned them as particularly challenging ones.
1.
Write a SQL query to calculate the % of high-frequency customers for January 2023. A high-frequency customer is defined as someone who 
places more than 5 orders in a month. Your output should only include the % of these high-frequency customers.Round your results to 2 decimal points.

delivery_order table:

Column Name	Description
restaurant_id	Identifier of the restaurant
delivery_id	Unique identifier for each delivery
customer_id	ID of the customer placing the order
order_timestamp	Time the order was placed
Example Output:
ratio
0.24

My Approach:'
  
with high_frequency_customer as(
select customer_id
from delivery_order
where extract(month from order_timestamp) = 1
and extract(year from order_timestamp) = 2023
group by customer_id
order by count(deliver_id) > 5
),
total_customers as(
select count(distinct customer_id) as total
from delivery_order
where extract(month from order_timestamp) = 1
and extract(year from order_timestamp) = 2023




)
select round(count(hfc.customer_id) * 100 / tc.total,2) as ratio
from high_frequency_customer hfc, total_customer tc

