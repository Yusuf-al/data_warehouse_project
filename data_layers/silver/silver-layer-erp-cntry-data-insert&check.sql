
--✅ Insert cleaned and standardized data into silver layer
TRUNCATE TABLE silver.erp_loc_a101;

PRINT "INSERTING LOC DATA IN SILVER LAYER"

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


--✅ Data standardization and consistency checks
SELECT * FROM silver.erp_loc_a101

-- Check if any Customer IDs contain unwanted spaces
SELECT cid 
FROM silver.erp_loc_a101
WHERE cid != TRIM(cid)

-- Check for NULL country values (data quality issue)
SELECT cntry 
FROM silver.erp_loc_a101
WHERE cntry IS NULL

-- Review distinct standardized country values
SELECT distinct cntry FROM silver.erp_loc_a101