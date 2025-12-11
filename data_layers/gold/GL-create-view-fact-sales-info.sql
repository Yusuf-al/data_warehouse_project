/*
======== DDL Script: Create Gold Views ========
Script Purpose:
    This script creates views for the Gold layer in the data warehouse.
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from 
    the Silver layer to produce a clean, enriched, and business-ready dataset.

Usage:
    These views can be queried directly for analytics and reporting.
*/

-- Drop view if it already exists to allow recreation
IF OBJECT_ID('gold.fact_sales_details','V') IS NOT NULL
    DROP VIEW gold.fact_sales_details
GO

-- Create sales fact view with key dimensions and measures
CREATE VIEW gold.fact_sales_details AS 
    SELECT
        ---Dimentions
        sl.sls_ord_num as order_number ,
        pd.product_key as product_key,
        cm.customer_key as customer_key,
        --- Dates
        sl.sls_order_dt as order_date,
        sl.sls_ship_dt  as shipping_date,
        sl.sls_due_dt as due_date,
        
        --- Measures
        sl.sls_price as price,
        sl.sls_quantity as quantity,
        sl.sls_sales as total_sales 
    FROM silver.crm_sales_details as sl
    LEFT JOIN gold.dim_products as pd
    ON sl.sls_prd_key = pd.product_number
    LEFT JOIN gold.dim_customers as cm 
    ON sl.sls_cust_id = cm.customer_id
