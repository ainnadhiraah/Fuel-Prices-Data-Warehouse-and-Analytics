/*
============================================================================  
DDL Script: Create Dimension Tables in Gold Layer
============================================================================
Script purpose:
	This script create the dimension tables present in the 'gold' schema,
	dropping existing table with the same name.

	Run this script to re-define ddl of the mapping tables
============================================================================
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

