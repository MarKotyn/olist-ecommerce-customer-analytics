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