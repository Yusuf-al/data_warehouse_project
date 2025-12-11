-- Check if the products dimension view already exists and drop it if it does
-- This ensures clean recreation of the view during deployment

IF OBJECT_ID('gold.dim_products','V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

-- Create product dimension view in the gold layer for reporting and analytics
CREATE VIEW gold.dim_products AS 
SELECT 

    -- Surrogate key for data warehousing
    ROW_NUMBER() OVER(ORDER BY prd_start_dt,prd_key ) as product_key,

    -- Business keys from source systems
    pi.prd_id as product_id,
    pi.prd_key as product_number,
    pi.prd_nm as product_name,

    -- Product categorization hierarchy from ERP system
    pc.id as category_id,
    pc.cat as product_category,
    pc.subcat as product_subcategory,
    pc.maintenance as maintenance,
    
    pi.prd_cost as product_price,
    pi.prd_line as product_line,

    -- Product lifecycle dates
    pi.prd_start_dt as start_dates
FROM silver.crm_prd_info pi

-- Left join to product category reference data to enrich product information
LEFT JOIN silver.erp_px_cat_g1v2 pc 
ON pi.cat_id = pc.id

-- Critical business filter: Only include current active products
------ NULL end date indicates the product is currently active and not discontinued
WHERE pi.prd_end_dt IS NULL 