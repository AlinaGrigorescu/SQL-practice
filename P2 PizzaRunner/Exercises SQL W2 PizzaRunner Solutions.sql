/*Q1. How many pizzas were ordered?*/
SELECT COUNT(*)
FROM pizza_runner.customer_orders

/*Q2.How many unique customer orders were made?*/

SELECT COUNT(DISTINCT(pizza_runner.customer_orders.order_id))
FROM pizza_runner.customer_orders

/*Q3.How many successful orders were delivered by each runner?*/

SELECT ro.runner_id,
      COUNT(ro.order_id) AS successful_orders
FROM pizza_runner.runner_orders ro
WHERE ro.cancellation NOT LIKE '%ell%' OR ro.cancellation IS NULL
GROUP BY ro.runner_id

/*Q4.How many of each type of pizza was delivered?*/

SELECT CAST(pn.pizza_name AS NVARCHAR(100)) AS pizza_name,
       COUNT(co.pizza_id) AS nr_ordered
FROM pizza_runner.pizza_names pn
LEFT JOIN pizza_runner.customer_orders co ON co.pizza_id=pn.pizza_id
WHERE EXISTS(
				SELECT 1 
				FROM pizza_runner.runner_orders ro
				WHERE ro.order_id=co.order_id AND (ro.cancellation NOT LIKE '%ell%' OR ro.cancellation IS NULL)
			)
GROUP BY CAST(pn.pizza_name AS NVARCHAR(100)) 

/*Q5.How many Vegetarian and Meatlovers were ordered by each customer?*/
SELECT co.customer_id,
       CAST(pn.pizza_name AS NVARCHAR(100)) AS pizza_name,
       COUNT(co.pizza_id) AS nr_ordered
FROM pizza_runner.customer_orders co
LEFT JOIN pizza_runner.pizza_names pn ON pn.pizza_id=co.pizza_id
GROUP BY co.customer_id,
       CAST(pn.pizza_name AS NVARCHAR(100))
ORDER BY co.customer_id

/*Q6.What was the maximum number of pizzas delivered in a single order?*/

SELECT TOP 1 co.order_id,
       COUNT(co.pizza_id) AS nr_ordered
FROM pizza_runner.customer_orders co
GROUP BY co.order_id
ORDER BY nr_ordered DESC

-- CTE proposed solution

WITH cte_ranked_orders AS (
  SELECT
    order_id,
    COUNT(pizza_id) AS pizza_count,
    RANK() OVER (ORDER BY COUNT(pizza_id) DESC) AS count_rank
  FROM pizza_runner.customer_orders AS t1
  WHERE EXISTS (
				SELECT 1 
				FROM pizza_runner.runner_orders AS t2
				WHERE t1.order_id = t2.order_id AND (t2.cancellation IS NULL OR t2.cancellation NOT IN ('Restaurant Cncellation', 'Cstomer Cancellation')
    )
  )
  GROUP BY order_id
)
SELECT pizza_count FROM cte_ranked_orders WHERE count_rank = 1;


/*Q7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?*/

WITH cte_cleaned_customer_orders AS (
  SELECT
    order_id,
    customer_id,
    pizza_id,
    CASE WHEN (exclusions IN ('null', '') OR exclusions IS NULL) THEN NULL ELSE exclusions END AS exclusions,
    CASE WHEN (extras IN ('null', '') OR exclusions IS NULL) THEN NULL ELSE extras END AS extras,
    order_time
  FROM pizza_runner.customer_orders
)
SELECT co.customer_id,
SUM (CASE WHEN (exclusions IS NULL AND extras IS NULL) THEN 0
	 ELSE 1
	 END) AS nr_changes
FROM cte_cleaned_customer_orders co
WHERE EXISTS (
				SELECT 1 
				FROM pizza_runner.runner_orders ro
				WHERE co.order_id = ro.order_id AND (ro.cancellation IS NULL OR ro.cancellation NOT IN ('Restaurant Cncellation', 'Cstomer Cancellation'))
    )
