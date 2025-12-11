-- Clear existing data from the silver layer product category table
TRUNCATE TABLE silver.erp_px_cat_g1v2 

PRINT 'INSERT PRD CAT DATA INTO SILVER LAYER'

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

-------------------------------------------------------------------------------------------
-- DATA QUALITY AND PROFILING CHECKS
-------------------------------------------------------------------------------------------

-- Sample review of all inserted records
SELECT * FROM silver.erp_px_cat_g1v2

-- Check for whitespace issues in subcategory values
SELECT subcat FROM silver.erp_px_cat_g1v2 WHERE subcat != TRIM(subcat)

-- Data profiling: Analyze distinct values in each column to understand data distribution
-- and identify potential data quality issues
SELECT DISTINCT cat FROM silver.erp_px_cat_g1v2
SELECT DISTINCT subcat FROM silver.erp_px_cat_g1v2
SELECT DISTINCT maintenance FROM silver.erp_px_cat_g1v2