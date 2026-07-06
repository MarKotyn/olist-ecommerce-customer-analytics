-- Create order review summary view
-- one row = one order review

CREATE OR REPLACE VIEW vw_order_review_summary AS
WITH review_summary_join AS (
SELECT
	ore.review_id,
	ore.order_id,
	ore.review_score,
	o.order_status,
	o.order_purchase_timestamp,
	o.order_delivered_customer_date,
	o.order_estimated_delivery_date,
	c.customer_unique_id
FROM order_reviews ore
LEFT OUTER JOIN orders o
ON ore.order_id = o.order_id
LEFT OUTER JOIN customers c
ON o.customer_id = c.customer_id
)

SELECT
	review_id,
	order_id,
	customer_unique_id,
	review_score,
	CASE WHEN review_score >= 4 THEN 'Positive' WHEN review_score = 3 THEN 'Neutral' ELSE 'Negative' END AS review_sentiment,
	order_status,
	CASE WHEN order_status NOT IN ('canceled', 'unavailable') THEN TRUE ELSE FALSE END AS successful_order,
	DATE_TRUNC('month', order_purchase_timestamp) AS purchase_month,
	CASE WHEN order_delivered_customer_date IS NULL THEN NULL ELSE order_delivered_customer_date::date - order_purchase_timestamp::date END AS delivery_days,
	CASE WHEN order_delivered_customer_date IS NULL THEN NULL ELSE order_delivered_customer_date::date - order_estimated_delivery_date::date END AS delivery_delay_days,
	CASE WHEN order_delivered_customer_date IS NULL THEN NULL WHEN order_delivered_customer_date::date <= order_estimated_delivery_date::date THEN FALSE ELSE TRUE END AS is_late_delivery
FROM review_summary_join;

SELECT *
FROM vw_order_review_summary;