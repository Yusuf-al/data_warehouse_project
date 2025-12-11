-- Clear existing data from the silver layer sales table for fresh load
TRUNCATE TABLE silver.crm_sales_details

PRINT 'INSERTING SALES DEAILS IN SILVER LAYER TABLE'

-- Insert transformed sales data with data quality improvements
INSERT INTO silver.crm_sales_details(
    sls_ord_num ,
    sls_prd_key ,
    sls_cust_id ,
    sls_order_dt ,
    sls_ship_dt ,
    sls_due_dt ,
    sls_price ,
    sls_quantity ,
    sls_sales 
)

SELECT 
    sls_ord_num ,
    sls_prd_key ,
    sls_cust_id ,

     -- Validate and convert order date: handle invalid dates (0 or wrong length) by setting to NULL
    CASE 
        WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt as varchar) as DATE)
    END sls_order_dt,

     -- Convert ship date from numeric to DATE format
    CAST(CAST(sls_ship_dt as varchar) as DATE) as sls_ship_dt ,
    CAST(CAST(sls_due_dt as varchar) as DATE) as sls_due_dt ,
    CASE 
        WHEN sls_price IS NULL OR sls_price <= 0 
        THEN ABS(sls_sales) / NULLIF(sls_quantity,0) -- Prevent division by zero
        ELSE sls_price 
    END sls_price,
    sls_quantity,

     -- Validate and recalculate sales amount: ensure sales = quantity * price
    CASE 
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
        THEN sls_quantity * ABS(sls_price) -- Recalculate using absolute price value
        ELSE sls_sales
    END sls_sales
FROM bronze.crm_sales_details


-------------------------------------------------------------------------------------------
-- DATA QUALITY VALIDATION CHECKS
-------------------------------------------------------------------------------------------

-- Sample check: Review records where sales = price * quantity for business validation
SELECT sls_price, sls_quantity,sls_sales FROM silver.crm_sales_details
WHERE sls_quantity > 1


-- Check for whitespace issues and NULL values in product keys and order number
SELECT 
    sls_prd_key 
FROM silver.crm_sales_details
WHERE sls_prd_key != TRIM(sls_prd_key) 
OR sls_prd_key IS NULL
OR sls_ord_num != TRIM(sls_ord_num) 
OR sls_ord_num IS NULL

-- Validate business logic: Order date should not be after ship date or due date
SELECT 
    *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
OR sls_order_dt > sls_due_dt

-- Check for data integrity in critical numeric fields
SELECT 
    sls_price,
    sls_quantity,
    sls_sales
FROM silver.crm_sales_details
WHERE 
sls_price <= 0
OR sls_price IS NULL
OR sls_quantity <= 0
OR sls_quantity IS NULL
OR sls_sales <= 0
OR sls_sales IS NULL