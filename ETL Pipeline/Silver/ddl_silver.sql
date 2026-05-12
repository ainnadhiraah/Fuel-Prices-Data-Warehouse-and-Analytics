/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'silver' Tables
===============================================================================
*/

IF OBJECT_ID('silver.global_fuel_prices', 'U') IS NOT NULL
    DROP TABLE silver.global_fuel_prices;
GO

CREATE TABLE silver.global_fuel_prices(
     country                    NVARCHAR(50),
     region                     NVARCHAR(50),
     iso3                       NVARCHAR(3),
     gasoline_usd_per_liter     DECIMAL(10,2),
     diesel_usd_per_liter       DECIMAL(10,2),
     local_currency             NVARCHAR(5),
     gasoline_local_price       DECIMAL(10,2),
     diesel_local_price         DECIMAL(10,2),
     price_date                 DATE,
     is_asian                   INT,
     avg_fuel_usd               DECIMAL(7,2),
     price_spread_usd           DECIMAL(7,2),
     price_spread_local         DECIMAL(7,2),
     dwh_create_date            DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.price_trend_monthly', 'U') IS NOT NULL
    DROP TABLE silver.price_trend_monthly;
GO

CREATE TABLE silver.price_trend_monthly(
    "date"                          DATE,
    "year"                          INT,
    "month"                         INT,
    country                         NVARCHAR(50), 
    iso3                            NVARCHAR(3),    -- joined
    standard_country                NVARCHAR(MAX),  -- joined
    region                          NVARCHAR(50),
    gasoline_usd_per_liter          DECIMAL(7,2),
    brent_crude_usd_bbl             DECIMAL(7,2),
    gasoline_mom_change_pct         DECIMAL(7,2),
    gasoline_yoy_change_pct         DECIMAL(7,2),
    brent_crude_usd_per_liter       DECIMAL(7,2),
    gasoline_to_brent_abs_margin    DECIMAL(7,2),
    gasoline_to_brent_rel_margin    DECIMAL(7,2),
    gasoline_to_brent_ratio         DECIMAL(7,2),
    dwh_create_date                 DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.asia_fuel_prices_detailed', 'U') IS NOT NULL
    DROP TABLE silver.asia_fuel_prices_detailed;
GO

CREATE TABLE silver.asia_fuel_prices_detailed (
    country                          NVARCHAR(50),
    sub_region                       NVARCHAR(50),
    iso3                             NVARCHAR(3),
    gasoline_usd_per_liter           DECIMAL(10,2),
    diesel_usd_per_liter             DECIMAL(10,2),
    lpg_usd_per_kg                   DECIMAL(10,2),
    avg_monthly_income_usd           DECIMAL(10,2),
    fuel_affordability_index         DECIMAL(10,2),
    oil_import_dependency_pct        DECIMAL(10,2),
    refinery_capacity_kbpd           INT,
    ev_adoption_pct                  DECIMAL(10,2),
    fuel_subsidy_active              BIT,
    subsidy_cost_bn_usd              DECIMAL(10,2),
    co2_transport_mt                 DECIMAL(10,2),
    price_date                       DATE,
    gasoline_pct_daily_wage          DECIMAL(10,2),
    regional_rank_fuel_affordability INT,
    dwh_create_date                  DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.crude_oil_annual', 'U') IS NOT NULL
    DROP TABLE silver.crude_oil_annual;
GO

CREATE TABLE silver.crude_oil_annual (
    "year"                  INT,
    brent_avg_usd_bbl       DECIMAL(6,3),
    wti_avg_usd_bbl         DECIMAL(6,3),
    brent_yoy_change_pct    DECIMAL(6,3),
    wti_yoy_change_pct      DECIMAL(6,3),
    key_event               NVARCHAR(50),
    brent_wti_spread        DECIMAL (6,3),
    avg_price_usd_bbl       DECIMAL (6,3),
    dwh_create_date         DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.fuel_tax_comparison', 'U') IS NOT NULL
    DROP TABLE silver.fuel_tax_comparison;
GO

CREATE TABLE silver.fuel_tax_comparison (
    country                     NVARCHAR(50),
    iso3                        NVARCHAR(3),    -- joined
    standard_country            NVARCHAR(MAX),  -- joined
    region                      NVARCHAR(50),
    gasoline_tax_pct            DECIMAL(6,2),
    diesel_tax_pct              DECIMAL(6,2),
    vat_pct                     DECIMAL(6,2),
    excise_usd_per_liter        DECIMAL(6,2),
    carbon_tax_active           BIT,
    total_tax_usd_per_liter     DECIMAL(6,2),
    tax_burden_category         NVARCHAR(50),
    dwh_create_date             DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.asia_subsidy_tracker', 'U') IS NOT NULL
    DROP TABLE silver.asia_subsidy_tracker;
GO

CREATE TABLE silver.asia_subsidy_tracker (
    country                         NVARCHAR(50),
    iso3                            NVARCHAR(3),
    gasoline_subsidized             BIT,
    diesel_subsidized               BIT,
    subsidy_type                    NVARCHAR(50),
    annual_subsidy_cost_bn_usd      DECIMAL(6,2),
    subsidy_pct_gdp                 DECIMAL(6,2),
    subsidy_description             NVARCHAR(MAX),
    last_price_change               DATE,
    pricing_mechanism               NVARCHAR(50),
    regulator                       NVARCHAR(10),
    dwh_create_date                 DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.country_ref', 'U') IS NOT NULL
    DROP TABLE silver.country_ref;
GO

CREATE TABLE silver.country_ref(
   "name"                     NVARCHAR(MAX),
   "alpha-3"                  NVARCHAR(3),
   region                     NVARCHAR(50),
   "sub-region"               NVARCHAR(50),
   "is-asia"				  INT,
   dwh_create_date            DATETIME2 DEFAULT GETDATE()
);
GO

