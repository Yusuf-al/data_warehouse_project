   ----CUSTOMER TABLE MARGING FROM CRM AND ERP 
    SELECT 
        ROW_NUMBER() OVER(ORDER BY ci.cst_id) as customer_key,
        ci.cst_id as customer_id,
        ci.cst_key as customer_number,
        ci.cst_firstname as first_name,
        ci.cst_lastname as last_name,
         cloc.cntry as country,
        ci.cst_marital_status as marital_status ,
        CASE 
            WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
            ELSE (COALESCE(cbd.gen, 'n/a'))
        END gender,
        cbd.bdate birthdate,
        ci.cst_create_date as create_date 
    FROM silver.crm_cst_info ci 
    LEFT JOIN silver.erp_cust_az12 cbd 
    on ci.cst_key = cbd.cid
    LEFT JOIN silver.erp_loc_a101 cloc 
    ON ci.cst_key = cloc.cid

---USING SUBQUERY CHECK THE DUPLICATE ROW
    -- SELECT cst_id,COUNT(*) FROM ()t GROUP BY cst_id
    -- HAVING COUNT(*) > 1

-- DATA INTRIGRATION
SELECT DISTINCT
    ci.cst_gndr,
    cbd.gen,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE (COALESCE(cbd.gen, 'n/a'))
    END new_gen
FROM silver.crm_cst_info ci 
LEFT JOIN silver.erp_cust_az12 cbd 
on ci.cst_key = cbd.cid
LEFT JOIN silver.erp_loc_a101 cloc 
ON ci.cst_key = cloc.cid
ORDER BY 1, 2


-- SELECT * FROM silver.crm_cst_info
-- SELECT * FROM silver.erp_cust_az12
-- SELECT * FROM silver.erp_loc_a101
-- SELECT * FROM gold.dim_customer