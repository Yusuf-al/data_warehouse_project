
-----///---INSERTNIG DATA TO SILVER LAYER TABLE ---///----
TRUNCATE TABLE silver.silver.crm_prd_info;
PRINT'INSERTNIG PRODUCT DATA TO SILVER LAYER TABLE';

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

-----//-- Checking silver layer data --//----

-- View all inserted and standardized product data
SELECT * FROM silver.crm_prd_info

--- Check duplicate and NULL product IDs
SELECT 
    prd_id,
    COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

--- Check if any product cost is missing or negative
SELECT prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

--- Review all distinct product line categories for standardization
SELECT DISTINCT prd_line
FROM silver.crm_prd_info


--- Check for extra spaces in product key field
SELECT cat_id_with_prd_key FROM silver.crm_prd_info
WHERE cat_id_with_prd_key != TRIM(cat_id_with_prd_key)

--- Check for invalid or inconsistent date ranges
SELECT 
*
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt