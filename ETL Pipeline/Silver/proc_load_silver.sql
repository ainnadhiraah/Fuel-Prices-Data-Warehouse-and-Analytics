/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================

Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process
    to populate all tables in the 'silver' schema from the 'bronze' schema.

Process Overview:
    1. TRUNCATE Silver tables (full refresh strategy)
    2. EXTRACT data from Bronze layer
    3. TRANSFORM data (cleaning, casting, standardization, derivations)
    4. LOAD transformed data into Silver layer tables
    5. LOG execution duration for each table and overall batch

Key Transformations:
    - Data trimming (removal of leading/trailing spaces)
    - Type casting to appropriate data types (DECIMAL, BIT, etc.)
    - Standardization of country and ISO mappings
    - Derived metrics (e.g., price spreads, ratios, margins)
    - Ranking and computed analytical fields where applicable

Data Standardization:
    - Country names are standardized using mapping tables
    - ISO3 codes are used as the primary integration key
    - Cross-dataset consistency is enforced via reference tables

Execution Behavior:
    - Full refresh load (TRUNCATE + INSERT)
    - Sequential processing of each Silver table
    - Execution time logging per table and batch-level monitoring
    - No incremental loading is performed

Parameters:
    None
    (This procedure runs as a full batch ETL with no input parameters)

Output:
    - Populated and refreshed Silver layer tables
    - Execution logs printed for monitoring performance

Usage Example:
    EXEC silver.load_silver;

Notes:
    - This is a full reload process; existing Silver data will be overwritten
    - Bronze layer must be successfully loaded before execution
    - Designed for batch processing, not real-time or incremental pipelines
    - Country inconsistencies are resolved using Silver mapping tables
    - Derived metrics are calculated during transformation stage

Error Handling:
    - Implemented using TRY...CATCH blocks
    - Captures and displays:
        * Error message
        * Error number
        * Error state
    - Helps identify and debug ETL failures during execution

