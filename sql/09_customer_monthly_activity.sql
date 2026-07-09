CREATE OR REPLACE VIEW vw_customer_monthly_activity AS
WITH customer_monthly_activity AS (
SELECT
	c.customer_unique_id,
	o.order_id,
	DATE_TRUNC('month', o.order_purchase_timestamp)::date AS purchase_month,
	MIN(DATE_TRUNC('month', o.order_purchase_timestamp)::date) OVER (PARTITION BY c.customer_unique_id) AS cohort_month,
	ap.total_payment
FROM customers c
LEFT OUTER JOIN orders o
ON c.customer_id = o.customer_id
LEFT OUTER JOIN vw_aggregated_payments ap
ON o.order_id = ap.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
)

SELECT
    customer_unique_id,
    cohort_month,
    purchase_month,
    ((EXTRACT(YEAR FROM purchase_month) - EXTRACT(YEAR FROM cohort_month)) * 12+(EXTRACT(MONTH FROM purchase_month) - EXTRACT(MONTH FROM cohort_month))) AS cohort_index,
    COUNT(DISTINCT order_id) AS orders_in_month,
    SUM(total_payment) AS revenue_in_month
FROM customer_monthly_activity
GROUP BY
    customer_unique_id,
    cohort_month,
    purchase_month;