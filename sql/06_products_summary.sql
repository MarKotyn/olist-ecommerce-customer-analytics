-- Create products view 
CREATE OR REPLACE VIEW vw_products_summary AS
WITH products_english AS (
SELECT
	p.product_id,
	COALESCE(pt.product_category_name_english, 'unknown') AS product_category_name
FROM products p
LEFT OUTER JOIN product_translation pt
ON p.product_category_name=pt.product_category_name
),

products_summary AS (
SELECT
	pe.product_id,
	pe.product_category_name,
	oi.order_id,
	oi.order_item_id,
	oi.price,
	oi.freight_value,
	o.order_status
FROM products_english pe
LEFT OUTER JOIN order_items oi
ON pe.product_id=oi.product_id
LEFT OUTER JOIN orders o
ON oi.order_id=o.order_id
WHERE o.order_status NOT IN ('canceled','unavailable')
)

SELECT
	product_category_name,
	COUNT(DISTINCT order_id) AS total_orders,
	COUNT(*) AS products_sold,
	SUM(price) AS total_revenue,
	ROUND(AVG(price),2) AS avg_product_price,
	SUM(freight_value) AS total_freight,
	ROUND(AVG(freight_value),2) AS avg_freight
FROM products_summary
GROUP BY product_category_name;

-- Check vw_products_summary
SELECT *
FROM vw_products_summary;