===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;

	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.global_fuel_prices';
		TRUNCATE TABLE silver.global_fuel_prices;
		PRINT '>> Inserting Data Into: silver.global_fuel_prices';
		INSERT INTO silver.global_fuel_prices (
			 country,                    
			 region,                     
			 iso3,
			 gasoline_usd_per_liter,     
			 diesel_usd_per_liter,       
			 local_currency,             
			 gasoline_local_price,       
			 diesel_local_price,         
			 price_date,                 
			 is_asian,                   
			 avg_fuel_usd,               
			 price_spread_usd,           
			 price_spread_local
			 )
		SELECT 
			 country,                    
			 region,                     
			 TRIM(iso3) AS iso3,                       
			 CAST(gasoline_usd_per_liter AS DECIMAL (10,2)) AS gasoline_usd_per_liter,     
			 CAST(diesel_usd_per_liter AS DECIMAL (10,2)) AS diesel_usd_per_liter,      
			 TRIM(local_currency) AS local_currency,             
			 CAST(gasoline_local_price AS DECIMAL (10,2)) AS gasoline_local_price,      
			 CAST(diesel_local_price AS DECIMAL (10,2)) AS diesel_local_price,         
			 price_date,               
			 is_asian,                  
			 CAST(avg_fuel_usd AS DECIMAL (7,2)) AS avg_fuel_usd,
			 CAST(ABS(diesel_usd_per_liter - gasoline_usd_per_liter) AS DECIMAL(7,2)) AS price_spread_usd,
			 CAST(ABS(diesel_local_price - gasoline_local_price) AS DECIMAL(7,2)) AS price_spread_local
		FROM bronze.global_fuel_prices
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading silver.price_trend_monthly
		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.price_trend_monthly';
		TRUNCATE TABLE silver.price_trend_monthly;
		PRINT '>> Inserting Data Into: silver.price_trend_monthly';
		INSERT INTO silver.price_trend_monthly (
			"date",
			"year",
			"month",
			country,
			iso3,
			standard_country,
			region,
			gasoline_usd_per_liter,
			brent_crude_usd_bbl,
			gasoline_mom_change_pct,
			gasoline_yoy_change_pct,
			brent_crude_usd_per_liter,
			gasoline_to_brent_abs_margin,
			gasoline_to_brent_rel_margin,
			gasoline_to_brent_ratio         
		)
		SELECT
			t."date",
			t."year",
			t."month",
			TRIM(t.country) AS country,
			COALESCE(TRIM(m.iso3), TRIM(i."alpha-3")) AS iso3,
			COALESCE(TRIM(m.standard_country), TRIM(t.country)) AS standard_country,
			TRIM(t.region) AS region,                  
			CAST(t.gasoline_usd_per_liter AS DECIMAL(7,2)) AS gasoline_usd_per_liter,
			CAST(t.brent_crude_usd_bbl AS DECIMAL(7,2)) AS brent_crude_usd_bbl,
			CAST(t.mom_change_pct AS DECIMAL(7,2)) AS gasoline_mom_change_pct,
			CAST(t.yoy_change_pct AS DECIMAL(7,2)) AS gasoline_yoy_change_pct,
			ROUND((t.brent_crude_usd_bbl / 159.0),2) AS brent_crude_usd_liter,

			-- derived column 1: absolute margin
			ROUND(t.gasoline_usd_per_liter - (brent_crude_usd_bbl / 159.0), 2) AS gasoline_to_brent_abs_margin,
			
			-- derived column 2: relative margin
			ROUND(
				(t.gasoline_usd_per_liter - (t.brent_crude_usd_bbl / 159.0))
				/ (t.brent_crude_usd_bbl /159.0), 2) AS gasoline_to_brent_rel_margin,

			-- derived column 3: ratio
			ROUND(t.gasoline_usd_per_liter / (t.brent_crude_usd_bbl / 159.0),2) AS gasoline_to_brent_ratio
		FROM bronze.price_trend_monthly t
		LEFT JOIN silver.country_mapping m
			ON LOWER(t.country) = LOWER(m.source_country)
		LEFT JOIN silver.country_ref i
			ON LOWER(COALESCE(m.standard_country, t.country)) = LOWER(i.name)
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading silver.asia_fuel_prices_detailed
		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.asia_fuel_prices_detailed';
		TRUNCATE TABLE silver.asia_fuel_prices_detailed;
		PRINT '>> Inserting Data Into: silver.asia_fuel_prices_detailed';
		INSERT INTO silver.asia_fuel_prices_detailed (
			country,
			sub_region,
			iso3,
			gasoline_usd_per_liter,
			diesel_usd_per_liter,
			lpg_usd_per_kg,
			avg_monthly_income_usd,
			fuel_affordability_index,
			oil_import_dependency_pct,
			refinery_capacity_kbpd,
			ev_adoption_pct,
			fuel_subsidy_active,
			subsidy_cost_bn_usd,
			co2_transport_mt,
			price_date,
			gasoline_pct_daily_wage,
			regional_rank_fuel_affordability
		)
		SELECT
			TRIM(country) AS country,
			TRIM(sub_region) AS sub_region,
			TRIM(iso3) AS iso3,
			CAST(gasoline_usd_per_liter AS DECIMAL(10,2)) AS gasoline_usd_per_liter,
			CAST(diesel_usd_per_liter AS DECIMAL (10,2)) AS diesel_usd_per_liter,
			CAST(lpg_usd_per_kg AS DECIMAL (10,2)) AS lpg_usd_per_kg,
			CAST(avg_monthly_income_usd AS DECIMAL (10,2)) AS avg_monthly_income_usd,
			CAST(fuel_affordability_index AS DECIMAL (10,2)) AS fuel_affordability_index,
			CAST(oil_import_dependency_pct AS DECIMAL (10,2)) AS oil_import_dependency_pct,
			refinery_capacity_kbpd,
			CAST(ev_adoption_pct AS DECIMAL (10,2)) AS ev_adoption_pct,
			CAST(fuel_subsidy_active AS BIT) AS fuel_subsidy_active,
			CAST(subsidy_cost_bn_usd AS DECIMAL (10,2)) AS subsidy_cost_bn_usd,
			CAST(co2_transport_mt AS DECIMAL (10,2)) AS co2_transport_mt,
			price_date,
			CAST(gasoline_pct_daily_wage AS DECIMAL (10,2)) AS gasoline_pct_daily_wage,
			RANK() OVER (PARTITION BY sub_region ORDER BY fuel_affordability_index DESC) AS regional_rank_fuel_affordability
		FROM bronze.asia_fuel_prices_detailed
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading silver.crude_oil_annual
		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.crude_oil_annual';
		TRUNCATE TABLE silver.crude_oil_annual;
		PRINT '>> Inserting Data Into: crude_oil_annual';
		INSERT INTO silver.crude_oil_annual (
			"year",
			brent_avg_usd_bbl,
			wti_avg_usd_bbl,
			brent_yoy_change_pct,
			wti_yoy_change_pct,
			key_event,
			brent_wti_spread,
			avg_price_usd_bbl
			)
		SELECT
			"year",                    
			CAST(brent_avg_usd_bbl AS DECIMAL(6,3)) AS brent_avg_usd_bbl,
			CAST(wti_avg_usd_bbl AS DECIMAL(6,3)) AS wti_avg_usd_bbl,
			CAST(brent_yoy_change_pct AS DECIMAL(6,3)) AS brent_yoy_change_pct,
			CAST(wti_yoy_change_pct AS DECIMAL(6,3)) AS wti_yoy_change_pct,  
			TRIM(key_event) AS key_event,
			CAST(brent_wti_spread AS DECIMAL(6,3)) AS brent_wti_spread,     
			CAST(avg_price_usd_bbl AS DECIMAL(6,3)) AS avg_price_usd_bbl          
		FROM bronze.crude_oil_annual
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading silver.fuel_tax_comparison
		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.fuel_tax_comparison';
		TRUNCATE TABLE silver.fuel_tax_comparison;
		PRINT '>> Inserting Data Into: fuel_tax_comparison';
		INSERT INTO silver.fuel_tax_comparison(
			country,
			iso3,
			standard_country,
			region,
			gasoline_tax_pct,
			diesel_tax_pct,
			vat_pct,
			excise_usd_per_liter,
			carbon_tax_active,
			total_tax_usd_per_liter,
			tax_burden_category         
		)
		SELECT
			TRIM(t.country) AS country,
			COALESCE(TRIM(m.iso3), TRIM(i."alpha-3")) AS iso3,
			COALESCE(TRIM(m.standard_country),TRIM(t.country)) AS standard_country,
			TRIM(t.region) AS region,
			CAST(t.gasoline_tax_pct AS DECIMAL(6,2)) AS gasoline_tax_pct ,
			CAST(t.diesel_tax_pct AS DECIMAL (6,2)) AS diesel_tax_pct,
			CAST(t.vat_pct AS DECIMAL (6,2)) AS vat_pct,
			CAST(t.excise_usd_per_liter AS DECIMAL (6,2)) AS excise_usd_per_liter,
			CAST(t.carbon_tax_active AS BIT) AS carbon_tax_active,
			CAST(t.total_tax_usd_per_liter AS DECIMAL (6,2)) AS total_tax_usd_per_liter,
			TRIM(t.tax_burden_category) AS tax_burden_category 
		FROM bronze.fuel_tax_comparison t
		LEFT JOIN silver.country_mapping m
			ON LOWER(t.country) = LOWER(m.source_country)
		LEFT JOIN silver.country_ref i
			ON LOWER(COALESCE(m.standard_country, t.country)) = LOWER(i.name) 
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		--Loading silver.asia_subsidy_tracker
		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.asia_subsidy_tracker';
		TRUNCATE TABLE silver.asia_subsidy_tracker;
		PRINT '>> Inserting Data Into: asia_subsidy_tracker';
		INSERT INTO silver.asia_subsidy_tracker (
			country,                         
			iso3,                           
			gasoline_subsidized,
			diesel_subsidized,
			subsidy_type, 
			annual_subsidy_cost_bn_usd,
			subsidy_pct_gdp,     
			subsidy_description,
			last_price_change,               
			pricing_mechanism,              
			regulator
			)
		SELECT
			TRIM(country) AS country,
			TRIM(iso3) as iso3,
			CAST(gasoline_subsidized AS BIT) AS gasoline_subsidized,
			CAST(diesel_subsidized AS BIT) AS diesel_subsidized,
			TRIM(subsidy_type) as subsidy_type,
			CAST(annual_subsidy_cost_bn_usd AS DECIMAL(6,2)) AS annual_subsidy_cost_bn_usd,
			CAST(subsidy_pct_gdp AS DECIMAL(6,2)) AS subsidy_pct_gdp,
			TRIM(subsidy_description) AS subsidy_description,
			last_price_change,
			TRIM(pricing_mechanism) AS pricing_mechanism,
			TRIM(regulator) AS regulator
		FROM bronze.asia_subsidy_tracker
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		--Loading silver.country_ref
		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.country_ref';
		TRUNCATE TABLE silver.country_ref;
		PRINT '>> Inserting Data Into: country_ref';
		INSERT INTO silver.country_ref (
			"name",
			"alpha-3",
			region,
			"sub-region",
			"is-asia"
		) 
		SELECT
			TRIM("name") AS country,
			TRIM("alpha-3") AS iso3,
			TRIM(region) AS region,
			TRIM("sub-region") AS sub_region,
			CASE 
				WHEN LOWER(TRIM("sub-region")) LIKE '%Asia%' THEN 1
				ELSE 0
			END "is-asia"
		FROM bronze.countries_ref
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='

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



		


