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
   3. Further checks reveal no additional key discrepancies within dataset.