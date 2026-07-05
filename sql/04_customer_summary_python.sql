-- Create new customer_summary view for python
-- one row = one customer_unique_id (with latest used address)

CREATE OR REPLACE VIEW vw_customer_summary_python AS
WITH customer_address_join AS (
SELECT
	c.customer_unique_id,
	c.customer_city,
	c.customer_state,
	o.order_purchase_timestamp,
	ROW_NUMBER() OVER(PARTITION BY c.customer_unique_id ORDER BY o.order_purchase_timestamp DESC) AS latest_address
FROM customers c
LEFT OUTER JOIN orders o
ON c.customer_id = o.customer_id
),

address_mapping AS (
SELECT 
	customer_unique_id,
	customer_city,
	customer_state
FROM customer_address_join
WHERE latest_address = 1
),

customer_summary_join AS (
SELECT
	c.customer_unique_id,
	c.customer_id,
	am.customer_city,
	am.customer_state,
	o.order_id,
	o.order_purchase_timestamp,
	CASE WHEN o.order_status NOT IN ('canceled','unavailable') THEN TRUE ELSE FALSE END AS valid_order,
	ap.total_payment
FROM customers c
LEFT OUTER JOIN address_mapping am
ON c.customer_unique_id=am.customer_unique_id
LEFT OUTER JOIN orders o
ON c.customer_id = o.customer_id
LEFT OUTER JOIN vw_aggregated_payments ap
ON o.order_id = ap.order_id
)

SELECT
	customer_unique_id,
	customer_city,
	customer_state,
	MIN(order_purchase_timestamp) AS first_purchase_date,
	DATE_TRUNC('month', MIN(order_purchase_timestamp)) AS first_purchase_month,
	MAX(order_purchase_timestamp) AS last_purchase_date,
	MAX(order_purchase_timestamp)::date - MIN(order_purchase_timestamp)::date AS customer_tenure_days,
	COUNT(DISTINCT order_id) AS total_orders,
	SUM(CASE WHEN valid_order THEN 0 ELSE 1 END) AS failed_orders,
	SUM(CASE WHEN valid_order THEN total_payment END) AS total_spent,
	ROUND(AVG(CASE WHEN valid_order THEN total_payment END)::numeric,2) AS avg_order_value
FROM customer_summary_join
GROUP BY 
	customer_unique_id,
	customer_city,
	customer_state;

-- Check vw_customer_summary_python
SELECT *
FROM vw_customer_summary_python;
