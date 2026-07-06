-- olist_customer_dataset table
CREATE TABLE IF NOT EXISTS customers (
	customer_id VARCHAR PRIMARY KEY,
	customer_unique_id VARCHAR,
    customer_zip_code_prefix INT,
    customer_city VARCHAR,
    customer_state VARCHAR
);

-- olist_geolocation_dataset
CREATE TABLE IF NOT EXISTS geolocation (
	geolocation_zip_code_prefix INT,
	geolocation_lat FLOAT,
	geolocation_lng FLOAT,
	geolocation_city VARCHAR,
	geolocation_state VARCHAR
);

-- olist_order_items_dataset
CREATE TABLE IF NOT EXISTS order_items (
	order_id VARCHAR,
	order_item_id INT,
	product_id VARCHAR,
	seller_id VARCHAR,
	shipping_limit_date TIMESTAMP,
	price NUMERIC(10, 2),
	freight_value NUMERIC(10, 2)
);

-- olist_order_payments_dataset
CREATE TABLE IF NOT EXISTS order_payments (
	order_id VARCHAR,
	payment_sequential INT,
	payment_type VARCHAR,
	payment_installments INT,
	payment_value NUMERIC(10, 2)
);

-- olist_order_reviews_dataset
CREATE TABLE IF NOT EXISTS order_reviews (
	review_id VARCHAR,
	order_id VARCHAR,
	review_score INT,
	review_comment_title VARCHAR,
	review_comment_message VARCHAR,
	review_creation_date TIMESTAMP,
	review_answer_date TIMESTAMP
);

-- olist_orders_dataset
CREATE TABLE IF NOT EXISTS orders (
	order_id VARCHAR PRIMARY KEY,
	customer_id VARCHAR,
	order_status VARCHAR,
	order_purchase_timestamp TIMESTAMP,
	order_approved_at TIMESTAMP,
	order_delivered_carrier_date TIMESTAMP,
	order_delivered_customer_date TIMESTAMP,
	order_estimated_delivery_date TIMESTAMP
);

-- olist_products_dataset
CREATE TABLE IF NOT EXISTS products (
	product_id VARCHAR PRIMARY KEY,
	product_category_name VARCHAR,
	product_name_length INT,
	product_description_length INT,
	product_photo_qty INT,
	product_weight_g INT,
	product_length_cm INT,
	product_height_cm INT,
	product_width_cm INT
);

-- olist_sellers_dataset
CREATE TABLE IF NOT EXISTS sellers (
	seller_id VARCHAR PRIMARY KEY,
	seller_zip_code_prefix INT,
	seller_city VARCHAR,
	seller_state VARCHAR
);

-- olist_product_category_name_translation_dataset
CREATE TABLE IF NOT EXISTS product_translation (
	product_category_name VARCHAR,
	product_category_name_english VARCHAR
);
