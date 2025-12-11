SELECT 
    age_group,
    customer_segment,
    COUNT(customer_number) as total_customer,
    SUM(total_sales) as total_sales_by_age_group
    FROM gold.report_customers
GROUP BY age_group,customer_segment

