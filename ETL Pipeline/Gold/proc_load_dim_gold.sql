/*
===============================================================================
DDL Script: Creating Dimension Tables in the Gold Layer
===============================================================================

Script Purpose:
   
    This script loads data into dimension tables in the Gold layer
    of the data warehouse.

    Before inserting new records, the script checks whether the target
    dimension table already exists. If it exists, the table is truncated
    to ensure a full refresh with the latest transformed data from the
    Silver layer.

    The loading process produces clean, standardized and business-ready
    dimension data for analytical reporting and dashboard consumption.

Usage:
    - Performs full refresh loading for Gold dimension tables
    - Truncates existing data before inserting updated records
    - Loads standardized and transformed data from the Silver layer
    - Supports dimensional modeling and star schema design

Notes:
    - Source data originates from the Silver layer
    - Intended for reporting, analytics, and BI workloads

===============================================================================
*/

IF OBJECT_ID('gold.dim_date','U') IS NOT NULL
	TRUNCATE TABLE gold.dim_date;
GO

INSERT INTO gold.dim_date (
	date_key,
	full_date,
	"year",
	"month",
	month_name,
	"quarter",
	year_month,
	is_month_start )
SELECT DISTINCT 
	("year" * 10000 + "month" * 100 + 1) AS date_key,
	DATEFROMPARTS ("year", "month", 1) AS full_date,
	"year",
	"month",
	DATENAME (MONTH, DATEFROMPARTS("year","month",1)) AS month_name,
	DATEPART(QUARTER, DATEFROMPARTS("year","month",1)) AS "quarter",
	("year" * 100 + "month") AS year_month,
	1 AS is_month_start
FROM silver.price_trend_monthly;
GO

IF OBJECT_ID('gold.dim_country','U') IS NOT NULL
	TRUNCATE TABLE gold.dim_country;
GO

INSERT INTO gold.dim_country (
	iso3,
	country,
	region,
	sub_region,
	is_asia
)
SELECT
	"alpha-3",
	"name",
	region,
	"sub-region",
	"is-asia"
FROM silver.country_ref;
GO





