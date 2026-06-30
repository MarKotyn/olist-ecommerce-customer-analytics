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