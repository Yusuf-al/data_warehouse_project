SELECT 
    ROW_NUMBER() OVER(ORDER BY prd_start_dt,prd_key ) as product_key,
    pi.prd_id as product_id,
    pi.prd_key as porduct_number,
    pi.prd_nm as product_name,
    pc.id as category_id,
    pc.cat as product_category,
    pc.subcat as product_subcategory,
    pc.maintenance as maintenance,
    pi.prd_cost as product_price,
    pi.prd_line as product_line,
    pi.prd_start_dt as start_dates
FROM silver.crm_prd_info pi
LEFT JOIN silver.erp_px_cat_g1v2 pc 
ON pi.cat_id = pc.id
WHERE pi.prd_end_dt IS NULL      ---- Remove historical data only fetch current data which end date is null

---check uniqueness does the have duplicate
SELECT product_category , COUNT(*) FROM (
    SELECT 
    pi.prd_id as product_id,
    pi.prd_key as porduct_key,
    pi.prd_nm as product_name,
    pc.id as category_id,
    pc.cat as product_category,
    pc.subcat as product_subcategory,
    pi.prd_cost as product_price,
    pi.prd_start_dt as start_dates,
    pc.maintenance as maintenance
FROM silver.crm_prd_info pi
LEFT JOIN silver.erp_px_cat_g1v2 pc 
ON pi.cat_id = pc.id
WHERE pi.prd_end_dt IS NULL
)t GROUP BY product_category
HAVING COUNT(*) > 1


SELECT * FROM silver.erp_px_cat_g1v2

