/*Q1. What is the total amount each customer spent at the restaurant?*/
SELECT sa.customer_id,
       SUM(me.price) AS TotalSpent
FROM dannys_diner.sales sa
LEFT JOIN dannys_diner.menu me ON sa.product_id=me.product_id
GROUP BY sa.customer_id

/*Q2. How many days has each customer visited the restaurant?*/
SELECT sa.customer_id,
       COUNT(DISTINCT(sa.order_date)) AS nr_visits
FROM dannys_diner.sales sa
GROUP BY sa.customer_id

/*Q3. What was the first item from the menu purchased by each customer?*/

SELECT k.customer_id, 
       m.product_name 
FROM 
	(SELECT * 
	FROM (SELECT *, 
			      ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) AS row_nr
		  FROM dannys_diner.sales)
	WHERE row_nr=1) k 
	LEFT JOIN dannys_diner.menu m ON k.product_id = m.product_id;

/*Q4. Most purchased item on the menu and the number of times it was purchased by all customers*/
SELECT TOP 1 sa.product_id,
       me.product_name,
       COUNT(sa.product_id) AS nr_orders
FROM dannys_diner.sales sa
LEFT JOIN dannys_diner.menu me ON sa.product_id=me.product_id
GROUP BY sa.product_id, me.product_name
ORDER BY nr_orders DESC

/*Q5. Which item was the most popular for each customer?*/

SELECT 
		s.customer_id, 
		m.product_name, 
		COUNT(m.product_id) AS order_count,
        DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.customer_id) DESC) AS prod_rank
FROM dannys_diner.menu AS m
JOIN dannys_diner.sales AS s ON m.product_id = s.product_id
GROUP BY s.customer_id, m.product_name

/*Q6. Which item was purchased first by the customer after they became a member?*/
SELECT  s.customer_id, 
		s.product_id, 
		s.order_date, 
		m.join_date,
		ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS row_n
FROM dannys_diner.sales s 
JOIN dannys_diner.members m ON s.customer_id = m.customer_id
WHERE s.order_date < m.join_date

/*Q7. Which item was purchased just before the customer became a member?*/

/*Q8. What is the total items and amount spent for each member before they became a member?*/
SELECT s.customer_id,
       COUNT(s.product_id) AS nr_items,
	   SUM(m.price) AS amount_spent
	   -- mm.join_date
FROM dannys_diner.sales s 
LEFT JOIN dannys_diner.menu m ON s.product_id=m.product_id
LEFT JOIN dannys_diner.members mm ON s.customer_id=mm.customer_id
WHERE mm.join_date>s.order_date
GROUP BY s.customer_id

/*Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?*/
SELECT
  sales.customer_id,
  SUM(CASE 
      WHEN menu.product_name = 'sushi ' THEN menu.price*10*2
      ELSE menu.price*10
	  END) AS points
FROM dannys_diner.sales
LEFT JOIN dannys_diner.menu ON sales.product_id = menu.product_id
GROUP BY sales.customer_id
ORDER BY points DESC

/*In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi 
- how many points do customer A and B have at the end of January?*/
SELECT
  sales.customer_id,
  SUM(
    CASE
    -- you may want to check this logic carefully!
      WHEN menu.product_name != 'sushi' THEN menu.price*20
      WHEN sales.order_date BETWEEN members.join_date AND DATEADD(day, 6, members.join_date) THEN menu.price*20
      END
      ) AS points
FROM dannys_diner.sales
LEFT JOIN dannys_diner.menu ON sales.product_id = menu.product_id
LEFT JOIN dannys_diner.members ON members.customer_id=sales.customer_id
WHERE sales.order_date = '2019-01-31'
GROUP BY sales.customer_id
ORDER BY points;