SELECT * FROM customer_shopping LIMIT 20;

-- Total revenue by gender
SELECT gender, SUM(purchase_amount) as revenue
FROM customer_shopping
GROUP BY gender;

-- which customers used a discount but still spent more than the avg purchse amount
SELECT customer_id, purchase_amount
FROM customer_shopping
WHERE discount_applied = 'Yes' AND purchase_amount >= (SELECT AVG(purchase_amount) FROM customer_shopping);

-- Which are the top 5 product with highest average review rating
SELECT item_purchased, ROUND(avg(review_rating),2) as average_rating
FROM customer_shopping
GROUP BY item_purchased
ORDER BY avg(review_rating) DESC
LIMIT 5;

-- compare the avarage purchase amounts between standard and ecpress shipping
SELECT shipping_type, ROUND(avg(purchase_amount),2) as avg_amount
FROM customer_shopping
WHERE shipping_type in ('Standard' , 'Express')
GROUP BY shipping_type;

-- do subcribed customers spend more? Compare avg spend and total revenue btw subcribers and non subscriber
SELECT subscription_status,
COUNT(customer_id) as total_customer,
round(avg(purchase_amount),2) as avg_spend,
SUM(purchase_amount) as total_revenue
FROM customer_shopping
GROUP BY subscription_status
ORDER BY total_revenue,avg_spend DESC;

-- which 5 products rely highly on discounts
SELECT item_purchased,
ROUND(100 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)/Count(*),2) as discount_rate
from customer_shopping
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;

-- segment customers into new, returing, loyal based on their total no. of previous purchases and show the count of each segment
WITH customer_type as(
SELECT customer_id,previous_purchases,
CASE
	WHEN previous_purchases = 1 THEN 'New'
    WHEN previous_purchases BETWEEN 2 and 10 THEN 'Returning'
    ELSE 'Loyal'
    END as customer_segment
FROM customer_shopping
)
SELECT customer_segment, COUNT(*) as 'Number of Customers'
FROM customer_type
GROUP BY customer_segment;

WITH item_counts AS (
    SELECT
        category,
        item_purchased,
        COUNT(customer_id) AS total_orders,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY COUNT(customer_id) DESC
        ) AS item_rank
    FROM customer_shopping
    GROUP BY category, item_purchased
)

SELECT
    category,
    item_purchased,
    total_orders
FROM item_counts
WHERE item_rank <= 3
ORDER BY category, item_rank;

-- are customer who are repeat buyers are also loyal buyers
SELECT subscription_status,
count(customer_id) as repeat_buyers
FROM customer_shopping
WHERE previous_purchases > 5
GROUP BY subscription_status;

-- what is the revenue contributions of each age group
SELECT age_group,
SUM(purchase_amount) as total_revenue
FROM customer_shopping
GROUP BY age_group
ORDER BY total_revenue DESC;