/*
--------------------------------------------------------------------------    
    **** Stored Procedure: Load Silver Layer (Bronze => Silver) ****
--------------------------------------------------------------------------
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to populate the silver schema tables from the bronze schema.

Actions Performed:
    -Truncates Silver tables.
    -Inserts transformed and cleansed data from Bronze Into Silver tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
EXEC silver.load_silver;

*/


CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN 
    DECLARE @start_time DATETIME, @end_time DATETIME,@batch_start_time DATETIME, @batch_end_time DATETIME
    BEGIN TRY
        SET @batch_end_time = GETDATE()
            SET @start_time = GETDATE()        
                PRINT 'INSERTING CRM CST INFO TO SILVER LAYER';
                TRUNCATE TABLE silver.crm_cst_info;
                -- Insert transformed and cleaned data into the silver layer table
                INSERT INTO silver.crm_cst_info (
                    cst_id,
                    cst_key,
                    cst_firstname ,
                    cst_lastname,
                    cst_marital_status,
                    cst_gndr,
                    cst_create_date
                )
                SELECT 
                    cst_id,
                    cst_key,

                    -- Remove leading/trailing spaces
                    TRIM(cst_firstname) as cst_firstname ,
                    TRIM(cst_lastname) as cst_lastname,

                    -- Standardize marital status and handle unexpected values
                    CASE 
                        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                    ELSE 'n/a' 
                    END cst_marital_status,

                    -- Standardize gender and handle unexpected values
                    CASE 
                        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                    ELSE 'n/a' 
                    END cst_gndr,
                    cst_create_date

                FROM (
                    -- Deduplication: For each customer ID, keep only the most recent record
                    SELECT *,
                    RANK() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag 
                    FROM bronze.crm_cst_info 

                    -- Filter for latest records and valid customer IDs
                )t WHERE flag = 1 AND cst_id IS NOT NULL        
            SET @end_time = GETDATE()
            
            PRINT '--------------------------------------------------------'
            PRINT ' CRM CST Load duration '+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'
            PRINT '--------------------------------------------------------'

            SET @start_time = GETDATE()        
                PRINT'INSERTNIG CRM PRODUCT DATA TO SILVER LAYER TABLE';
                TRUNCATE TABLE silver.crm_prd_info;
                INSERT INTO silver.crm_prd_info (
                    prd_id,
                    cat_id_with_prd_key,
                    cat_id,
                    prd_key,
                    prd_nm,
                    prd_cost,
                    prd_line,
                    prd_start_dt,
                    prd_end_dt
                )
                SELECT
                    prd_id,
                    prd_key as cat_id_with_prd_key,

                    -- Standardize category ID by replacing '-' with '_'
                    REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id,

                    -- Extract product key portion from prd_key
                    SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key,
                    prd_nm,

                    -- Replace NULL cost values with 0 to avoid missing data
                    ISNULL(prd_cost, 0) as prd_cost,

                    -- Standardize product line codes into readable names
                    CASE UPPER(TRIM(prd_line))
                        WHEN 'M' THEN  'Mountain'
                        WHEN 'R' THEN  'Road'
                        WHEN 'S' THEN  'Other Sales'
                        WHEN 'T' THEN  'Touring'
                        ELSE 'n/a'
                    END prd_line,

                    -- Ensure valid date type for start and end dates
                    CAST(prd_start_dt as DATE) as prd_start_dt,
                    CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 as DATE) as prd_end_dt
                FROM bronze.crm_prd_info
            SET @end_time = GETDATE()

            PRINT '--------------------------------------------------------'
            PRINT ' CRM PRD Load duration '+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'
            PRINT '--------------------------------------------------------'

            SET @start_time = GETDATE()
                PRINT 'INSERTING CRM SALES DEAILS IN SILVER LAYER TABLE';
                TRUNCATE TABLE silver.crm_sales_details;

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
            SET @end_time = GETDATE()

            PRINT '--------------------------------------------------------'
            PRINT ' CRM Sales Details Load duration '+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'
            PRINT '--------------------------------------------------------'

            SET @start_time = GETDATE()

                PRINT 'INSERTING ERP LOC DATA IN SILVER LAYER';
                TRUNCATE TABLE silver.erp_loc_a101;

                INSERT INTO silver.erp_loc_a101 (
                    cid,
                    cntry 
                )
                SELECT 
                -- Remove any dashes from customer ID for consistency
                    REPLACE(cid,'-','') as cid,

                    -- Standardize country names and handle missing values
                    CASE 
                        WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
                        WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
                        WHEN TRIM(cntry) = '' OR TRIM(cntry) IS NULL THEN 'n/a'
                        ELSE TRIM(cntry)
                    END cntry
                FROM bronze.erp_loc_a101
            SET @end_time = GETDATE()

            PRINT '--------------------------------------------------------'
            PRINT ' ERP LOC Load duration '+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'
            PRINT '--------------------------------------------------------'

            SET @start_time = GETDATE()
                PRINT'INSERTING ERP CUST DATA INTO SILVER LAYER';
                TRUNCATE TABLE silver.erp_cust_az12;

                INSERT INTO silver.erp_cust_az12 (
                    cid ,
                    bdate ,
                    gen
                )
                SELECT 
                    -- If the ID starts with 'NAS', remove that prefix for consistency
                    CASE 
                        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                        ELSE cid
                    END cid_2,

                    -- If the date of birth is in the future, replace it with NULL
                    CASE 
                        WHEN bdate > GETDATE() THEN NULL
                        ELSE bdate
                    END bdate,

                    -- Convert M/F or MALE/FEMALE into consistent 'Male'/'Female' format
                    -- Assign 'n/a' when gender data is invalid or missing
                    CASE 
                        WHEN TRIM(UPPER(gen)) IN ('M','MALE') THEN 'Male'
                        WHEN TRIM(UPPER(gen)) IN ('F','FEMALE') THEN 'Female'
                        else 'n/a'
                    END gen
                FROM bronze.erp_cust_az12            
            SET @end_time = GETDATE()

            PRINT '--------------------------------------------------------'
            PRINT ' CRM CUST DATA Load duration '+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'
            PRINT '--------------------------------------------------------'


            SET @start_time = GETDATE()
                PRINT 'INSERT ERP PRD CAT DATA INTO SILVER LAYER';
                TRUNCATE TABLE silver.erp_px_cat_g1v2; 
                -- Insert product category data from bronze to silver layer without transformation
                -- This is a direct copy as this reference data is assumed to be clean
                INSERT INTO silver.erp_px_cat_g1v2 (
                    id ,
                    cat ,
                    subcat ,
                    maintenance
                ) SELECT 
                    id,
                    TRIM(cat) as cat,
                    TRIM(subcat) as subcat, 
                    TRIM(maintenance) as maintenance
                FROM bronze.erp_px_cat_g1v2  
            SET @end_time = GETDATE()

            PRINT '--------------------------------------------------------'
            PRINT ' ERP PRD CAT DATA Load duration '+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'
            PRINT '--------------------------------------------------------'

        SET @batch_end_time = GETDATE()

        PRINT '============ Total load duration of Bronze layer ===============';
        PRINT 'LOAD DURATION' + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) as NVARCHAR) +' Seconds' ;
    END TRY
    BEGIN CATCH
        PRINT '============ ERROR IN SILVER LAYER ===============';
        PRINT 'Error Message' + ERROR_MESSAGE();
        PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '===================================================';
    END CATCH
END

EXEC silver.load_silver
