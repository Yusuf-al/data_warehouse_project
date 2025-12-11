
/*

Stored Procedure: Load Bronze Layer (Source > Bronze)

Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files.
    It performs the following actions:
        - Truncates the bronze tables before loading data.
        - Uses the BULK INSERT command to load data from csv Files to bronze tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
EXEC bronze.load_bronze;

*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
    BEGIN TRY
        SET @batch_start_time = GETDATE()

        PRINT '===== LOAD BRONZE LAYER =====';
        PRINT '----INSERTING CRM DATA TO TABLE----';

        PRINT '============ crm_cst_info ==============='
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_cst_info
        BULK INSERT bronze.crm_cst_info
        FROM 'C:\Users\Yusuf Al Naiem\OneDrive\Desktop\SQL Data\Project-1-DW\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW=2,
            FIELDTERMINATOR=',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT 'crm_cst_info take Load duration '+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'

        PRINT '============ crm_prd_info ==============='
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_prd_info
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\Yusuf Al Naiem\OneDrive\Desktop\SQL Data\Project-1-DW\datasets\source_crm\prd_info.csv'
        WITH(
            FIRSTROW =2,
            FIELDTERMINATOR = ',',
            TABLOCK
        )
        
         SET @end_time = GETDATE();
         PRINT 'crm_prd_info take Load duration '+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'

        PRINT '============ crm_sales_details ==============='
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_sales_details
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\Yusuf Al Naiem\OneDrive\Desktop\SQL Data\Project-1-DW\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        )
        SET @end_time = GETDATE();
        PRINT 'crm_sales_details Load duration '+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'


        PRINT '----INSERTING ERP DATA TO TABLE----'

        PRINT '============ erp_cust_az12 ==============='
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_cust_az12
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\Yusuf Al Naiem\OneDrive\Desktop\SQL Data\Project-1-DW\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        )
        SET @end_time = GETDATE();
        PRINT 'erp_cust_az12 Load duration '+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'

        PRINT '============ erp_px_cat_g1v2 ==============='
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_px_cat_g1v2
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\Yusuf Al Naiem\OneDrive\Desktop\SQL Data\Project-1-DW\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        )
        SET @end_time = GETDATE();
        PRINT 'erp_px_cat_g1v2 Load duration '+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'

        PRINT '============ erp_loc_a101 ==============='
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_loc_a101
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\Yusuf Al Naiem\OneDrive\Desktop\SQL Data\Project-1-DW\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        )
        SET @end_time = GETDATE()
        PRINT 'erp_loc_a101 Load duration '+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds'
        SET @batch_end_time = GETDATE()
        
        PRINT '============ Total load duration of Bronze layer ==============='
        PRINT 'Load duration '+ CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds'




    END TRY
    BEGIN CATCH
        PRINT '============ ERROR IN BRONZE LAYER ==============='
        PRINT 'Error Message' + ERROR_MESSAGE();
        PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '==================================================='
    END CATCH
END

EXEC bronze.load_bronze