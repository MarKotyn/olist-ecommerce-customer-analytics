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
SELECT 'category_name_products' AS source_name, COUNT(DISTINCT(product_category_name)) AS products_unique_name FROM products
UNION ALL
SELECT 'translation', COUNT(DISTINCT(product_category_name)) FROM product_translation;

-- Check which products don't have translation
SELECT DISTINCT(p.product_category_name),product_category_name_english FROM products p
LEFT OUTER JOIN product_translation pt
ON p.product_category_name = pt.product_category_name
WHERE product_category_name_english IS NULL;

-- Manually insert missing translation into product_translation
INSERT INTO product_translation (product_category_name, product_category_name_english)
VALUES 
    ('pc_gamer', 'gaming_pc'),
    ('portateis_cozinha_e_preparadores_de_alimentos', 'kitchen_appliances_&_food_prep');

-- Double-check if now all products have traslations
SELECT DISTINCT(p.product_category_name),product_category_name_english FROM products p
LEFT OUTER JOIN product_translation pt
ON p.product_category_name = pt.product_category_name
WHERE product_category_name_english IS NULL

-- Check if all product_ids in order_items exist in products
SELECT oi.product_id, p.product_id
FROM order_items oi
LEFT OUTER JOIN products p
ON oi.product_id=p.product_id
WHERE p.product_id IS NULL;

-- Check if all order_ids in order_items, order_payments and order_reviews exists in orders
SELECT  o.order_id, oi.order_id AS items_order_id, op.order_id AS payments_order_id, ore.order_id AS reviews_order_id
FROM orders o
LEFT OUTER JOIN order_items oi
ON o.order_id=oi.order_id
LEFT OUTER JOIN order_payments op
ON o.order_id=op.order_id
LEFT OUTER JOIN order_reviews ore
ON o.order_id=ore.order_id
WHERE o.order_id IS NULL;

-- Check if all customer_ids in orders exist in customers
SELECT c.customer_id, o.customer_id
FROM customers c
LEFT OUTER JOIN orders o
ON c.customer_id=o.customer_id
WHERE c.customer_id IS NULL;

-- Check if all zip_code_prefixes in customers and sellers are in geolocation
SELECT geolocation_zip_code_prefix, customer_zip_code_prefix, seller_zip_code_prefix
FROM geolocation
LEFT OUTER JOIN customers
ON geolocation_zip_code_prefix=customer_zip_code_prefix
LEFT OUTER JOIN sellers
ON geolocation_zip_code_prefix=seller_zip_code_prefix
WHERE geolocation_zip_code_prefix IS NULL

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
GROUP BY order_status) AS orders_missing_dates
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

-- Duplicates in lookup tables: customers
WITH duplicate_check AS (
    SELECT 
        *,
        ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY customer_id) AS row_num
    FROM 
        customers
)
SELECT * FROM duplicate_check 
WHERE row_num > 1;

-- Duplicates in lookup tables: products
WITH duplicate_check AS (
    SELECT 
        *,
        ROW_NUMBER() OVER(PARTITION BY product_id ORDER BY product_id) AS row_num
    FROM 
        products
)
SELECT * FROM duplicate_check 
WHERE row_num > 1;

-- Duplicates in lookup tables: sellers
WITH duplicate_check AS (
    SELECT 
        *,
        ROW_NUMBER() OVER(PARTITION BY seller_id ORDER BY seller_id) AS row_num
    FROM 
        sellers
)
SELECT * FROM duplicate_check 
WHERE row_num > 1;

-- Duplicates in lookup tables: reviews
WITH duplicate_check AS (
    SELECT 
        *,
        ROW_NUMBER() OVER(PARTITION BY review_id ORDER BY review_id) AS row_num
    FROM 
        order_reviews
)
SELECT * FROM duplicate_check 
WHERE row_num > 1;
