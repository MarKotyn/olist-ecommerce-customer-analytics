# List of DAX Measures

---
## KPI Measures

### 1. Total Revenue 
= SUM(fct_MonthlySales[total_revenue])

### 2. Total Orders 
= SUM(fct_MonthlySales[total_orders])

### 3. Unique Customers 
= DISTINCTCOUNT(fct_CustomerActivity[customer_unique_id])

### 4. Average Revenue per Customer 
= 'KPI Measures'[Total Revenue]/'KPI Measures'[Unique Customers]

### 5. Average Order Value 
= 'KPI Measures'[Total Revenue]/'KPI Measures'[Total Orders]

### 6. Failed Orders 
= SUM(fct_MonthlySales[cancelled_orders])+SUM(fct_MonthlySales[unavailable_orders])

### 7. Failed Order Rate 
= 'KPI Measures'[Failed Orders]/'KPI Measures'[Total Orders]

---
## Specific Measures

### 8. Repeat Customers 
= COALESCE(CALCULATE(COUNTROWS(dim_Customer), dim_Customer[total_orders] > 1), 0)

### 9. Repeat Customer Rate 
= DIVIDE([Repeat Customers], [Unique Customers], 0)

### 10. On Time Orders 
= SUM(fct_Delivery[on_time_orders])

### 11. On Time Rate 
= 'Specific Measures'[On Time Orders]/SUM(fct_Delivery[completed_orders])

### 12. Late Orders 
= SUM(fct_Delivery[late_orders])

### 13. Late Rate 
= 'Specific Measures'[Late Orders]/SUM(fct_Delivery[completed_orders])

### 14. Average Review Score 
= AVERAGE(fct_OrderReviews[review_score])

### 15. 5-Star Review Rate 
= DIVIDE(CALCULATE(COUNTROWS(fct_OrderReviews), fct_OrderReviews[review_score] = 5), COUNTROWS(fct_OrderReviews))

### 16. Average Delivery Days 
= DIVIDE(SUMX(fct_Delivery, fct_Delivery[avg_delivery_days] * fct_Delivery[completed_orders]), SUM(fct_Delivery[completed_orders]))

### 17. Average Processing Days 
= DIVIDE(SUMX(fct_Delivery, fct_Delivery[avg_processing_days] * fct_Delivery[completed_orders]), SUM(fct_Delivery[completed_orders]))

---
## Time Intelligence

### 18. Revenue Previous Month 
= CALCULATE([Total Revenue], PREVIOUSMONTH(dim_Calendar[Date]))

### 19. Revenue MoM % 
= DIVIDE([Total Revenue] - [Revenue Previous Month], [Revenue Previous Month])

### 20. Revenue YTD 
= TOTALYTD([Total Revenue], dim_Calendar[Date])
