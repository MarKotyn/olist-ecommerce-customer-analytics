-- Row count for all tables
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'geolocation', COUNT(*) FROM geolocation
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'order_reviews', COUNT (*) FROM order_reviews
UNION ALL
SELECT 'orders', COUNT (*) FROM orders
UNION ALL
SELECT 'product_translation', COUNT (*) FROM product_translation
UNION ALL
SELECT 'products', COUNT (*) FROM products
UNION ALL
SELECT 'sellers', COUNT (*) FROM sellers;

-- Check if all product_categories have translation in product_translation
SELECT 
	'category_name_products' AS source_name, 
	COUNT(DISTINCT(product_category_name)) AS products_unique_name FROM products
UNION ALL
SELECT 
	'translation', 
	COUNT(DISTINCT(product_category_name)) 
FROM product_translation;

-- Check which products don't have translation
SELECT 
	DISTINCT(p.product_category_name),
	product_category_name_english 
FROM products p
LEFT OUTER JOIN product_translation pt
ON p.product_category_name = pt.product_category_name
WHERE product_category_name_english IS NULL;

-- Manually insert missing translation into product_translation
INSERT INTO product_translation (product_category_name, product_category_name_english)
VALUES 
    ('pc_gamer', 'gaming_pc'),
    ('portateis_cozinha_e_preparadores_de_alimentos', 'kitchen_appliances_&_food_prep');

-- Double-check if now all products have traslations
SELECT 
	DISTINCT(p.product_category_name),
	product_category_name_english 
FROM products p
LEFT OUTER JOIN product_translation pt
ON p.product_category_name = pt.product_category_name
WHERE product_category_name_english IS NULL

-- Check if all product_ids in order_items exist in products
SELECT 
	oi.product_id, 
	p.product_id
FROM order_items oi
LEFT OUTER JOIN products p
ON oi.product_id=p.product_id
WHERE p.product_id IS NULL;

-- Check if all order_ids in order_items, order_payments and order_reviews exists in orders
SELECT 
	o.order_id, 
	oi.order_id AS items_order_id, 
	op.order_id AS payments_order_id, 
	ore.order_id AS reviews_order_id
FROM orders o
FULL OUTER JOIN order_items oi
ON o.order_id=oi.order_id
FULL OUTER JOIN order_payments op
ON o.order_id=op.order_id
FULL OUTER JOIN order_reviews ore
ON o.order_id=ore.order_id
WHERE o.order_id IS NULL;

-- Check if all customer_ids in orders exist in customers
SELECT 
	c.customer_id, 
	o.customer_id
FROM orders o
LEFT OUTER JOIN customers c
ON c.customer_id=o.customer_id
WHERE c.customer_id IS NULL;

-- Check if all seller_ids in order_items exist in sellers
SELECT 
	s.seller_id, 
	oi.seller_id
FROM order_items oi
LEFT OUTER JOIN sellers s
ON oi.seller_id=s.seller_id
WHERE s.seller_id IS NULL;

-- Check if all zip_code_prefixes in customers and sellers are in geolocation
SELECT 
	geolocation_zip_code_prefix, 
	customer_zip_code_prefix, 
	seller_zip_code_prefix
FROM geolocation
FULL OUTER JOIN customers
ON geolocation_zip_code_prefix=customer_zip_code_prefix
FULL OUTER JOIN sellers
ON geolocation_zip_code_prefix=seller_zip_code_prefix
WHERE geolocation_zip_code_prefix IS NULL;

-- Check the impact of missing customer_zip_codes based on orders
WITH missing_customer_zip_codes AS (
SELECT
	o.order_id,
	c.customer_zip_code_prefix,
	g.geolocation_zip_code_prefix
FROM orders o
LEFT OUTER JOIN customers c
ON o.customer_id=c.customer_id
LEFT OUTER JOIN geolocation g
ON c.customer_zip_code_prefix=g.geolocation_zip_code_prefix)

SELECT 
ROUND(100.00*SUM(CASE WHEN geolocation_zip_code_prefix IS NULL THEN 1 ELSE 0 END)/COUNT(*),3) AS orders_impacted
FROM missing_customer_zip_codes;

-- Check the impact of missing seller_zip_codes based on orders
WITH missing_seller_zip_codes AS (
SELECT
	oi.order_id,
	s.seller_zip_code_prefix,
	g.geolocation_zip_code_prefix
FROM order_items oi
LEFT OUTER JOIN sellers s
ON oi.seller_id=s.seller_id
LEFT OUTER JOIN geolocation g
ON s.seller_zip_code_prefix=g.geolocation_zip_code_prefix)

SELECT 
ROUND(100.00*SUM(CASE WHEN geolocation_zip_code_prefix IS NULL THEN 1 ELSE 0 END)/COUNT(*),3) AS orders_impacted
FROM missing_seller_zip_codes;

