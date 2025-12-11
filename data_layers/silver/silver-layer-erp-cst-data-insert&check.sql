
-- ✅ Insert standardized and cleaned data into silver layer table
-- Purpose: Perform data standardization while loading from bronze → silver
TRUNCATE TABLE silver.erp_cust_az12;
PRINT ' INSERTING CUST DATA INTO SILVER LAYER'

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


SELECT * FROM silver.erp_cust_az12

--------------------------------------------------------------
-- 🧠 DATA QUALITY CHECKS: Ensure standardization consistency
--------------------------------------------------------------

-- Check for Customer IDs with unwanted spaces
SELECT cid 
FROM silver.erp_cust_az12
WHERE cid != TRIM(cid)

--- Check for invalid or missing birthdates
SELECT 
bdate 
FROM silver.erp_cust_az12
WHERE bdate > GETDATE() OR bdate IS NULL

--Check gender value consistency
-- (Should contain only 'Male', 'Female', or 'n/a')

SELECT distinct gen 
FROM silver.erp_cust_az12