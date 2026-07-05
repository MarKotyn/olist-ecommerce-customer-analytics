-- Create monthly sales view
-- one row = one month metrics

CREATE OR REPLACE VIEW vw_monthly_sales_summary AS
WITH orders_summary AS (
SELECT
	DATE_TRUNC('month', o.order_purchase_timestamp) AS purchase_month,
	o.order_id,
	o.order_status,
	c.customer_unique_id,
	ap.total_payment
FROM orders o
LEFT OUTER JOIN customers c
ON o.customer_id=c.customer_id
LEFT OUTER JOIN vw_aggregated_payments ap
ON o.order_id=ap.order_id
)

SELECT
	purchase_month,
	COUNT(order_id) AS total_orders,
	COUNT(DISTINCT customer_unique_id) AS total_customers,
	SUM(total_payment) AS total_revenue,
	ROUND(AVG(total_payment),2) AS avg_order_value,
	COUNT(order_id)/COUNT(DISTINCT customer_unique_id) AS avg_orders_per_customer,
	SUM(CASE WHEN order_status = 'canceled' THEN 1 ELSE 0 END) AS cancelled_orders,
	ROUND(100.00*SUM(CASE WHEN order_status = 'canceled' THEN 1 ELSE 0 END)/COUNT(order_id),2) AS cancellation_rate,
	SUM(CASE WHEN order_status = 'unavailable' THEN 1 ELSE 0 END) AS unavailable_orders,
	ROUND(100.00*SUM(CASE WHEN order_status = 'unavailable' THEN 1 ELSE 0 END)/COUNT(order_id),2) AS unavailable_rate
FROM orders_summary
GROUP BY purchase_month
ORDER BY purchase_month ASC;

-- Check vw_monthly_sales_summary
SELECT *
FROM vw_monthly_sales_summary;