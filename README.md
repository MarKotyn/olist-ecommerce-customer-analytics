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
        * **fix** rows missing information were retained as the statistical impact is negligible for general analysis
      * products:
        * **issue** 1.85% of products are missing key information (e.g. product_category_name)
   5. Duplicate value checks highlights:
      * customers: while customer_id is set as primary key, we also have customer_unique_id where we have duplicates; however, it's not a duplicate issue since based on additional check in orders table system is generating new customer_id for each new order_id; customer_unique_id will be used later for client retention analysis
      * geolocation: since we have no primary key and no apparent candidate validation was run on whole rows
        * **issue** it was found that 26.18% of rows are duplicated
        * **fix** to eliminate technical redundancy and optimize database size, new geolocation table was created; identical rows were aggregated using `GROUP BY` filter over all columns into a new structure. The old table was safely archived, and new dataset was promoted to the primary `geolocation` table.
      * order_items: check validated that there are no duplicated order_item_ids within each order_id
      * order_payments: check validated that there are no duplicated payment_sequential within each order_id
        * **Payment Types Note**: The dataset includes `boleto` as a payment method. According to investigation, *Boleto Bancário* is a widely used Brazilian push-payment method regulated by the Central Bank, functioning similarly to a bank invoice or cash payment. This field is kept in its original name to preserve financial context for further analysis
      * order_reviews: duplicated review_id confirmed in table creation, impact 0.8% of all reviews; interestingly there are no duplicates when grouping by review_id and order_id, which would signal that duplicate reviews are generated for different orders, however by grouping by all columns except order_id we still get duplicates
        * **issue** duplicated review_id that have exactly the same values for all columns except order_id
        * **fix** almost all of those are duplicated due to '1-to-many' relationship, where a single review row is replicated for each individual item within that multi-item order
          * **sub-issue** method revealed that there are reviews for order_ids that don't exist in order_items table, further investigation revealed that there is 759 review records for orders that don't exist in order_items
          * **fix** cross reference with orders and order_status revealed that 99.4% of those are either unavaliable or canceled; meaning that system was sending review request without confirmation if the order was approved
          * **edge cases** within 0.6% order_status is 'created', 'invoiced' and 'shipped' pointing at technical system bug; however it's 0.006% of all reviews, so the impact is negligible 


To be checked later:
- unavaliable order_status
- product_ids with missing product_category_name impact