GROUP BY co.customer_id

/*Q8.How many pizzas were delivered that had both exclusions and extras?*/
/*Q9.What was the total volume of pizzas ordered for each hour of the day?*/

SELECT DATEPART(hour, CAST(pickup_time AS DATETIME)),
  COUNT(*) AS pizza_count
FROM pizza_runner.runner_orders
WHERE pickup_time NOT IN ('null')
GROUP BY DATEPART(hour, CAST(pickup_time AS DATETIME))
ORDER BY DATEPART(hour, CAST(pickup_time AS DATETIME));


SELECT DATEPART(hour, CAST(pickup_time AS DATETIME))
FROM pizza_runner.runner_orders
WHERE pickup_time NOT IN ('null')

/*Q10.What was the volume of orders for each day of the week?*/
SELECT DATEPART(weekday, CAST(pickup_time AS DATETIME)) AS DayOfTheWeek,
  COUNT(*) AS pizza_count
FROM pizza_runner.runner_orders
WHERE pickup_time NOT IN ('null')
GROUP BY DATEPART(weekday, CAST(pickup_time AS DATETIME))
ORDER BY DATEPART(weekday, CAST(pickup_time AS DATETIME));

/*B. Runner and Customer Experience*/
/*QB.1 How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)*/

SELECT 
       DATEPART(week, CAST(registration_date AS DATETIME)) AS weekofyear,
	   COUNT(runner_id) AS nr_runners
FROM pizza_runner.runners
GROUP BY DATEPART(week, CAST(registration_date AS DATETIME))

/*QB.2 What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?*/
/* INTERPRETATION : What is the AVERAGE difference between order time and pickup time?*/
WITH cte_pickuptime AS (
						SELECT DISTINCT co.order_id,
							   DATEDIFF(minute, CAST(co.order_time AS DATETIME), CAST(ro.pickup_time AS DATETIME)) AS MinutesToPickup
						FROM pizza_runner.customer_orders co
						INNER JOIN pizza_runner.runner_orders ro ON co.order_id=ro.order_id
						WHERE ro.pickup_time NOT IN ('null')
						)
SELECT AVG(MinutesToPickup) FROM cte_pickuptime


/*QB.3 Is there any relationship between the number of pizzas and how long the order takes to prepare?*/
SELECT DISTINCT co.order_id,
		DATEDIFF(minute, CAST(co.order_time AS DATETIME), CAST(ro.pickup_time AS DATETIME)) AS MinutesToPickup,
		COUNT(co.pizza_id) AS nr_pizzas_per_order
FROM pizza_runner.customer_orders co
INNER JOIN pizza_runner.runner_orders ro ON co.order_id=ro.order_id
WHERE ro.pickup_time NOT IN ('null')
GROUP BY co.order_id,
		DATEDIFF(minute, CAST(co.order_time AS DATETIME), CAST(ro.pickup_time AS DATETIME)) 

/*QB.4 What was the average distance travelled for each customer?*/
SELECT DISTINCT co.customer_id,
	   COUNT(ro.order_id) AS nr_orders,
	   SUM(CAST(TRIM(REPLACE(ro.distance,'km','')) AS FLOAT))/COUNT(ro.order_id) AS distance_to_customer
FROM pizza_runner.customer_orders co
INNER JOIN pizza_runner.runner_orders ro ON co.order_id=ro.order_id
WHERE ro.distance NOT IN ('null')
GROUP BY co.customer_id

--Check--
SELECT DISTINCT co.customer_id,
	   ro.order_id,
	   CAST(TRIM(REPLACE(ro.distance,'km','')) AS FLOAT)
FROM pizza_runner.customer_orders co
INNER JOIN pizza_runner.runner_orders ro ON co.order_id=ro.order_id
WHERE ro.distance NOT IN ('null')


/*QB.5 What was the difference between the longest and shortest delivery times for all orders?*/

