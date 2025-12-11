    -- Drop the view if it already exists to avoid conflicts
    IF OBJECT_ID('gold.dim_customers','V') IS NOT NULL
        DROP VIEW gold.dim_customers;
    GO

    -- Create customer dimension view for the gold layer
    CREATE VIEW gold.dim_customers AS
    SELECT 
        -- Surrogate key for data warehousing (sequential unique identifier)
        ROW_NUMBER() OVER(ORDER BY ci.cst_id) as customer_key,

        -- Business keys from source systems
        ci.cst_id as customer_id,
        ci.cst_key as customer_number,

        -- Customer personal information
        ci.cst_firstname as first_name,
        ci.cst_lastname as last_name,
        cloc.cntry as country,
        ci.cst_marital_status as marital_status ,

        -- Enhanced gender logic: prefer CRM gender, fallback to ERP gender
        CASE 
            WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
            ELSE (COALESCE(cbd.gen, 'n/a'))
        END gender,
        cbd.bdate birthdate,
        ci.cst_create_date as create_date 
    FROM silver.crm_cst_info ci 
    
    -- Left join ERP customer data to get additional demographic information
    LEFT JOIN silver.erp_cust_az12 cbd 
    on ci.cst_key = cbd.cid

    -- Left join location data to get country information  
    LEFT JOIN silver.erp_loc_a101 cloc 
    ON ci.cst_key = cloc.cid