-- Null values in customers table
SELECT
	COUNT(*) AS total_rows,
	SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_null,
	SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END) AS customer_unique_id_null,
	SUM(CASE WHEN customer_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS customer_zip_code_prefix_null,
	SUM(CASE WHEN customer_city IS NULL THEN 1 ELSE 0 END) AS customer_city_null,
	SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS customer_state_null
FROM customers;

-- Null values in geoloctaion table
SELECT
	COUNT(*) AS total_rows,
	SUM(CASE WHEN geolocation_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS geolocation_zip_code_prefix_null,
	SUM(CASE WHEN geolocation_lat IS NULL THEN 1 ELSE 0 END) AS geolocation_lat_null,
	SUM(CASE WHEN geolocation_lng IS NULL THEN 1 ELSE 0 END) AS geolocation_lng_null,
	SUM(CASE WHEN geolocation_city IS NULL THEN 1 ELSE 0 END) AS geolocation_city_null,
	SUM(CASE WHEN geolocation_state IS NULL THEN 1 ELSE 0 END) AS geolocation_state_null
FROM geolocation;

-- Null values in order_items table
SELECT
	COUNT(*) AS total_rows,
	SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_null,
	SUM(CASE WHEN order_item_id IS NULL THEN 1 ELSE 0 END) AS order_item_id_null,
	SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_null,
	SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS seller_id_null,
	SUM(CASE WHEN shipping_limit_date IS NULL THEN 1 ELSE 0 END) AS shipping_limit_date_null,
	SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS price_null,
	SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS freight_value_null
FROM order_items;

-- Null values in order_payments table
SELECT
	COUNT(*) AS total_rows,
	SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_null,
	SUM(CASE WHEN payment_sequential IS NULL THEN 1 ELSE 0 END) AS payment_sequential_null,
	SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS payment_type_null,
	SUM(CASE WHEN payment_installments IS NULL THEN 1 ELSE 0 END) AS payment_installments_null,
	SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS payment_value_null
FROM order_payments;

-- Null values in order_reviews table
SELECT
	COUNT(*) AS total_rows,
	SUM(CASE WHEN review_id IS NULL THEN 1 ELSE 0 END) AS review_id_null,
	SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_null,
	SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS review_score_null,
	SUM(CASE WHEN review_comment_title IS NULL THEN 1 ELSE 0 END) AS review_comment_title_null,
	SUM(CASE WHEN review_comment_message IS NULL THEN 1 ELSE 0 END) AS review_comment_message_null,
	SUM(CASE WHEN review_creation_date IS NULL THEN 1 ELSE 0 END) AS review_creation_date_null,
	SUM(CASE WHEN review_answer_date IS NULL THEN 1 ELSE 0 END) AS review_answer_date_null
FROM order_reviews;

-- How many incomplete reviews do we have in comparison to complete reviews?
SELECT
	ROUND(100.00*SUM(CASE WHEN review_comment_title IS NULL THEN 1 ELSE 0 END)/COUNT(*),2) AS missing_review_titles,
	ROUND(100.00*SUM(CASE WHEN review_comment_message IS NULL THEN 1 ELSE 0 END)/COUNT(*),2) AS missing_review_messages
FROM order_reviews;

-- Null values in orders table
SELECT
	COUNT(*) AS total_rows,
	SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_null,
	SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_null,
	SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS order_status_null,
	SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS order_purchase_timestamp_null,
	SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS order_delivered_carrier_date_null,
	SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS order_delivered_customer_date_null,
	SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS order_estimated_delivery_date_null
FROM orders;

-- Investigation of missing dates in orders table based on order_status
SELECT
	order_status,
	ROUND(100.00*order_delivered_carrier_date_null/total_orders,3) AS missing_carrier_dates,
	ROUND(100.00*order_delivered_customer_date_null/total_orders,3) AS missing_delivered_dates
FROM
(SELECT 
    order_status,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS order_delivered_carrier_date_null,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS order_delivered_customer_date_null
FROM orders
GROUP BY order_status
) AS orders_missing_dates
WHERE order_status = 'delivered'

-- Null values in products table
SELECT
	COUNT(*) AS total_rows,
	SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_null,
	SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS product_category_name_null,
	SUM(CASE WHEN product_name_length IS NULL THEN 1 ELSE 0 END) AS product_name_length_null,
	SUM(CASE WHEN product_description_length IS NULL THEN 1 ELSE 0 END) AS product_description_length_null,
	SUM(CASE WHEN product_photo_qty IS NULL THEN 1 ELSE 0 END) AS product_photo_qty_null,
	SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS product_weight_g_null,
	SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) AS product_length_cm_null,
	SUM(CASE WHEN product_height_cm IS NULL THEN 1 ELSE 0 END) AS product_height_cm_null,
	SUM(CASE WHEN product_width_cm IS NULL THEN 1 ELSE 0 END) AS product_width_cm_null
FROM products;

-- Products null values investigation
SELECT *
FROM products
WHERE product_category_name IS NULL;

SELECT *
FROM products
WHERE product_height_cm IS NULL;

SELECT
	ROUND(100.00*SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END)/COUNT(*),2) AS missing_products
FROM products;

