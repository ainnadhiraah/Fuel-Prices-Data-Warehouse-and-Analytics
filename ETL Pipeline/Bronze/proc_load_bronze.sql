/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================

Script Purpose:
    This stored procedure loads raw source data into the Bronze layer
    of the data warehouse from external CSV files.

    The Bronze layer acts as the raw data ingestion layer and preserves
    source data in its original structure.

    The procedure performs a full refresh load by truncating existing
    Bronze tables before reloading the latest source data using the
    BULK INSERT operation.

Process Overview:
    For each dataset, the procedure performs:
        1. TRUNCATE of the target Bronze table
        2. BULK INSERT from external CSV file
        3. Logging of load duration per table
        4. Error handling via TRY...CATCH

Source Datasets:
    - asia_fuel_prices_detailed
    - crude_oil_annual
    - fuel_tax_comparison
    - asia_subsidy_tracker
    - countries_ref

ETL Layer Role:
    Bronze Layer (Raw Ingestion Layer):
        - Stores raw data as-is from source systems/files
        - No cleansing, transformation, or standardization applied
        - Acts as the foundation layer for downstream processing (Silver/Gold)

Execution Behavior:
    - Full refresh load (TRUNCATE + INSERT)
    - Reads data directly from local CSV file paths
    - Executes sequentially per dataset
    - Prints execution time for monitoring and performance tracking

Parameters:
    None.
    This stored procedure does not accept input parameters
    and does not return values.

Usage Example:
    EXEC bronze.load_bronze;

Notes:
    - Existing data in Bronze tables will be removed before loading
    - No transformation is applied in the Bronze layer
	- File paths must be valid and accessible before execution
    - UTF-8 encoding is used for selected datasets where required (e.g., countries_ref)

Error Handling:
    - Implemented using TRY...CATCH blocks
    - Captures and displays:
        * Error message
        * Error number
        * Error state
    - Helps identify and debug ingestion failures during load process

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
