-- Create delivery summary view
CREATE OR REPLACE VIEW vw_delivery_summary AS
SELECT
	DATE_TRUNC('month', order_purchase_timestamp) AS order_month,
	COUNT(order_id) AS completed_orders,
	ROUND(AVG(order_delivered_customer_date::date - order_purchase_timestamp::date),0) AS avg_delivery_days,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY order_delivered_customer_date::date - order_purchase_timestamp::date) AS median_delivery_days,
	ROUND(AVG(order_approved_at::date - order_purchase_timestamp::date),0) AS avg_processing_days,
	ROUND(AVG(order_delivered_customer_date::date - order_delivered_carrier_date::date),0) AS avg_shipping_days,
	SUM(CASE WHEN order_delivered_customer_date::date <= order_estimated_delivery_date::date THEN 1 ELSE 0 END) AS on_time_orders,
	SUM(CASE WHEN order_delivered_customer_date::date > order_estimated_delivery_date ::date THEN 1 ELSE 0 END) AS late_orders,
	ROUND(100.00*SUM(CASE WHEN order_delivered_customer_date::date <= order_estimated_delivery_date::date THEN 1 ELSE 0 END)/COUNT(order_id),2) AS on_time_rate,
	ROUND(AVG(order_delivered_customer_date::date - order_estimated_delivery_date::date),0) AS avg_estimation_error
FROM orders
WHERE order_status = 'delivered'
GROUP BY DATE_TRUNC('month', order_purchase_timestamp);

-- Check vw_deliver_summary
SELECT *
FROM vw_delivery_summary;