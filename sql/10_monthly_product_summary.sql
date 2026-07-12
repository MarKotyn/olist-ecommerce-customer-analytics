CREATE OR REPLACE VIEW vw_monthly_product_summary AS
WITH products_monthly_join AS (
SELECT
	DATE_TRUNC('month', o.order_purchase_timestamp) AS purchase_month,
	o.order_id,
	o.order_status,
	oi.price,
	oi.freight_value,
	pt.product_category_name_english AS product_category_name
FROM orders o
LEFT OUTER JOIN order_items oi
ON o.order_id = oi.order_id
LEFT OUTER JOIN products p
ON oi.product_id = p.product_id
LEFT OUTER JOIN product_translation pt
ON p.product_category_name = pt.product_category_name
WHERE o.order_status NOT IN ('canceled','unavailable')
)

SELECT
	purchase_month,
	product_category_name,
	COUNT(DISTINCT order_id) AS total_orders,
	COUNT(*) AS items_sold,
	SUM(price) AS total_revenue,
	ROUND(AVG(price),2) AS avg_product_price,
	SUM(freight_value) AS total_freight,
	ROUND(AVG(freight_value),2) AS avg_product_freight
FROM products_monthly_join
GROUP BY
	purchase_month,
	product_category_name;