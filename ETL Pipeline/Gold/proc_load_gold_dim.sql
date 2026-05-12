/*
===============================================================================
Stored Procedure: Load Gold Dimension Tables
===============================================================================

Script Purpose:
    This script loads data into dimension tables in the Gold layer
    of the data warehouse.

    The procedure performs a full refresh load by truncating existing
    dimension tables before inserting the latest transformed and
    standardized data from the Silver layer.

    The dimension tables provide descriptive and reference attributes
    used to support analytical reporting and dimensional modeling.

	 The dimensions include:
        - dim_country
        - dim_date

Usage:
    - Refreshes Gold dimension tables
    - Loads clean and standardized reference data
    - Supports star schema relationships with fact tables
    - Intended to be executed before loading fact tables

Notes:
Notes:
    - Source data originates from the Silver layer
    - Country-related attributes are standardized using ISO3 mappings
    - dim_date uses generated date keys for temporal analysis
    - Designed for analytics, dashboarding, and BI workloads

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





