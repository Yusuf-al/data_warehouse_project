/*
 For Creating database always use masters data base
    
    -----------Create databse
    CREATE DATABASE [NAME]

    -----------Change database name
     ALTER DATABASE [current_database_name] MODIFY NAME = [new_database_name];

    ===============================================================================================
    Script Purpose:
        This script creates a new database named 'DataWarehouse' after checking if it already exists.
        If the database exists, it is dropped and recreated. Additionally, the script sets up 
        three schemas within the database: 'bronze', 'silver', and 'gold'.
    -----------------------------------------------------------------------------------------------
    WARNING:
        Running this script will drop the entire 'DataWarehouse' database if it exists. 
        All data in the database will be permanently deleted. Proceed with caution and ensure 
        you have proper backups before running this script.
    =================================================================================================
*/

USE master
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

  -----------Create databse
    CREATE DATABASE DataWarehouse;
    GO


  -----------USE databse
    USE DataWarehouse;
    GO

-- Creating bronze Schemas
CREATE SCHEMA bronze;
GO

-- Creating silver Schemas
CREATE SCHEMA silver;
GO

-- Creating gold Schemas
CREATE SCHEMA gold;
GO