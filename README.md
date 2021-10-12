# SQL-projects

# Project 1: Danny's Diner

# Case Study Questions
Q1. What is the total amount each customer spent at the restaurant?<br>
Q2. How many days has each customer visited the restaurant?<br>
Q3. What was the first item from the menu purchased by each customer?<br>
Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?<br>
Q5. Which item was the most popular for each customer?<br>
Q5. Which item was purchased first by the customer after they became a member?<br>
Q6. Which item was purchased just before the customer became a member?<br>
Q7. What is the total items and amount spent for each member before they became a member?<br>
Q8. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?<br>
Q9. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?<br>

<b> Topics relevant to the Danny’s Diner case study:</b><br>

Common Table Expressions<br>
Group By Aggregates<br>
Window Functions for ranking<br>
Table Joins<br>

# Project 2: Pizza Runner

# Case Study Questions
<b> A. Pizza Metrics </b><br>
QA.01 How many pizzas were ordered?<br>
QA.02 How many unique customer orders were made?<br>
QA.03 How many successful orders were delivered by each runner?<br>
QA.04 How many of each type of pizza was delivered?<br>
QA.05 How many Vegetarian and Meatlovers were ordered by each customer?<br>
QA.06 What was the maximum number of pizzas delivered in a single order?<br>
QA.07 For each customer, how many delivered pizzas had at least 1 change and how many had no changes?<br>
QA.08 How many pizzas were delivered that had both exclusions and extras?<br>
QA.09 What was the total volume of pizzas ordered for each hour of the day?<br>
QA.10 What was the volume of orders for each day of the week?<br>

<b> B. Runner and Customer Experience </b><br>
QB.01 How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)<br>
QB.02 What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?<br>
QB.03 Is there any relationship between the number of pizzas and how long the order takes to prepare?<br>
QB.04 What was the average distance travelled for each customer?<br>
QB.05 What was the difference between the longest and shortest delivery times for all orders?<br>
QB.06 What was the average speed for each runner for each delivery and do you notice any trend for these values?<br>
QB.07 What is the successful delivery percentage for each runner?<br>

<b>C. Ingredient Optimisation</b><br>
QC.01 What are the standard ingredients for each pizza?<br>
QC.02 What was the most commonly added extra?<br>
QC.03 What was the most common exclusion?<br>
QC.04 Generate an order item for each record in the customers_orders table in the format of one of the following:<br>
Meat Lovers<br>
Meat Lovers - Exclude Beef<br>
Meat Lovers - Extra Bacon<br>
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers<br>
QC.05 Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"<br>
QC.06 What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?<br>

<b>D. Pricing and Ratings</b><br>
QD.01 If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?<br>
QD.02 What if there was an additional $1 charge for any pizza extras?<br>
Add cheese is $1 extra<br>
QD.03 The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.<br>
QD.04 Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?<br>
- customer_id<br>
- order_id<br>
- runner_id<br>
- rating<br>
- order_time<br>
- pickup_time<br>
- Time between order and pickup<br>
- Delivery duration<br>
- Average speed<br>
- Total number of pizzas<br>
QD.05 If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?<br>

<b> Topics relevant to the case study:</b><br>
Common table expressions<br>
Group by aggregates<br>
Table joins<br>
String transformations<br>
Dealing with null values<br>
Regular expressions