SELECT DISTINCT co.order_id,
		DATEDIFF(minute, CAST(co.order_time AS DATETIME), CAST(ro.pickup_time AS DATETIME)) AS MinutesToPickup,
		RANK() OVER(ORDER BY DATEDIFF(minute, CAST(co.order_time AS DATETIME), CAST(ro.pickup_time AS DATETIME)))
FROM pizza_runner.customer_orders co
INNER JOIN pizza_runner.runner_orders ro ON co.order_id=ro.order_id
WHERE ro.pickup_time NOT IN ('null')
GROUP BY co.order_id, DATEDIFF(minute, CAST(co.order_time AS DATETIME), CAST(ro.pickup_time AS DATETIME))


/*QB.6 What was the average speed for each runner for each delivery and do you notice any trend for these values?*/
SELECT DISTINCT ro.order_id,
	   CAST(TRIM(REPLACE(ro.distance,'km','')) AS FLOAT) AS distance_km,
	   CAST(SUBSTRING(ro.duration,1,2) AS FLOAT)/60 AS duration_hrs,
	   CAST(TRIM(REPLACE(ro.distance,'km','')) AS FLOAT)/(CAST(SUBSTRING(ro.duration,1,2) AS FLOAT)/60) AS speed_km_per_hr
FROM pizza_runner.runner_orders ro
WHERE ro.distance NOT IN ('null')


/*QB.7 What is the successful delivery percentage for each runner?*/
/* INTERPRETATION : What is the percentage of pickup time not NULL*/
SELECT runner_id,
	   CAST(SUM(CASE WHEN pickup_time NOT IN ('null') THEN 1 ELSE 0 END) AS FLOAT)/COUNT(runner_id) AS perc_successful_pickups,
	   COUNT(runner_id) AS nr_orders
FROM pizza_runner.runner_orders
GROUP BY runner_id
ORDER BY runner_id

/*C. Ingredient Optimisation*/
/*QC.1 What are the standard ingredients for each pizza?*/
WITH cte_pizza_recipes_clean AS(
								SELECT pr.pizza_id, CAST(value AS INT) AS topping_id
								FROM pizza_runner.pizza_recipes  pr
									CROSS APPLY STRING_SPLIT(convert(varchar(max), pr.toppings), ',')
	)
SELECT prc.pizza_id, STRING_AGG(CONVERT(NVARCHAR(max), pt.topping_name), ';') AS topping_name 
FROM cte_pizza_recipes_clean prc
LEFT JOIN pizza_runner.pizza_toppings pt ON  prc.topping_id=pt.topping_id
GROUP BY prc.pizza_id


/*QC.2 What was the most commonly added extra?*/
WITH cte_customer_orders_clean AS(
									SELECT order_id, TRIM(value) AS topping_id
									FROM pizza_runner.customer_orders
										 CROSS APPLY STRING_SPLIT(convert(varchar(max), extras), ',')
                                  )
SELECT coc.topping_id,
	   CAST(pt.topping_name AS NVARCHAR(100)),
       COUNT(coc.topping_id) AS nr_times_requested
FROM cte_customer_orders_clean coc
LEFT JOIN pizza_runner.pizza_toppings pt ON pt.topping_id=CAST(coc.topping_id AS INT)
WHERE coc.topping_id IS NOT NULL AND coc.topping_id NOT IN ('null','')
GROUP BY coc.topping_id, CAST(pt.topping_name AS NVARCHAR(100))


/*QC.3 What was the most common exclusion?*/
WITH cte_customer_orders_clean AS(
									SELECT order_id, value AS topping_id
									FROM pizza_runner.customer_orders
										 CROSS APPLY STRING_SPLIT(convert(varchar(max), exclusions), ',')
									)
SELECT coc.topping_id,
	CAST(pt.topping_name AS NVARCHAR(100)),
	COUNT(coc.order_id)
