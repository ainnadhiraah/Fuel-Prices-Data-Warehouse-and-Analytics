/*
===============================================================================
DDL Script: Create Gold Dimension Tables
===============================================================================

Script Purpose:
    This script creates dimension tables in the Gold layer of the
    data warehouse.

    The Gold layer represents the final analytical layer designed
    using dimensional modeling principles (Star Schema).

    Each dimension table contains clean, standardized and enriched
    descriptive attributes derived from transformed data in the
    Silver layer.

 The dimension model includes:
        - dim_country  : Standardized country reference information
        - dim_date     : Calendar and temporal reference data using date keys

    These dimension tables provide business context for analytical
    reporting and are intended to be joined with fact tables for
    multidimensional analysis.

Usage:
    - Creates dimension tables in the Gold layer
    - Supports star schema and dimensional modeling
    - Provides standardized reference data for analytics
    - Used for filtering, grouping and categorizing fact data

Notes:
    - Source data originates from the Silver layer
    - Country-related attributes are standardized using ISO3 mappings
	- dim_date uses a generated date_key for temporal analysis
    - Some fact tables may use distinct year values directly depending
      on the grain and availability of source data
    - Designed for reporting, dashboarding and BI workloads
    - Dimension tables serve as descriptive entities for fact tables

===============================================================================
*/

IF OBJECT_ID ('gold.dim_date','U') IS NOT NULL
	DROP TABLE gold.dim_date;
GO

CREATE TABLE gold.dim_date (
	date_key		INT,
	full_date		DATE,
	"year"			INT,
	"month"			INT,
	month_name		NVARCHAR(50),
	"quarter"		INT,
	year_month		INT,
	is_month_start	INT
);
GO

IF OBJECT_ID ('gold.dim_country','U') IS NOT NULL
	DROP TABLE gold.dim_country;
GO

CREATE TABLE gold.dim_country(
	iso3			    NVARCHAR(3),
	country			  NVARCHAR(MAX),
	region			  NVARCHAR(50),
	sub_region		NVARCHAR(50),
	is_asia			  INT
);
GO

