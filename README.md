# olist-ecommerce-customer-analytics
End-to-end e-commerce analytics project using PostgreSQL, Python and Power BI

SQL:
1. Table creation and csv import into pgAdmin:
    * **issue**: olist_order_reviews_dataset failed to import
    * **fix**: review_id was set to be primary key in table creation, but it's not an unique value; primary key requirement was excluded from table


2. Data cleaning:
   1. Row count check confirms all rows were imported sucessfuly.
   2. Unique value check for product_category_name vs. product_category_name_english
      * **issue**: there are two product_category_name values missing translation
      * **fix**: manual addition of two translation pairs into product_translation table
   3. Primary/foreign key checks highlights:
      * refactored initial approach (LEFT JOIN was used, changed to FULL OUTER JOIN)
      * validated data integrity between tables for product_id, order_id, customer_id, seller_id, zip_code_prefix
        * **issue** identified minor gaps for geolocation_zip_code_prefix - 0.002% of orders are impacted due to missing customer_zip_code_prefix from geolocation table and another 0.002% due to missing seller_zip_code_prefix
        * **fix** rows with missing information were retained as the statistical impact is negligible
   4. Null value checks highlights:
      * order_reviews:
        * **issue** many reviews with missing titles (88.34%) and messages (58.70%)
        * **fix** reviews with missing information were retained, for most of our analysis we will need the review_score  
      * orders:
        * **issue** missing dates in orders table - 0.01% are actual missing data (status "delivered" but no information in carrier_date and delivered_customer_date)
        * **fix** rows with missing information were retained as the statistical impact is negligible for general analysis
      * products:
        * **issue** 1.85% of products are missing key information (e.g. product_category_name)
   5. Duplicate value checks highlights:
      * duplicated review_id confirmed from prior finding - to be investigated

To be checked later:
- unavaliable order_status
- product_ids with missing product_category_name impact