-- Clear existing data from the silver layer table to prepare for fresh data load
TRUNCATE TABLE silver.crm_cst_info;

PRINT 'INSERTING CRM CST INFO TO SILVER LAYER';

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

-------------------------------------------------------------------------------------------
-- DATA QUALITY CHECKS
-------------------------------------------------------------------------------------------

-- Verify standardized gender values after transformation
SELECT 
DISTINCT cst_gndr
FROM silver.crm_cst_info


-- Check for remaining whitespace issues in first names
SELECT 
    cst_firstname
FROM silver.crm_cst_info
WHERE cst_firstname != TRIM(cst_firstname)


-- Verify deduplication worked - should return no records
SELECT 
    *
FROM (
    SELECT *,
    RANK() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag 
    FROM silver.crm_cst_info 
)t WHERE flag > 1 AND cst_id IS NOT NULL

/*

                    Quality Checks
Script Purpose:
    This script performs various quality checks for data consistency, accuracy. and standardization across the 'silver' schena. It includes checks for:
    Null or duplicate primary keys.
    Unwanted spaces in string fields.
    Data standardization and consistency.
    Invalid date ranges and orders.
    Data consistency between Flated fields.

Usage Notes:
    Run these checks after data loading Silver Layer.
    Investigate and resolve any discrepancies found during the checks.

** Same for all other files
*/