-- Null values in sellers table
SELECT
	COUNT(*) AS total_rows,
	SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS seller_id_null,
	SUM(CASE WHEN seller_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS seller_zip_code_prefix_null,
	SUM(CASE WHEN seller_city IS NULL THEN 1 ELSE 0 END) AS seller_city_null,
	SUM(CASE WHEN seller_state IS NULL THEN 1 ELSE 0 END) AS pseller_state_null
FROM sellers;

-- Duplicates in customers table: customer_unique_id
SELECT
    customer_unique_id,
    COUNT(customer_id) AS customer_records

FROM customers
GROUP BY customer_unique_id
HAVING COUNT(customer_id) > 1;

SELECT
	customer_id,
	COUNT(order_id) AS orders_per_cust
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) >1;

-- Duplicates in geolocation table
SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state,
    COUNT(*) AS duplicate_count
FROM geolocation
GROUP BY
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
HAVING COUNT(*)>1;

-- Investigation of duplicates in geolocation table
WITH geolocation_with_duplicates AS (
SELECT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state,
    COUNT(*) AS duplicate_count
FROM geolocation
GROUP BY
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
)
SELECT
	SUM(duplicate_count) AS total_rows,
	SUM(duplicate_count - 1) AS rows_to_clean,
	ROUND(100.00*SUM(duplicate_count - 1)/SUM(duplicate_count),2) AS pct_of_rows_to_clean
FROM geolocation_with_duplicates;

-- Create new geolocation table without duplicates
CREATE TABLE geolocation_cleaned AS
SELECT 
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
FROM geolocation
GROUP BY 
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state;

-- Change name of geolocation table with duplicates
ALTER TABLE geolocation RENAME TO geolocation_old;

-- Change name of new geolocation table
ALTER TABLE geolocation_cleaned RENAME TO geolocation;

-- Duplicates in order_item table
SELECT 
    order_id, 
    order_item_id, 
    COUNT(*) AS duplicate_count
FROM 
    order_items
GROUP BY 
    order_id, 
    order_item_id
HAVING 
    COUNT(*) > 1;

-- Duplicates in order_payments table
SELECT 
    order_id, 
    payment_sequential, 
    COUNT(*) AS duplicate_count
FROM 
    order_payments
GROUP BY 
    order_id, 
    payment_sequential
HAVING 
    COUNT(*) > 1;

-- Duplicates in order_reviews table
SELECT 
    review_id, 
    COUNT(*) AS duplicate_count
FROM order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1;

-- Investigation of duplicates in order_reviews table
SELECT 
    review_id,
	order_id,
    COUNT(*) AS duplicate_count
FROM order_reviews
GROUP BY 
	review_id,
	order_id
HAVING COUNT(*) > 1;

SELECT 
    review_id,
	review_score,
	review_comment_title,
	review_comment_message,
	review_creation_date,
	review_answer_date,
    COUNT(*) AS duplicate_count
FROM order_reviews
GROUP BY 
	review_id,
	review_score,
	review_comment_title,
	review_comment_message,
	review_creation_date,
	review_answer_date
HAVING COUNT(*) > 1;

-- Check if same customers are making those reviews
WITH review_to_customer_map AS (
SELECT
	ore.review_id,
	ore.review_score,
	ore.review_comment_title,
	ore.review_comment_message,
	c.customer_unique_id
FROM order_reviews ore
LEFT JOIN orders o
ON ore.order_id = o.order_id
LEFT JOIN customers c
ON o.customer_id=c.customer_id
)

SELECT
	customer_unique_id,
	review_id,
	review_score,
	review_comment_title,
	review_comment_message,
	COUNT(*) AS duplicate_count
FROM review_to_customer_map
GROUP BY
	customer_unique_id,
	review_id,
	review_score,
	review_comment_title,
	review_comment_message
HAVING COUNT(*)>1;

-- Check if those reviews are due to multiple order_items in one order
WITH review_to_items_map AS (
SELECT
	ore.review_id,
	ore.review_score,
	ore.review_comment_title,
	ore.review_comment_message,
	oi.order_id,
	oi.order_item_id
FROM order_reviews ore
LEFT JOIN order_items oi
ON ore.order_id = oi.order_id
)

SELECT
	review_id,
	review_score,
	review_comment_title,
	review_comment_message
	order_id,
	COUNT(order_item_id) AS items_in_order,
	COUNT(*) AS duplicate_count,
	CASE WHEN COUNT(order_item_id) = COUNT(*) THEN 1 ELSE 0 END
FROM review_to_items_map
GROUP BY
	review_id,
	review_score,
	review_comment_title,
	review_comment_message,
	order_id
HAVING COUNT(*)>1 AND CASE WHEN COUNT(order_item_id) = COUNT(*) THEN 1 ELSE 0 END = 0;

-- Investigate all reviews for orders that don't exist in order_items
WITH incorrect_reviews AS (
SELECT
	ore.review_id,
	ore.order_id,
	oi.order_id,
	o.order_status
FROM order_reviews ore
LEFT OUTER JOIN order_items oi
ON ore.order_id=oi.order_id
LEFT OUTER JOIN orders o
ON ore.order_id=o.order_id
WHERE oi.order_id IS NULL
)

SELECT
	order_status,
	COUNT(review_id)
FROM incorrect_reviews
GROUP BY order_status;

