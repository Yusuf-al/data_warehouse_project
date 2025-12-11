SELECT
    ---Dimentions
    sl.sls_ord_num as order_number ,
    pd.product_key as product_key,
    cm.customer_key as customer_key,
    --- Dates
    sl.sls_order_dt as order_date,
    sl.sls_ship_dt  as shipping_date,
    sl.sls_due_dt as due_date,
    
    --- Measures
    sl.sls_price as price,
    sl.sls_quantity as quantity,
    sl.sls_sales as total_sales 
FROM silver.crm_sales_details as sl
LEFT JOIN gold.dim_products as pd
ON sl.sls_prd_key = pd.product_number
LEFT JOIN gold.dim_customers as cm 
ON sl.sls_cust_id = cm.customer_id
ORDER BY cm.customer_key
-- LEFT JOIN silver.crm_prd_info as pd 
-- ON sl.sls_prd_key = pd.prd_key
-- LEFT JOIN silver.crm_cst_info as ci 
-- ON sl.sls_cust_id = ci.cst_id

SELECT * FROM gold.dim_products
SELECT * FROM gold.dim_customers
SELECT * FROM silver.crm_sales_details

SELECT * FROM gold.fact_sales_details WHERE order_date IS NOT NULL