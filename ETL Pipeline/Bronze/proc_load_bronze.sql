/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS

BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;

    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '================================================';

        SET @start_time = GETDATE()
        PRINT '>> Truncating Table: bronze.asia_fuel_prices_detailed';
        TRUNCATE TABLE bronze.asia_fuel_prices_detailed;
        PRINT '>> Inserting Data Into: bronze.asia_fuel_prices_detailed';
        BULK INSERT bronze.asia_fuel_prices_detailed
        FROM 'C:\DataProjects\FuelPricesDW\01_Datasets\asia_fuel_prices_detailed.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ---------------';

        SET @start_time = GETDATE()
        PRINT '>> Truncating Table: bronze.crude_oil_annual';
        TRUNCATE TABLE bronze.crude_oil_annual;
        PRINT '>> Inserting Data Into: bronze.crude_oil_annual';
        BULK INSERT bronze.crude_oil_annual
        FROM 'C:\DataProjects\FuelPricesDW\01_Datasets\crude_oil_annual.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ---------------';

        SET @start_time = GETDATE()
        PRINT '>> Truncating Table: bronze.fuel_tax_comparison';
        TRUNCATE TABLE bronze.fuel_tax_comparison;
        PRINT '>> Inserting Data Into: fuel_tax_comparison';
        BULK INSERT bronze.fuel_tax_comparison
        FROM 'C:\DataProjects\FuelPricesDW\01_Datasets\fuel_tax_comparison.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ---------------';

        SET @start_time = GETDATE()
        PRINT '>> Truncating Table: bronze.asia_subsidy_tracker';
        TRUNCATE TABLE bronze.asia_subsidy_tracker;
        PRINT '>> Inserting Data Into: asia_subsidy_tracker';
        BULK INSERT bronze.asia_subsidy_tracker
        FROM 'C:\DataProjects\FuelPricesDW\01_Datasets\asia_subsidy_tracker - Copy.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ---------------';

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: bronze.countries_ref';
		TRUNCATE TABLE bronze.countries_ref;
		PRINT '>> Inserting Data Into: countries_ref';
		BULK INSERT bronze.countries_ref
		FROM 'C:\DataProjects\FuelPricesDW\01_Datasets\countries_ref.csv'
		WITH (
		    FORMAT = 'CSV',
		    FIRSTROW = 2,
		    CODEPAGE = '65001',
		    TABLOCK
		);
		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ---------------';	 
        END TRY

        BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	    END CATCH
END
