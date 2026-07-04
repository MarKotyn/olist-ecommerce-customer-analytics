-- Aggregated payments for multiple views
CREATE OR REPLACE VIEW aggregated_payments AS
SELECT
	order_id,
	SUM(payment_value) AS total_payment
FROM order_payments
GROUP BY
	order_id;

-- Customer summary view
CREATE OR REPLACE VIEW vw_customer_summary AS
WITH customer_summary_join AS (
SELECT
	c.customer_unique_id,
	c.customer_id,
	c.customer_city,
	c.customer_state,
	o.order_id,
	o.order_purchase_timestamp,
	o.order_status,
	ap.total_payment
FROM customers c
LEFT OUTER JOIN orders o
ON c.customer_id = o.customer_id
LEFT OUTER JOIN aggregated_payments ap
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
	SUM(CASE WHEN order_status IN ('canceled','unavailable') THEN 1 ELSE 0 END) AS failed_orders,
	SUM(CASE WHEN order_status NOT IN ('canceled','unavailable') THEN total_payment END) AS total_spent,
	ROUND(AVG(CASE WHEN order_status NOT IN ('canceled','unavailable') THEN total_payment END)::numeric,2) AS avg_order_value
FROM customer_summary_join
GROUP BY
	customer_unique_id,
	customer_city,
	customer_state;

-- Validate vw_customer_summary
SELECT
	COUNT(*),
	COUNT(DISTINCT customer_unique_id)
FROM customers;

SELECT
	COUNT(*),
	COUNT(DISTINCT customer_unique_id)
FROM vw_customer_summary;

-- Multiple customer_unique_id in vw_customer_summary, customers changed location between purchases
-- Decision was made to create two separate view, original will be used in PBI and for python we will create view with latest city and state

-- Rename original customer_summary view
ALTER VIEW vw_customer_summary RENAME TO vw_customer_summary_powerbi;