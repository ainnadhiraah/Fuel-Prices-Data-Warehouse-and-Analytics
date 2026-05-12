/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

IF OBJECT_ID('bronze.asia_fuel_prices_detailed', 'U') IS NOT NULL
    DROP TABLE bronze.asia_fuel_prices_detailed;
GO

CREATE TABLE bronze.asia_fuel_prices_detailed (
    country                        NVARCHAR(50),
    sub_region                     NVARCHAR(50),
    iso3                           NVARCHAR(3),
    gasoline_usd_per_liter         FLOAT,
    diesel_usd_per_liter           FLOAT,
    lpg_usd_per_kg                 FLOAT,
    avg_monthly_income_usd         FLOAT,
    fuel_affordability_index       FLOAT,
    oil_import_dependency_pct      FLOAT,
    refinery_capacity_kbpd         INT,
    ev_adoption_pct                FLOAT,
    fuel_subsidy_active            NVARCHAR(50),
    subsidy_cost_bn_usd            FLOAT,
    co2_transport_mt               FLOAT,
    price_date                     DATE,
    gasoline_pct_daily_wage        FLOAT
);
GO

IF OBJECT_ID('bronze.crude_oil_annual', 'U') IS NOT NULL
    DROP TABLE bronze.crude_oil_annual;
GO

CREATE TABLE bronze.crude_oil_annual (
    year                    INT,
    brent_avg_usd_bbl       FLOAT,
    wti_avg_usd_bbl         FLOAT,
    brent_yoy_change_pct    FLOAT,
    wti_yoy_change_pct      FLOAT,
    key_event               NVARCHAR(50),
    brent_wti_spread        FLOAT,
    avg_price_usd_bbl       FLOAT
);
GO

IF OBJECT_ID('bronze.fuel_tax_comparison', 'U') IS NOT NULL
    DROP TABLE bronze.fuel_tax_comparison;
GO

CREATE TABLE bronze.fuel_tax_comparison (
    country                     NVARCHAR(50),
    region                      NVARCHAR(50),
    gasoline_tax_pct            FLOAT,
    diesel_tax_pct              FLOAT,
    vat_pct                     FLOAT,
    excise_usd_per_liter        FLOAT,
    carbon_tax_active           NVARCHAR(50),
    total_tax_usd_per_liter     FLOAT,
    tax_burden_category         NVARCHAR(50)
);
GO

IF OBJECT_ID('bronze.asia_subsidy_tracker', 'U') IS NOT NULL
    DROP TABLE bronze.asia_subsidy_tracker;
GO

CREATE TABLE bronze.asia_subsidy_tracker (
    country                         NVARCHAR(50),
    iso3                            NVARCHAR(3),
    gasoline_subsidized             NVARCHAR(50),
    diesel_subsidized               NVARCHAR(50),
    subsidy_type                    NVARCHAR(50),
    annual_subsidy_cost_bn_usd      FLOAT,
    subsidy_pct_gdp                 FLOAT,
    subsidy_description             NVARCHAR(MAX),
    last_price_change               DATE,
    pricing_mechanism               NVARCHAR(50),
    regulator                       NVARCHAR(10)
);
GO

IF OBJECT_ID('bronze.countries_ref', 'U') IS NOT NULL
    DROP TABLE bronze.countries_ref;
GO

CREATE TABLE bronze.countries_ref(
   "name"                     NVARCHAR(MAX),
   "alpha-2"                  NVARCHAR(5),
   "alpha-3"                  NVARCHAR(3),
   "country-code"             INT,
   "iso_3166-2"               NVARCHAR(50),
   "region"                   NVARCHAR(50),
   "sub-region"               NVARCHAR(50),
   "intermediate-region"      NVARCHAR(50),
   "region-code"              INT,
   "sub-region-code"          INT,
   "intermediate-region-code" INT
);
GO