FROM cte_customer_orders_clean coc
LEFT JOIN pizza_runner.pizza_toppings pt ON pt.topping_id=CAST(coc.topping_id AS INT)
WHERE coc.topping_id NOT IN ('null','')
GROUP BY coc.topping_id,	CAST(pt.topping_name AS NVARCHAR(100))
ORDER BY COUNT(coc.order_id) DESC



/*QC.4 Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers*/
/* TO BE CONTINUED !!!*/
DROP TABLE IF EXISTS pizza_runner.customer_orders_cleaned_excluded
SELECT order_id, value AS topping_id_excluded, extras
INTO pizza_runner.customer_orders_cleaned_excluded
FROM pizza_runner.customer_orders
											CROSS APPLY STRING_SPLIT(convert(varchar(max), exclusions), ',')

WITH customer_orders_cleaned_excluded_extras AS(
										SELECT order_id, topping_id_excluded, value AS topping_id_extra
										FROM customer_orders_cleaned_excluded
																				 CROSS APPLY STRING_SPLIT(convert(varchar(max), extras), ',')
                                       )
SELECT * FROM customer_orders_cleaned_excluded_extras 


/*QC.5 Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"*/


/*QC.7 What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?*/



/*D. Pricing and Ratings*/
/*QD.1.If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?*/
SELECT SUM(CASE WHEN pn.pizza_name LIKE '%Veg%' THEN 10 ELSE 12 END) AS Total_Income
FROM pizza_runner.customer_orders co
LEFT JOIN pizza_runner.pizza_names pn ON pn.pizza_id=co.pizza_id

/*QD.2.What if there was an additional $1 charge for any pizza extras?
Add cheese is $1 extra*/
-- CREATE clean exclusions table
DROP TABLE IF EXISTS pizza_runner.customer_orders_exclusions_clean
SELECT order_id,
	   pizza_id,
	   CAST(TRIM(value) AS INT) AS exclusions_id
INTO pizza_runner.customer_orders_exclusions_clean
FROM pizza_runner.customer_orders
	CROSS APPLY STRING_SPLIT(convert(varchar(max), exclusions), ',')
WHERE exclusions NOT IN ('null','')

-- CREATE extras table
DROP TABLE IF EXISTS pizza_runner.customer_orders_extras_clean
SELECT order_id,
	   pizza_id,
	   CAST(TRIM(value) AS INT) AS extras_id
INTO pizza_runner.customer_orders_extras_clean
FROM pizza_runner.customer_orders
	CROSS APPLY STRING_SPLIT(convert(varchar(max), extras), ',')
WHERE extras NOT IN ('null','')

-- Compute total income with +2$ for each extra 
WITH cte_basic_price AS(
						SELECT co.order_id,
						       co.pizza_id,
						      SUM(CASE WHEN pn.pizza_name LIKE '%Veg%' THEN 10 ELSE 12 END) AS Total_Income
						FROM pizza_runner.customer_orders co
						LEFT JOIN pizza_runner.pizza_names pn ON pn.pizza_id=co.pizza_id
						GROUP BY co.order_id,
						       co.pizza_id
						),
 cte_nr_extras AS(
		              SELECT order_id,
						     pizza_id,
							 COUNT(extras_id) AS nr_extras
					  FROM pizza_runner.customer_orders_extras_clean
					  GROUP BY order_id,pizza_id
					  )
SELECT --cbp.order_id,
	  -- cbp.pizza_id,
	   SUM(cbp.Total_Income+2*COALESCE(cne.nr_extras,0))
	   --cne.nr_extras
FROM cte_basic_price cbp
LEFT JOIN cte_nr_extras cne ON cne.order_id=cbp.order_id AND cne.pizza_id=cbp.pizza_id

/*QD.3.The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
How would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.*/

/*QD.4.Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas

/*QD.5.If 
Meat Lovers pizza was $12 and 
Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled 
- how much money does Pizza Runner have left over after these deliveries?
