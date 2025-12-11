/*
        Bronze Layer

Step 1: Analysing -
          Interview Source System Experts  

Step 2: Coding -
          Data Ingestion

Step 3: Validating-
          Data Completeness & Schema Checks

Step 4: Docs & Version-
          Data Documenting Versioning in GIT

===> Business Context & Ownership <===
    #> Who owns the data?
    #> What Business Process it supports?
    #> System & Data documentation
    #> Data Model & Data Catalog

===> Architecture & Technology Stack <===
    #> How is data stored? (SQL Server, Oracle, AWS, Azure. ...)
    #> What are the integration capabilities? (API, Kafka, File Extract, Direct DB, ...)

===> Extract & Load <===
    #> Incremental vs. Full Loads ?
    #> Data Scope & Historical Needs
    #> What is the expected size of the extracts?
    #> Are there any data volume limitations?
    #> How to avoid impacting the source system's performance?
    #> authentication and authorization (tokens, SSH keys, VPN, IP whitelisting....)

*/

/*
                    ===///=== Bronze Layer TASKS ===///===
                Definition ->   Raw, unprocessed data as-is from sources
                  Objective->   Traceability & Debugging
                Object Type->   Tables
                Load Method->   Full Load (Truncate & Insert)
        Data Transformation->   None (as-is)
              Data Modeling->   None (as-is)
            Target Audience->   Data Engineers

*/

/*
====================================================================================
DDL Script: Create Bronze Tables

Script Purpose:
        This script creates tables in the 'bronze' schema, dropping existing tables 
        if they already exist. 
        Run this script to re-define the DDL structure of 'bronze Tables
*/


IF OBJECT_ID('bronze.crm_cst_info','U') IS NOT NULL
    DROP TABLE bronze.crm_cst_info

CREATE TABLE bronze.crm_cst_info (
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(20),
    cst_gndr NVARCHAR(20),
    cst_create_date DATE
);


IF OBJECT_ID('bronze.crm_prd_info','U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info

CREATE TABLE bronze.crm_prd_info (
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE

);


IF OBJECT_ID('bronze.crm_sales_details','U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);


IF OBJECT_ID('bronze.erp_cust_az12','U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12

CREATE TABLE bronze.erp_cust_az12 (
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(50)
);



IF OBJECT_ID('bronze.erp_loc_a101','U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101

CREATE TABLE bronze.erp_loc_a101 (
   cid NVARCHAR(50),
   cntry NVARCHAR(50)
);



IF OBJECT_ID('bronze.erp_px_cat_g1v2','U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2


CREATE TABLE bronze.erp_px_cat_g1v2(
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50)
);



/*
Changing fac analysis
capling
association rule
confidance 
*/